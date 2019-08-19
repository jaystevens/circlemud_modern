//
// Created by jaystevens on 8/17/2019.
//

#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <sys/stat.h>
#include <string.h>
#include <limits.h>
#include "version.h"
#include "argparse.h"

#if defined(_WIN32) || defined(_WIN64)
#define MAX_PATH _MAX_PATH
#endif

static const char *const usage[] = {
        "circle [options]",
        NULL,
};

struct launch_config {
    bool check_boot;
    const char *lib_dir;
    bool quick_boot;
    bool boot_restricted;
    bool no_spec_proc;
    bool need_copy_over;
    int32_t copy_over_socket;
    const char *path_to_exe;
};

static bool check_folder_exists(const char *folder_path)
{
    struct stat st_info;

    if (stat(folder_path, &st_info) != 0) {
        return false; // stat failed, folder does not exist
    }

    if ((st_info.st_mode & S_IFDIR) != 0) {
        return true; // stat says path is a directory
    }

    return false;  // exists but not a folder
}

static int main99(int argc, char **argv)
{
    char lib_dir[MAX_PATH];
    bool init_exit = false;
    struct game_startup_config game_cfg;

    // argparse params
    uint32_t PARAM_port = 4000;
    bool PARAM_check_boot = false;
    char *PARAM_lib_dir = "lib";
    bool PARAM_quick_boot = false;
    bool PARAM_restrict_mode = false;
    bool PARAM_wizlock_mode = false;
    bool PARAM_no_spec_proc = false;
    int32_t PARAM_copyover_socket = -1;

    // argparse vars
    struct argparse_option options[] = {
            OPT_HELP(),
            OPT_INTEGER('p', "port",       &PARAM_port, "game port (default: 4000)"),
            OPT_STRING('d',  "libdir",     &PARAM_lib_dir, "library directory (default: ./lib)", NULL, 0, 0),
            OPT_BOOLEAN('q', "quick",      &PARAM_quick_boot, "quick boot (skip rent check for object limits)", NULL, 0, 0),
            OPT_BOOLEAN('r', "restrict",   &PARAM_restrict_mode, "restrict login to existing players", NULL, 0, 0),
            OPT_BOOLEAN('w', "wizlock",    &PARAM_wizlock_mode, "restrict login to god or higher", NULL, 0, 0),
            OPT_BOOLEAN('s', "nospecproc", &PARAM_no_spec_proc, "do not setup special procedure assignments", NULL, 0, 0),
            OPT_BOOLEAN(0,   "check",      &PARAM_check_boot, "check game files and exit", NULL, 0, 0),
            OPT_GROUP("DO NOT USE"),
            OPT_INTEGER('C', "copyover",   &PARAM_copyover_socket, "copyover control socket [USED INTERNALLY, DO NOT USE]", NULL, 0, 0),
            OPT_END(),
    };
    struct argparse argparse;

    printf("circlemud\n");
    printf("Version: %s\n", MUD_VERSION_FULL);
    printf("Compiler: %s %s\n", COMPILER_NAME, COMPILER_VER);
    printf("compiled on: %s @ %s\n", MUD_BUILD_TIME, MUD_BUILD_HOST);
    printf("\n");

    // parse args
    argparse_init(&argparse, options, usage, 0);
    argparse_describe(&argparse, "\ncircle", "\ncircle mud server");
    argparse_parse(&argparse, argc, (const char **) argv);  // returns argc

    // validate port
    if ((PARAM_port <= 0) || (PARAM_port > 65535)) {
        printf("invalid port: %d, valid range 1-65535\n", PARAM_port);
        init_exit = true;
    }

    // convert PARAM_lib_dir to absolute path stored as lib_dir
#if defined(_WIN32) || defined(_WIN64)
    _fullpath((char*)lib_dir, (const char*)PARAM_lib_dir, sizeof(lib_dir));
#else
    realapath((const char*)&PARAM_lib_dir, (char*)&lib_dir)
#endif

    // check lib dir exists
    if (!check_folder_exists(lib_dir)) {
        printf("unable to find lib directory: %s\n", lib_dir);
        init_exit = true;
    }

    printf("PARAM_port: %d\n", PARAM_port);
    printf("PARAM_check: %d\n", PARAM_check_boot);
    printf("PARAM_lib_dir: %s\n", PARAM_lib_dir);
    printf("PARAM_quick_boot: %d\n", PARAM_quick_boot);
    printf("PARAM_restrict_mode: %d\n", PARAM_restrict_mode);
    printf("PARAM_no_spec_proc: %d\n", PARAM_no_spec_proc);

    if (init_exit) {
        return 1;
    }

    // zero game_cfg
    memset(&game_cfg, 0, sizeof(game_cfg));
    // setup game cfg
    game_cfg.check_boot = PARAM_check_boot;
    game_cfg.lib_dir = (const char*)&lib_dir;
    game_cfg.quick_boot = PARAM_quick_boot;
    game_cfg.boot_restricted = PARAM_restrict_mode;
    game_cfg.no_spec_proc = PARAM_no_spec_proc;
    game_cfg.copy_over_socket = PARAM_copyover_socket;

    return 0;
}