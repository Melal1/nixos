#include <ncurses.h>
#include <iostream>
#include <filesystem>
#include <vector>
#include <string>
#include <cstdlib>
#include <map>
#include <fstream>
#include <sstream>
#include <array>

namespace fs = std::filesystem;

// Paths
const std::string HOME = std::getenv("HOME");
const std::string MONITOR_FILE = HOME + "/.config/wallspan_monitors.txt";
const std::string CACHE_DIR = HOME + "/.cache/personal";
const std::string CMD_FILE = CACHE_DIR + "/wallcmd";

// Utility function to run shell commands and get output
std::string exec(const std::string &cmd) {
    std::array<char, 128> buffer;
    std::string result;
    FILE* pipe = popen(cmd.c_str(), "r");
    if (!pipe) return "";
    while (fgets(buffer.data(), buffer.size(), pipe) != nullptr) {
        result += buffer.data();
    }
    pclose(pipe);
    return result;
}

// Fetch monitors if not exists
void init_monitors() {
    if (!fs::exists(MONITOR_FILE)) {
        std::string monitors = exec("hyprctl monitors all | grep 'Monitor' | awk '{print $2}'");
        std::ofstream ofs(MONITOR_FILE);
        ofs << monitors;
        ofs.close();
    }
}

// Read monitors from file
std::vector<std::string> read_monitors() {
    std::vector<std::string> monitors;
    std::ifstream ifs(MONITOR_FILE);
    std::string line;
    while (std::getline(ifs, line)) {
        if (!line.empty())
            monitors.push_back(line);
    }
    return monitors;
}

// List image files in directory
std::vector<fs::path> list_images(const fs::path &dir) {
    std::vector<fs::path> images;
    for (auto &p : fs::directory_iterator(dir)) {
        if (!p.is_regular_file()) continue;
        std::string ext = p.path().extension().string();
        for (auto &c: ext) c = std::tolower(c);
        if (ext == ".png" || ext == ".jpg" || ext == ".jpeg" || ext == ".bmp" || ext == ".gif")
            images.push_back(p.path());
    }
    return images;
}

// Display menu with ncurses and return index (Vim-style navigation, q to exit)
int menu_select(const std::vector<std::string> &options, const std::string &title) {
    int highlight = 0;
    int choice = -1;
    int c;

    while (true) {
        clear();
        mvprintw(0, 0, title.c_str());
        for (size_t i = 0; i < options.size(); ++i) {
            if ((int)i == highlight)
                attron(A_REVERSE);
            mvprintw(i + 2, 0, options[i].c_str());
            if ((int)i == highlight)
                attroff(A_REVERSE);
        }
        refresh();

        c = getch();
        switch (c) {
            case 'k': case 'K': highlight--; if (highlight < 0) highlight = options.size()-1; break; // up
            case 'j': case 'J': highlight++; if (highlight >= (int)options.size()) highlight = 0; break; // down
            case 10: choice = highlight; break; // Enter
            case 'q': case 'Q': return -1; // exit menu
        }
        if (choice != -1) break;
    }
    return choice;
}

int main(int argc, char* argv[]) {
    if (argc < 2) {
        std::cerr << "Usage: " << argv[0] << " <wallpaper_dir> [mode]\n";
        return 1;
    }

    fs::path target_dir = fs::absolute(argv[1]);
    fs::path edited_dir = target_dir / "edited";
    fs::create_directories(edited_dir);
    fs::create_directories(CACHE_DIR);

    int mode = 0;
    if (argc >= 3) mode = std::stoi(argv[2]);

    // === Mode 1: restore previous session ===
    if (mode == 1) {
        if (fs::exists(CMD_FILE) && fs::file_size(CMD_FILE) > 0) {
            std::cout << "Restoring last wallpaper session...\n";
            std::string cmd = "bash \"" + CMD_FILE + "\"";
            system(cmd.c_str());
        } else {
            system("dunstify 'Wallpaper' 'No previous wallpaper session found' -u normal -t 5000");
        }
        return 0;
    }

    std::map<std::string,std::string> monitor_cmds;

    init_monitors();
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

    std::vector<std::string> rotation_labels = {"0°","90°","180°","270°"};

    // Initialize ncurses once
    initscr();
    noecho();
    cbreak();
    keypad(stdscr, TRUE);
    curs_set(0);

    while (true) {
        // Prepare monitor names
        std::vector<std::string> monitor_names = monitors;
        int m_idx = menu_select(monitor_names, "Select monitor:");
        if (m_idx == -1) break; // exit on q

        // Prepare wallpaper names
        std::vector<std::string> image_names;
        for (auto &p : images) image_names.push_back(p.filename().string());
        int w_idx = menu_select(image_names, "Select wallpaper:");
        if (w_idx == -1) break; // exit on q

        // Rotation selection
        int r_idx = menu_select(rotation_labels, "Select rotation:");
        if (r_idx == -1) break; // exit on q
        int rotate = r_idx * 90;

        fs::path wallpaper = fs::absolute(images[w_idx]);
        fs::path final_wall = wallpaper;

        if (rotate != 0) {
            std::stringstream ss;
            ss << edited_dir.string() << "/" << wallpaper.stem().string() << "_rot" << rotate << wallpaper.extension().string();
            final_wall = fs::path(ss.str());
            std::string cmd = "magick \"" + wallpaper.string() + "\" -rotate " + std::to_string(rotate) + " \"" + final_wall.string() + "\"";
            system(cmd.c_str());
        }

        std::string swww_cmd = "swww img -o \"" + monitors[m_idx] + "\" \"" + final_wall.string() + "\"";
        system(swww_cmd.c_str());
        monitor_cmds[monitors[m_idx]] = swww_cmd;

        // Exit menu
        std::vector<std::string> options = {"Set another wallpaper","Exit"};
        int exit_choice = menu_select(options, "Options:");
        if (exit_choice == -1 || exit_choice == 1) break; // q or Exit
    }

    // Save wallcmd
    std::ofstream ofs(CMD_FILE);
    ofs << "#!/usr/bin/env bash\n\n";
    for (auto &p : monitor_cmds) {
        ofs << p.second << "\n";
    }
    ofs.close();
    fs::permissions(CMD_FILE, fs::perms::owner_all | fs::perms::group_read | fs::perms::others_read);

    // End ncurses at the very end
    endwin();

    std::cout << "Session saved to " << CMD_FILE << "\n";

    return 0;
}

