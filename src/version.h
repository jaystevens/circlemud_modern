#ifndef MUD_VERSION_H
#define MUD_VERSION_H


// compiler detection
#define STRINGIFY(x) #x
#define TOSTRING(x) STRINGIFY(x)

// Visual Studio
#if defined(_MSC_VER)
#define COMPILER_NAME "Visual Studio"

// visual studio 2017
#if (_MSC_VER >= 1910 && _MSC_VER < 1920)
#if (_MSC_VER == 1910)
#if (_MSC_FULL_VER == 191025017)
#define COMPILER_VER "2017 - 15.0 - " TOSTRING(_MSC_FULL_VER)
#elif (_MSC_FULL_VER == 191025017)
#define COMPILER_VER "2017 update 1 - 15.1 - " TOSTRING(_MSC_FULL_VER)
#elif (_MSC_FULL_VER == 191025017)
#define COMPILER_VER "2017 update 2 - 15.2 - " TOSTRING(_MSC_FULL_VER)
#else
#define COMPILER_VER "2017 - 15.x - " TOSTRING(_MSC_FULL_VER)
#endif
#elif (_MSC_VER == 1911)
#if (_MSC_FULL_VER == 191125507)
#define COMPILER_VER "2017 update 3 - 15.3 - " TOSTRING(_MSC_FULL_VER)
#elif (_MSC_FULL_VER == 191125542)
#define COMPILER_VER "2017 update 4 - 15.4.4 - " TOSTRING(_MSC_FULL_VER)
#elif (_MSC_FULL_VER == 191125547)
#define COMPILER_VER "2017 update 4 - 15.4.5 - " TOSTRING(_MSC_FULL_VER)
#else
#define COMPILER_VER "2017 update 3/4 - 15.3/15.4 - " TOSTRING(_MSC_FULL_VER)
#endif
#elif (_MSC_VER == 1912)
#define COMPILER_VER "2017 update 5 - 15.5 - " TOSTRING(_MSC_FULL_VER)
#elif (_MSC_VER == 1913)
#define COMPILER_VER "2017 update 6 - 15.6 - " TOSTRING(_MSC_FULL_VER)
#elif (_MSC_VER == 1914)
#define COMPILER_VER "2017 update 7 - 15.7 - " TOSTRING(_MSC_FULL_VER)
#elif (_MSC_VER == 1915)
#define COMPILER_VER "2017 update 8 - 15.8 - " TOSTRING(_MSC_FULL_VER)
#elif (_MSC_VER == 1916)
        // 2017 update 9.x
#if (_MSC_FULL_VER == 191627023)
#define COMPILER_VER "2017 update 9 - 15.9.1 - " TOSTRING(_MSC_FULL_VER)
#elif (_MSC_FULL_VER == 191627025)
#define COMPILER_VER "2017 update 9 - 15.9.4 - " TOSTRING(_MSC_FULL_VER)
#elif (_MSC_FULL_VER == 191627026)
#define COMPILER_VER "2017 update 9 - 15.9.5 - " TOSTRING(_MSC_FULL_VER)
#elif (_MSC_FULL_VER == 191627027)
#define COMPILER_VER "2017 update 9 - 15.9.7 - " TOSTRING(_MSC_FULL_VER)
#elif (_MSC_FULL_VER == 191627030)
#define COMPILER_VER "2017 update 9 - 15.9.11 - " TOSTRING(_MSC_FULL_VER)
#elif (_MSC_FULL_VER == 191627031)
#define COMPILER_VER "2017 update 9 - 15.9.12 - " TOSTRING(_MSC_FULL_VER)
#else
#define COMPILER_VER "2017 update 9+ - 15.x - " TOSTRING(_MSC_FULL_VER)
#endif
#else
#define COMPILER_VER "2017 15.x - " TOSTRING(_MSC_FULL_VER)
#endif
#endif

// visual studio 2019
#if (_MSC_VER >= 1920 && _MSC_VER < 1930)
#if (_MSC_VER == 1920)
#if (_MSC_FULL_VER == 192027508)
#define COMPILER_VER "2019 - 16.0.0-3 - " TOSTRING(_MSC_FULL_VER)
#else
#define COMPILER_VER "2019 - 16.x - " TOSTRING(_MSC_FULL_VER)
#endif
#elif (_MSC_VER == 1921)
#if (_MSC_FULL_VER == 192127702)
#define COMPILER_VER "2019 - 16.1.0 - " TOSTRING(_MSC_FULL_VER)
#else
#define COMPILER_VER "2019 - 16.x - " TOSTRING(_MSC_FULL_VER)
#endif
#elif (_MSC_VER == 1922)
#if (_MSC_FULL_VER == 192227905)
#define COMPILER_VER "2019 - 16.2.0 - " TOSTRING(_MSC_FULL_VER)
#else
#define COMPILER_VER "2019 - 16.2.0 - " TOSTRING(_MSC_FULL_VER)
#endif
#else
#define COMPILER_VER "2019 - 16.x - " TOSTRING(_MSC_FULL_VER)
#endif
#endif

// failsafe
#ifndef COMPILER_VER
#define COMPILER_VER TOSTRING(_MSC_FULL_VER)
#endif

// GCC
#elif defined(__GNUC__)
#define COMPILER_NAME "GCC"
#define COMPILER_VER __VERSION__

// ICC - Intel Compiler
#elif defined(__INTEL_COMPILER)
#define COMPILER_NAME "Intel Compiler"
//    #define COMPILER_VER TOSTRING(__INTEL_COMPILER)

// CLANG
#elif defined(__clang__)
#define COMPILER_NAME "CLANG"
#define COMPILER_VER TOSTRING(__clang_major__) "." TOSTRING(__clang_minor__) "." TOSTRING(__clang_patchlevel__)

// MINGW 32bit
#elif defined(__MINGW32__)
#define COMPILER_NAME "MING32"
#define COMPILER_VER TOSTRING(__MINGW32_VERSION_MAJOR) "." TOSTRING(__MINGW32_VERSION_MINOR)

// MINGW 64bit
#elif defined(__MINGW64__)
#define COMPILER_NAME "MINGW64"
#define COMPILER_VER TOSTRING(__MINGW64_VERSION_MAJOR) "." TOSTRING(__MINGW64_VERSION_MINOR)
#endif

// fail safe - compiler name
#ifndef COMPILER_NAME
#define COMPILER_NAME "???"
#endif
// fail safe - compiler version
#ifndef COMPILER_VER
#define COMPILER_VER " "
#endif


extern const int MUD_VERSION_MAJOR;
extern const int MUD_VERSION_MINOR;
extern const int MUD_VERSION_PATCH;
extern const int MUD_VERSION_TWEAK;
extern const char *MUD_VERSION;
extern const char *MUD_VERSION_FULL;
extern const char *MUD_BUILD_HOST;
extern const char *MUD_BUILD_TIME;

#endif // MUD_VERSION_H

