#include "block.h"

#include <fcntl.h>
#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>

#include "config.h"
#include "util.h"

block block_new(const char* const icon, const char* const command,
                const unsigned int interval, const int signal) {
    block block = {
        .icon = icon,
        .command = command,
        .interval = interval,
        .signal = signal,

        .output = {[0] = '\0'},
        .fork_pid = -1,
    };

    return block;
}

int block_init(block* const block) {
    if (pipe(block->pipe) != 0) {
        (void)fprintf(stderr,
                      "error: could not create a pipe for \"%s\" block\n",
                      block->command);
        return 1;
    }

    return 0;
}

int block_deinit(block* const block) {
    int status = close(block->pipe[READ_END]);
    status |= close(block->pipe[WRITE_END]);
    if (status != 0) {
        (void)fprintf(stderr, "error: could not close \"%s\" block's pipe\n",
                      block->command);
        return 1;
    }

    return 0;
}

// Fast path: read a file directly without fork+exec.
// Use "file:/path" as the command to trigger this.
static int block_read_file(block* const block) {
    const char* const path = block->command + 5;  // skip "file:"
    const int fd = open(path, O_RDONLY);
    if (fd == -1) {
        const char null = '\0';
        (void)write(block->pipe[WRITE_END], &null, sizeof(null));
        return 1;
    }

    char buffer[LEN(block->output)];
    const ssize_t n = read(fd, buffer, LEN(buffer) - 1);
    close(fd);

    if (n <= 0) {
        const char null = '\0';
        (void)write(block->pipe[WRITE_END], &null, sizeof(null));
        return (n < 0) ? 1 : 0;
    }

    // Remove trailing newlines and null-terminate.
    size_t length = (size_t)n;
    while (length > 0 &&
           (buffer[length - 1] == '\n' || buffer[length - 1] == '\r')) {
        --length;
    }
    buffer[length] = '\0';

    const size_t output_size =
        truncate_utf8_string(buffer, LEN(buffer), MAX_BLOCK_OUTPUT_LENGTH);
    (void)write(block->pipe[WRITE_END], buffer, output_size);

    return 0;
}

int block_execute(block* const block, const uint8_t button) {
    // Ensure only one child process exists per block at an instance.
    if (block->fork_pid != -1) {
        return 0;
    }

    // Fast path: read file directly in-process — no fork, no exec.
    if (strncmp(block->command, "file:", 5) == 0) {
        if (block_read_file(block) != 0) {
            return 1;
        }
        // Mark as "ready" and tell block_update not to waitpid
        block->fork_pid = -2;
        return 0;
    }

    block->fork_pid = fork();
    if (block->fork_pid == -1) {
        (void)fprintf(
            stderr, "error: could not create a subprocess for \"%s\" block\n",
            block->command);
        return 1;
    }

    if (block->fork_pid == 0) {
        const int write_fd = block->pipe[WRITE_END];
        int status = close(block->pipe[READ_END]);

        if (button != 0) {
            char button_str[4];
            (void)snprintf(button_str, LEN(button_str), "%hhu", button);
            status |= setenv("BLOCK_BUTTON", button_str, 1);
        }

        const char null = '\0';
        if (status != 0) {
            (void)write(write_fd, &null, sizeof(null));
            exit(EXIT_FAILURE);
        }

        FILE* const file = popen(block->command, "r");
        if (file == NULL) {
            (void)write(write_fd, &null, sizeof(null));
            exit(EXIT_FAILURE);
        }

        // Ensure null-termination since fgets() will leave buffer untouched on
        // no output.
        char buffer[LEN(block->output)] = {[0] = null};
        (void)fgets(buffer, LEN(buffer), file);

        // Remove trailing newlines.
        const size_t length = strcspn(buffer, "\n");
        buffer[length] = null;

        // Exit if command execution failed or if file could not be closed.
        if (pclose(file) != 0) {
            (void)write(write_fd, &null, sizeof(null));
            exit(EXIT_FAILURE);
        }

        const size_t output_size =
            truncate_utf8_string(buffer, LEN(buffer), MAX_BLOCK_OUTPUT_LENGTH);
        (void)write(write_fd, buffer, output_size);

        exit(EXIT_SUCCESS);
    }

    return 0;
}

int block_update(block* const block) {
    char buffer[LEN(block->output)];

    const ssize_t bytes_read =
        read(block->pipe[READ_END], buffer, LEN(buffer));
    if (bytes_read == -1) {
        (void)fprintf(stderr,
                      "error: could not fetch output of \"%s\" block\n",
                      block->command);
        return 2;
    }

    // Collect exit-status of the subprocess to avoid zombification.
    int fork_status = 0;
    if (block->fork_pid != -2) {
        if (waitpid(block->fork_pid, &fork_status, 0) == -1) {
            (void)fprintf(
                stderr,
                "error: could not obtain exit status for \"%s\" block\n",
                block->command);
            return 2;
        }
    }
    block->fork_pid = -1;

    if (fork_status != 0) {
        (void)fprintf(stderr,
                      "error: \"%s\" block exited with non-zero status\n",
                      block->command);
        return 1;
    }

    (void)strncpy(block->output, buffer, LEN(buffer));

    return 0;
}
