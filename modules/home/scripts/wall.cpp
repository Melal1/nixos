#include <array>
#include <cstdlib>
#include <filesystem>
#include <fstream>
#include <iostream>
#include <map>
#include <memory>
#include <ncurses.h>
#include <sstream>
#include <string>
#include <vector>
#include <algorithm>

namespace fs = std::filesystem;

// Paths
const std::string HOME = std::getenv("HOME");
const fs::path CACHE_DIR = fs::path(HOME) / ".cache" / "personal";
const fs::path CMD_FILE = CACHE_DIR / "wallcmd";

// RAII wrapper for ncurses
struct NcursesGuard {
    NcursesGuard() {
        initscr();
        noecho();
        cbreak();
        keypad(stdscr, TRUE);
        curs_set(0);
    }
    ~NcursesGuard() {
        endwin();
    }
};

// Run shell command and capture output
std::string exec(const std::string &cmd) {
    std::array<char, 128> buffer{};
    std::string result;
    std::unique_ptr<FILE, decltype(&pclose)> pipe(popen(cmd.c_str(), "r"), pclose);
    if (!pipe) return "";

    while (fgets(buffer.data(), buffer.size(), pipe.get())) {
        result += buffer.data();
    }
    return result;
}

std::vector<std::string> read_monitors() {
    std::vector<std::string> monitors;
    std::istringstream iss(exec("hyprctl monitors all | awk '/Monitor/ {print $2}'"));
    std::string line;
    while (std::getline(iss, line)) {
        if (!line.empty()) monitors.push_back(std::move(line));
    }
    return monitors;
}

// List image files in directory
std::vector<fs::path> list_images(const fs::path &dir) {
    std::vector<fs::path> images;
    for (auto &p : fs::directory_iterator(dir)) {
        if (!p.is_regular_file()) continue;
        std::string ext = p.path().extension().string();
        std::transform(ext.begin(), ext.end(), ext.begin(), ::tolower);
        if (ext == ".png" || ext == ".jpg" || ext == ".jpeg" || ext == ".bmp" || ext == ".gif") {
            images.push_back(p.path());
        }
    }
    return images;
}

// Display menu with ncurses and return index
int menu_select(const std::vector<std::string> &options, const std::string &title) {
    int highlight = 0;
    int choice = -1;
    int c;

    while (true) {
        clear();
        mvprintw(0, 0, "%s", title.c_str());
        for (size_t i = 0; i < options.size(); ++i) {
            if ((int)i == highlight) attron(A_REVERSE);
            mvprintw(i + 2, 0, "%s", options[i].c_str());
            if ((int)i == highlight) attroff(A_REVERSE);
        }
        refresh();

        c = getch();
        switch (c) {
            case 'k': case 'K':
                highlight = (highlight - 1 + options.size()) % options.size();
                break;
            case 'j': case 'J':
                highlight = (highlight + 1) % options.size();
                break;
            case 10:
                choice = highlight;
                break;
            case 'q': case 'Q':
                return -1;
        }
        if (choice != -1) break;
    }
    return choice;
}

int main(int argc, char *argv[]) {
    if (argc < 2) {
        std::cerr << "Usage: " << argv[0] << " <wallpaper_dir> [mode]\n";
        return 1;
    }

    fs::path target_dir = fs::absolute(argv[1]);
    fs::path edited_dir = target_dir / "edited";
    fs::create_directories(edited_dir);
    fs::create_directories(CACHE_DIR);

    int mode = (argc >= 3) ? std::stoi(argv[2]) : 0;

    // === Mode 1: restore previous session ===
    if (mode == 1) {
        if (fs::exists(CMD_FILE) && fs::file_size(CMD_FILE) > 0) {
            std::cout << "Restoring last wallpaper session...\n";
            fs::permissions(CMD_FILE, fs::perms::owner_exec, fs::perm_options::add);
            system(CMD_FILE.string().c_str());
        } else {
            system("dunstify 'Wallpaper' 'No previous wallpaper session found.\nPlease run wallSet' -u normal -t 5000");
        }
        return 0;
    }

    auto monitors = read_monitors();
    if (monitors.empty()) {
        std::cerr << "No monitors found.\n";
        return 1;
    }

    auto images = list_images(target_dir);
    if (images.empty()) {
        std::cerr << "No images found in " << target_dir << "\n";
        return 1;
    }

    static const std::vector<std::string> rotation_labels = {"0°", "90°", "180°", "270°"};
    std::map<std::string, std::string> monitor_cmds;

    NcursesGuard ncurses; // auto cleanup

    while (true) {
        int m_idx = menu_select(monitors, "Select monitor:");
        if (m_idx == -1) break;

        std::vector<std::string> image_names;
        image_names.reserve(images.size());
        for (auto &p : images) image_names.push_back(p.filename().string());

        int w_idx = menu_select(image_names, "Select wallpaper:");
        if (w_idx == -1) break;

        int r_idx = menu_select(rotation_labels, "Select rotation:");
        if (r_idx == -1) break;
        int rotate = r_idx * 90;

        fs::path wallpaper = fs::absolute(images[w_idx]);
        fs::path final_wall = wallpaper;

        if (rotate != 0) {
            final_wall = edited_dir / (wallpaper.stem().string() + "_rot" + std::to_string(rotate) + wallpaper.extension().string());
            std::string cmd = "magick \"" + wallpaper.string() + "\" -rotate " + std::to_string(rotate) + " \"" + final_wall.string() + "\"";
            system(cmd.c_str());
        }

        std::string swww_cmd = "swww img -o \"" + monitors[m_idx] + "\" \"" + final_wall.string() + "\"";
        system(swww_cmd.c_str());
        monitor_cmds[monitors[m_idx]] = swww_cmd;

        std::vector<std::string> options = {"Set another wallpaper", "Exit"};
        int exit_choice = menu_select(options, "Options:");
        if (exit_choice == -1 || exit_choice == 1) break;
    }

    // Save wallcmd
    std::ofstream ofs(CMD_FILE);
    ofs << "#!/usr/bin/env bash\n\n";
    for (auto &p : monitor_cmds) ofs << p.second << "\n";
    ofs.close();
    fs::permissions(CMD_FILE, fs::perms::owner_all | fs::perms::group_read | fs::perms::others_read);

    std::cout << "Session saved to " << CMD_FILE << "\n";
    return 0;
}

