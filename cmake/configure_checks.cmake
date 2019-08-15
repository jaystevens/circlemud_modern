include(CheckLibraryExists)
include(CheckCSourceCompiles)
include(CheckIncludeFiles)
include(CheckFunctionExists)
include(CheckSymbolExists)
include(CheckPrototypeDefinition)
include(CheckTypeSize)
include(CheckStructHasMember)

# set(CONF_H_GENERATED 0)  # set for debuging

# setup conf file
if(NOT CONF_H_GENERATED)
    if(MSVC)
        # if MSVC use prebuilt conf.h
        message(STATUS "conf.h - using prebuilt file for Visual Studio")
        include(windows_cache)
    else()
        message(STATUS "conf.h - detecting configuration")

        # PREFLIGHT
        CHECK_INCLUDE_FILES(stdio.h HAVE_STDIO_H)
        if(NOT HAVE_STDIO_H)
            message(ERROR "unable to find stdio.h")
        endif()
        CHECK_INCLUDE_FILES(stdint.h HAVE_STDINT_H)
        if(NOT_HAVE_STDINT_H)
            message(ERROR "unable to find stdint.h")
        endif()

        CHECK_INCLUDE_FILES(sys/types.h HAVE_SYS_TYPES_H)

        # in C11 const should always be defined/work
        set(const 0 CACHE INTERNAL "")

        CHECK_INCLUDE_FILES(sys/wait.h HAVE_SYS_WAIT_H)

        CHECK_FUNCTION_EXISTS(vprintf HAVE_VPRINTF)

        if(NOT HAVE_VPRINTF)
            CHECK_FUNCTION_EXISTS(_doprnt HAVE_DOPRNT)
        else()
            unset(HAVE_DOPRNT)
        endif()

        CHECK_TYPE_SIZE(pid_t HAVE_PID_T)
        if(HAVE_PID_T GREATER_EQUAL 0)
            set(pid_t 0 CACHE INTERNAL "")
        else()
            set(pid_t int CACHE INTERNAL "")
        endif()

        include(TestSignalType)

        CHECK_TYPE_SIZE(size_t HAVE_SIZE_T)
        if(HAVE_SIZE_T GREATER_EQUAL 0)
            set(size_t 0 CACHE INTERNAL "")
        else()
            set(size_t unsigned CACHE INTERNAL "")
        endif()

        # STDC_HEADERS test
        CHECK_INCLUDE_FILES(stdlib.h HAVE_STDLIB_H)
        CHECK_INCLUDE_FILES(stdarg.h HAVE_STDARG_H)
        CHECK_INCLUDE_FILES(string.h HAVE_STRING_H)
        CHECK_INCLUDE_FILES(float.h HAVE_FLOAT_H)
        if((HAVE_STDLIB_H) AND (HAVE_STDARG_H) AND (HAVE_STRING_H) AND (HAVE_FLOAT_H))
            set(STDC_HEADERS 1 CACHE INTERNAL "")
        endif()

        CHECK_INCLUDE_FILES("sys/time.h;time.h" TIME_WITH_SYS_TIME)

        # CIRCLE_UNIX / CIRCLE_WINDOWS
        if(WIN32)
            set(CIRCLE_UNIX 0 CACHE INTERNAL "")
            set(CIRCLE_WINDOWS 1 CACHE INTERNAL "")
        else()
            set(CIRCLE_UNIX 1 CACHE INTERNAL "")
            set(CIRCLE_WINDOWS 0 CACHE INTERNAL "")
        endif()

        # CIRCLE_CRYPT test
        CHECK_FUNCTION_EXISTS(crypt HAVE_CRYPT)
        CHECK_LIBRARY_EXISTS(crypt crypt "" HAVE_CRYPT_LIB)

        # CIRCLE_CRYPT
        if(HAVE_CRYPT OR HAVE_CRYPT_LIB)
            set(CIRCLE_CRYPT 1 CACHE INTERNAL "")
        else()
            set(CIRCLE_CRYPT 0 CACHE INTERNAL "")
        endif()

        # TODO HAVE_UNSAFE_CRYPT
        if(CIRCLE_CRYPT)
            message(STATUS "checking if crypt needs over 10 characters")
            try_run(CRYPT_RUN_RESULT CRYPT_COMPILE_RESULT  ${CMAKE_CURRENT_BINARY_DIR} ${CMAKE_SOURCE_DIR}/cmake/broken_crypt_test.c
                    LINK_LIBRARIES crypt)
            message(STATUS "CRYPT_RUN_RESULT: ${CRYPT_RUN_RESULT}")
            message(STATUS "CRYPT_COMPILE_RESULT: ${CRYPT_COMPILE_RESULT}")
            if(CRYPT_RUN_RESULT)
                message(STATUS "crypt works!")
                set(HAVE_UNSAFE_CRYPT 0 CACHE INTERNAL "")
            else()
                message(STATUS "crypt needs 10+ characters")
                set(HAVE_UNSAFE_CRYPT 1 CACHE INTERNAL "")
            endif()
        else()
            message(STATUS "skipping check for broken crypt, crypt not found")
            set(HAVE_UNSAFE_CRYPT 0 CACHE INTERNAL "")
        endif()

        # TODO - broken on windows - need to find headers
        CHECK_STRUCT_HAS_MEMBER("struct in_addr" s_addr "netinet/in.h" HAVE_STRUCT_IN_ADDR)

        # TODO - retest on windows - probably still broken
        set(CMAKE_EXTRA_INCLUDE_FILES ${CMAKE_EXTRA_INCLUDE_FILES} sys/socket.h)
        CHECK_TYPE_SIZE(socklen_t SOCKLEN_T_SIZE)
        if(SOCKLEN_T_SIZE GREATER_EQUAL 0)
            set(socklen_t 0 CACHE INTERNAL "")
        else()
            set(socklen_t unsigned CACHE INTERNAL "")
        endif()
        set(CMAKE_EXTRA_INCLUDE_FILES "")

        CHECK_TYPE_SIZE(ssize_t HAVE_SSIZE_T)
        if(HAVE_SSIZE_T GREATER_EQUAL 0)
            set(ssize_t 0 CACHE INTERNAL "")
        else()
            set(ssize_t int CACHE INTERNAL "")
        endif()

        CHECK_FUNCTION_EXISTS(gettimeofday HAVE_GETTIMEOFDAY)  # TODO -lnsl
        CHECK_FUNCTION_EXISTS(inet_addr HAVE_INET_ADDR)
        CHECK_FUNCTION_EXISTS(inet_aton HAVE_INET_ATON)
        CHECK_FUNCTION_EXISTS(select HAVE_SELECT)
        CHECK_FUNCTION_EXISTS(snprintf HAVE_SNPRINTF)
        CHECK_FUNCTION_EXISTS(strcasecmp HAVE_STRCASECMP)
        CHECK_FUNCTION_EXISTS(strdup HAVE_STRDUP)
        CHECK_FUNCTION_EXISTS(strerror HAVE_STRERROR)
        CHECK_FUNCTION_EXISTS(stricmp HAVE_STRICMP)
        CHECK_FUNCTION_EXISTS(strlcpy HAVE_STRLCPY)
        CHECK_FUNCTION_EXISTS(strncasecmp HAVE_STRNCASECMP)
        CHECK_FUNCTION_EXISTS(strnicmp HAVE_STRNICMP)
        CHECK_FUNCTION_EXISTS(strstr HAVE_STRSTR)
        CHECK_FUNCTION_EXISTS(vsnprintf HAVE_VSNPRINTF)

        CHECK_INCLUDE_FILES(arpa/inet.h HAVE_ARPA_INET_H)
        CHECK_INCLUDE_FILES(arpa/telnet.h HAVE_ARPA_TELNET_H)
        CHECK_INCLUDE_FILES(assert.h HAVE_ASSERT_H)
        CHECK_INCLUDE_FILES(crypt.h HAVE_CRYPT_H)
        CHECK_INCLUDE_FILES(errno.h HAVE_ERRNO_H)
        CHECK_INCLUDE_FILES(fcntl.h HAVE_FCNTL_H)
        CHECK_INCLUDE_FILES(limits.h HAVE_LIMITS_H)
        CHECK_INCLUDE_FILES(mcheck.h HAVE_MCHECK_H)
        CHECK_INCLUDE_FILES(memory.h HAVE_MEMORY_H)
        CHECK_INCLUDE_FILES(net/errno.h HAVE_NET_ERRNO_H)
        CHECK_INCLUDE_FILES(netdb.h HAVE_NETDB_H)
        CHECK_INCLUDE_FILES(netinet/in.h HAVE_NETINET_IN_H)
        CHECK_INCLUDE_FILES(signal.h HAVE_SIGNAL_H)
        CHECK_INCLUDE_FILES(string.h HAVE_STRING_H)
        CHECK_INCLUDE_FILES(strings.h HAVE_STRINGS_H)
        CHECK_INCLUDE_FILES(sys/fcntl.h HAVE_SYS_FCNTL_H)
        CHECK_INCLUDE_FILES(sys/resource.h HAVE_SYS_RESOURCE_H)
        CHECK_INCLUDE_FILES(sys/select.h HAVE_SYS_SELECT_H)
        CHECK_INCLUDE_FILES(sys/socket.h HAVE_SYS_SOCKET_H)
        CHECK_INCLUDE_FILES(sys/stat.h HAVE_SYS_STAT_H)
        CHECK_INCLUDE_FILES(sys/time.h HAVE_SYS_TIME_H)
        CHECK_INCLUDE_FILES(sys/types.h HAVE_SYS_TYPES_H)
        CHECK_INCLUDE_FILES(sys/uio.h HAVE_SYS_UIO_H)
        CHECK_INCLUDE_FILES(unistd.h HAVE_UNISTD_H)

        # TODO HAVE_LIBMALLOC -lmalloc
        # malloc library seems to be solaris related?
        # it is also possibly available on macOS?
        #   (apple has "barrowed" enough solaris code it would not surprise me)
        FIND_LIBRARY(HAVE_LIBMALLOC malloc)
        message(STATUS "HAVE_LIBMALLOC: ${HAVE_LIBMALLOC}")

        # NEED_ACCEPT_PROTO
        check_prototype_definition(accept
                "int accept(int sockfd, struct sockaddr *addr, socklen_t *addrlen)"
                "-1"
                "sys/types.h;sys/socket.h"
                HAVE_ACCEPT_PROTO
                )
        if(HAVE_ACCEPT_PROTO)
            set(NEED_ACCEPT_PROTO 0 CACHE INTERNAL "")
        else()
            set(NEED_ACCEPT_PROTO 1 CACHE INTERNAL "")
        endif()

        # NEED_ATOI_PROTO
        check_prototype_definition(atoi
                "int atoi(const char *str)"
                "-1"
                "stdlib.h;string.h"
                HAVE_ATOI_PROTO
                )
        if(HAVE_ATOI_PROTO)
            set(NEED_ATOI_PROTO 0 CACHE INTERNAL "")
        else()
            set(NEED_ATOI_PROTO 1 CACHE INTERNAL "")
        endif()

        # NEED_ATOL_PROTO
        check_prototype_definition(atol
                "long int atol(const char *str)"
                "-1"
                "stdlib.h;string.h"
                HAVE_ATOL_PROTO)
        if(HAVE_ATOL_PROTO)
            set(NEED_ATOL_PROTO 0 CACHE INTERNAL "")
        else()
            set(NEED_ATOL_PROTO 1 CACHE INTERNAL "")
        endif()

        # NEED_BIND_PROTO
        check_prototype_definition(bind
                "int bind(int sockfd, const struct sockaddr *addr, socklen_t addlen)"
                "-1"
                "sys/types.h;sys/socket.h"
                HAVE_BIND_PROTO)
        if(HAVE_BIND_PROTO)
            set(NEED_BIND_PROTO 0 CACHE INTERNAL "")
        else()
            set(NEED_BIND_PROTO 1 CACHE INTERNAL "")
        endif()

        # NEED_CHDIR_PROTO
        check_prototype_definition(chdir
                "int chdir(const char *path)"
                "-1"
                "unistd.h"
                HAVE_CHDIR_PROTO)
        if(HAVE_CHDIR_PROTO)
            set(NEED_BZERO_PROTO 0 CACHE INTERNAL "")
        else()
            set(NEED_BZERO_PROTO 1 CACHE INTERNAL "")
        endif()

        # NEED_CLOSE_PROTO
        check_prototype_definition(close
                "int close(int fd)"
                "-1"
                "unistd.h"
                HAVE_CLOSE_PROTO)
        if(HAVE_CLOSE_PROTO)
            set(NEED_CLOSE_PROTO 0 CACHE INTERNAL "")
        else()
            set(NEED_CLOSE_PROTO 1 CACHE INTERNAL "")
        endif()

        # NEED_CRYPT_PROTO - TODO check, need -lcrypt ?
        check_prototype_definition(crypt
                "char *crypt(const char *key, const char *salt)"
                "-1"
                "unistd.h"
                HAVE_CRYPT_PROTO)
        if(HAVE_CRYPT_PROTO)
            set(NEED_CRYPT_PROTO 0 CACHE INTERNAL "")
        else()
            set(NEED_CRYPT_PROTO 1 CACHE INTERNAL "")
        endif()
        # TODO - override, test needs work
        set(NEED_CRYPT_PROTO 0 CACHE INTERNAL "")

        # NEED_FCLOSE_PROTO
        check_prototype_definition(fclose
                "int fclose(FILE *stream)"
                "-1"
                "stdio.h"
                HAVE_FCLOSE_PROTO)
        if(HAVE_FCLOSE_PROTO)
            set(NEED_FCLOSE_PROTO 0 CACHE INTERNAL "")
        else()
            set(NEED_FCLOSE_PROTO 1 CACHE INTERNAL "")
        endif()

        # NEED_FCNTL_PROTO
        check_prototype_definition(fcntl
                "int fcntl(int fildes, int cmd, ...)"
                "-1"
                "unistd.h;fcntl.h"
                HAVE_FCNTL_PROTO)
        if(HAVE_FCNTL_PROTO)
            set(NEED_FCNTL_PROTO 0 CACHE INTERNAL "")
        else()
            set(NEED_FCNTL_PROTO 1 CACHE INTERNAL "")
        endif()

        # NEED_FFLUSH_PROTO
        check_prototype_definition(fflush
                "int fflush(FILE *stream)"
                "-1"
                "stdio.h"
                HAVE_FFLUSH_PROTO)
        if(HAVE_FFLUSH_PROTO)
            set(NEED_FFLUSH_PROTO 0 CACHE INTERNAL "")
        else()
            set(NEED_FFLUSH_PROTO 1 CACHE INTERNAL "")
        endif()

        # NEED_FPRINTF_PROTO
        check_prototype_definition(fprintf
                "int fprintf(FILE *stream, const char *format, ...)"
                "-1"
                "stdio.h"
                HAVE_FPRINTF_PROTO)
        if(HAVE_FPRINTF_PROTO)
            set(NEED_FPRINTF_PROTO 0 CACHE INTERNAL "")
        else()
            set(NEED_FPRINTF_PROTO 1 CACHE INTERNAL "")
        endif()

        # NEED_FPUTC_PROTO
        check_prototype_definition(fputc
                "int fputc(int c, FILE *stream)"
                "-1"
                "stdio.h"
                HAVE_FPUTC_PROTO)
        if(HAVE_FPUTC_PROTO)
            set(NEED_FPUTC_PROTO 0 CACHE INTERNAL "")
        else()
            set(NEED_FPUTC_PROTO 1 CACHE INTERNAL "")
        endif()

        # NEED_FPUTS_PROTO
        check_prototype_definition(fputs
                "int fputs(const char *s, FILE *stream)"
                "-1"
                "stdio.h"
                HAVE_FPUTS_PROTO)
        if(HAVE_FPUTS_PROTO)
            set(NEED_FPUTS_PROTO 0 CACHE INTERNAL "")
        else()
            set(NEED_FPUTS_PROTO 1 CACHE INTERNAL "")
        endif()

        # NEED_FREAD_PROTO
        check_prototype_definition(fread
                "size_t fread(void *ptr, size_t size, size_t nmemb, FILE *stream)"
                "0"
                "stdio.h"
                HAVE_FREAD_PROTO)
        if(HAVE_FREAD_PROTO)
            set(NEED_FREAD_PROTO 0 CACHE INTERNAL "")
        else()
            set(NEED_FREAD_PROTO 1 CACHE INTERNAL "")
        endif()

        # NEED_FSCANF_PROTO
        check_prototype_definition(fscanf
                "int fscanf(FILE *stream, const char *format, ...)"
                "-1"
                "stdio.h"
                HAVE_FSCANF_PROTO)
        if(HAVE_FSCANF_PROTO)
            set(NEED_FSCANF_PROTO 0 CACHE INTERNAL "")
        else()
            set(NEED_FSCANF_PROTO 1 CACHE INTERNAL "")
        endif()

        # NEED_FSEEK_PROTO
        check_prototype_definition(fseek
                "int fseek(FILE *stream, long offset, int whence)"
                "-1"
                "stdio.h"
                HAVE_FSEEK_PROTO)
        if(HAVE_FSEEK_PROTO)
            set(NEED_FSEEK_PROTO 0 CACHE INTERNAL "")
        else()
            set(NEED_FSEEK_PROTO 1 CACHE INTERNAL "")
        endif()

        # NEED_FWRITE_PROTO
        check_prototype_definition(fwrite
                "size_t fwrite(const void *ptr, size_t size, size_t nmemb, FILE *stream)"
                "0"
                "stdio.h"
                HAVE_FWRITE_PROTO)
        if(HAVE_FWRITE_PROTO)
            set(NEED_FWRITE_PROTO 0 CACHE INTERNAL "")
        else()
            set(NEED_FWRITE_PROTO 1 CACHE INTERNAL "")
        endif()

        # NEED_GETPID_PROTO
        check_prototype_definition(getpid
                "pid_t getpid(void)"
                "-1"
                "sys/types.h;unistd.h"
                HAVE_GETPID_PROTO)
        if(HAVE_GETPID_PROTO)
            set(NEED_GETPID_PROTO 0 CACHE INTERNAL "")
        else()
            set(NEED_GETPID_PROTO 1 CACHE INTERNAL "")
        endif()

        # NEED_GETRLIMIT_PROTO
        check_prototype_definition(getrlimit
                "int getrlimit(int resource, struct rlimit *rlim)"
                "-1"
                "sys/time.h;sys/resource.h"
                HAVE_GETRLIMIT_PROTO)
        if(HAVE_GETRLIMIT_PROTO)
            set(NEED_GETRLIMIT_PROTO 0 CACHE INTERNAL "")
        else()
            set(NEED_GETRLIMIT_PROTO 1 CACHE INTERNAL "")
        endif()

        # NEED_GETTIMEOFDAY_PROTO - LINUX
        check_prototype_definition(gettimeofday
                "int gettimeofday(struct timeval *tv, struct timezone *tz)"
                "-1"
                "sys/time.h"
                HAVE_GETTIMEOFDAY_PROTO_LINUX)
        check_prototype_definition(gettimeofday
                "int gettimeofday(struct timeval *restrict tp, void *restrict tzp)"
                "-1"
                "sys/time.h"
                HAVE_GETTIMEOFDAY_PROTO_MACOS)
        if(HAVE_GETTIMEOFDAY_PROTO_LINUX OR HAVE_GETTIMEOFDAY_PROTO_MACOS)
            message(STATUS "NEED_GETTIMEOFDAY_PROTO 0")
            set(NEED_GETTIMEOFDAY_PROTO 0 CACHE INTERNAL "")
        else()
            message(STATUS "NEED_GETTIMEOFDAY_PROTO 1")
            set(NEED_GETTIMEOFDAY_PROTO 1 CACHE INTERNAL "")
        endif()

        # NEED_HTONL_PROTO
        check_prototype_definition(htonl
                "uint32_t htonl(uint32_t hostlong)"
                "-1"
                "arpa/inet.h"
                HAVE_HTONL_PROTO)
        if(HAVE_HTONL_PROTO)
            set(NEED_HTONL_PROTO 0 CACHE INTERNAL "")
        else()
            # FreeBSD / macOS use a macro
            check_symbol_exists(htonl "arpa/inet.h" HAVE_HTONL_SYMBOL)
            if(HAVE_HTONL_SYMBOL)
                set(NEED_HTONL_PROTO 0 CACHE INTERNAL "")
            else()
                set(NEED_HTONL_PROTO 1 CACHE INTERNAL "")
            endif()
        endif()

        # NEED_HTONS_PROTO
        check_prototype_definition(htons
                "uint16_t htons(uint16_t hostshort)"
                "-1"
                "arpa/inet.h"
                HAVE_HTONS_PROTO)
        if(HAVE_HTONS_PROTO)
            set(NEED_HTONS_PROTO 0 CACHE INTERNAL "")
        else()
            # FreeBSD / macOS use a macro
            check_symbol_exists(htons "arpa/inet.h" HAVE_HTONS_SYMBOL)
            if(HAVE_HTONS_SYMBOL)
                set(NEED_HTONS_PROTO 0 CACHE INTERNAL "")
            else()
                set(NEED_HTONS_PROTO 1 CACHE INTERNAL "")
            endif()
        endif()

        # NEED_INET_ADDR_PROTO
        check_prototype_definition(inet_addr
                "in_addr_t inet_addr(const char *cp)"
                "-1"
                "sys/socket.h;arpa/inet.h"
                HAVE_INET_ADDR_PROTO)
        if(HAVE_INET_ADDR_PROTO)
            set(NEED_INET_ADDR_PROTO 0 CACHE INTERNAL "")
        else()
            set(NEED_INET_ADDR_PROTO 1 CACHE INTERNAL "")
        endif()

        # NEED_INET_ATON_PROTO
        check_prototype_definition(inet_aton
                "int inet_aton(const char *cp, struct in_addr *inp)"
                "-1"
                "sys/socket.h;arpa/inet.h"
                HAVE_INET_ATON_PROTO)
        if(HAVE_INET_ATON_PROTO)
            set(NEED_INET_ATON_PROTO 0 CACHE INTERNAL "")
        else()
            set(NEED_INET_ATON_PROTO 1 CACHE INTERNAL "")
        endif()

        # NEED_INET_NTOA_PROTO
        check_prototype_definition(inet_ntoa
                "char *inet_ntoa(struct in_addr in)"
                "-1"
                "sys/socket.h;arpa/inet.h"
                HAVE_INET_NTOA_PROTO)
        if(HAVE_INET_NTOA_PROTO)
            set(NEED_INET_NTOA_PROTO 0 CACHE INTERNAL "")
        else()
            set(NEED_INET_NTOA_PROTO 1 CACHE INTERNAL "")
        endif()

        # NEED_LISTEN_PROTO
        check_prototype_definition(listen
                "int listen(int sockfd, int backlog)"
                "-1"
                "sys/types.h;sys/socket.h"
                HAVE_LISTEN_PROTO)
        if(HAVE_LISTEN_PROTO)
            set(NEED_LISTEN_PROTO 0 CACHE INTERNAL "")
        else()
            set(NEED_LISTEN_PROTO 1 CACHE INTERNAL "")
        endif()

        # NEED_NTOHL_PROTO
        check_prototype_definition(ntohl
                "uint32_t ntohl(uint32_t netlong)"
                "0"
                "arpa/inet.h"
                HAVE_NTOHL_PROTO)
        if(HAVE_NTOHL_PROTO)
            set(NEED_NTOHL_PROTO 0 CACHE INTERNAL "")
        else()
            # FreeBSD / macOS use a macro
            check_symbol_exists(ntohl "arpa/inet.h" HAVE_NTOHL_SYMBOL)
            if(HAVE_NTOHL_SYMBOL)
                set(NEED_NTOHL_PROTO 0 CACHE INTERNAL "")
            else()
                set(NEED_NTOHL_PROTO 1 CACHE INTERNAL "")
            endif()
        endif()

        # NEED_PERROR_PROTO
        check_prototype_definition(perror
                "void perror(const char *s)"
                ""
                "stdio.h"
                HAVE_PERROR_PROTO)
        if(HAVE_PERROR_PROTO)
            set(NEED_PERROR_PROTO 0 CACHE INTERNAL "")
        else()
            set(NEED_PERROR_PROTO 1 CACHE INTERNAL "")
        endif()

        # NEED_PRINTF_PROTO
        check_prototype_definition(printf
                "int printf(const char *format, ...)"
                "-1"
                "stdio.h"
                HAVE_PRINTF_PROTO)
        if(HAVE_PRINTF_PROTO)
            set(NEED_PRINTF_PROTO 0 CACHE INTERNAL "")
        else()
            set(NEED_PRINTF_PROTO 1 CACHE INTERNAL "")
        endif()

        # NEED_QSORT_PROTO
        check_prototype_definition(qsort
                "void qsort(void *base, size_t nmemb, size_t size, int (*compar)(const void *, const void *))"
                ""
                "stdlib.h"
                HAVE_QSORT_PROTO)
        if(HAVE_QSORT_PROTO)
            set(NEED_QSORT_PROTO 0 CACHE INTERNAL "")
        else()
            set(NEED_QSORT_PROTO 1 CACHE INTERNAL "")
        endif()

        # NEED_READ_PROTO
        check_prototype_definition(read
                "ssize_t read(int fd, void *buf, size_t count)"
                "-1"
                "unistd.h"
                HAVE_READ_PROTO)
        if(HAVE_READ_PROTO)
            set(NEED_READ_PROTO 0 CACHE INTERNAL "")
        else()
            set(NEED_READ_PROTO 1 CACHE INTERNAL "")
        endif()

        # NEED_REMOVE_PROTO
        check_prototype_definition(remove
                "int remove(const char *pathname)"
                "-1"
                "stdio.h"
                HAVE_REMOVE_PROTO)
        if(HAVE_REMOVE_PROTO)
            set(NEED_REMOVE_PROTO 0 CACHE INTERNAL "")
        else()
            set(NEED_REMOVE_PROTO 1 CACHE INTERNAL "")
        endif()

        # NEED_REWIND_PROTO
        check_prototype_definition(rewind
                "void rewind(FILE *stream)"
                ""
                "stdio.h"
                HAVE_REWIND_PROTO)
        if(HAVE_REWIND_PROTO)
            set(NEED_REWIND_PROTO 0 CACHE INTERNAL "")
        else()
            set(NEED_REWIND_PROTO 1 CACHE INTERNAL "")
        endif()

        # NEED_SELECT_PROTO
        check_prototype_definition(select
                "int select(int nfds, fd_set *readfds, fd_set *writefds, fd_set *exceptfds, struct timeval *timeout)"
                "-1"
                "sys/select.h;sys/time.h;sys/types.h;unistd.h"
                HAVE_SELECT_PROTO)
        if(HAVE_SELECT_PROTO)
            set(NEED_SELECT_PROTO 0 CACHE INTERNAL "")
        else()
            set(NEED_SELECT_PROTO 1 CACHE INTERNAL "")
        endif()

        # NEED_SETTIMER_PROTO
        check_prototype_definition(setitimer
                "int setitimer(int which, const struct itimerval *new_value, struct itimerval *old_value)"
                "-1"
                "sys/time.h"
                HAVE_SETITIMER_PROTO)
        if(HAVE_SETITIMER_PROTO)
            set(NEED_SETITIMER_PROTO 0 CACHE INTERNAL "")
        else()
            set(NEED_SETITIMER_PROTO 1 CACHE INTERNAL "")
        endif()

        # NEED_SETRLIMIT_PROTO
        check_prototype_definition(setrlimit
                "int setrlimit(int resource, const struct rlimit *rlim)"
                "-1"
                "sys/time.h;sys/resource.h"
                HAVE_SETRLIMIT_PROTO)
        if(HAVE_SETRLIMIT_PROTO)
            set(NEED_SETRLIMIT_PROTO 0 CACHE INTERNAL "")
        else()
            set(NEED_SETRLIMIT_PROTO 1 CACHE INTERNAL "")
        endif()

        # NEED_SETSOCKOPT_PROTO
        check_prototype_definition(setsockopt
                "int setsockopt(int socket, int level, int option_name, const void *option_value, socklen_t option_len)"
                "-1"
                "sys/socket.h"
                HAVE_SETSOCKOPT_PROTO)
        if(HAVE_SETSOCKOPT_PROTO)
            set(NEED_SETSOCKOPT_PROTO 0 CACHE INTERNAL "")
        else()
            set(NEED_SETSOCKOPT_PROTO 1 CACHE INTERNAL "")
        endif()

        # NEED_SNPRINTF_PROTO
        check_prototype_definition(snprintf
                "int snprintf(char *str, size_t size, const char *format, ...)"
                "-1"
                "stdio.h"
                HAVE_SNPRINTF_PROTO)
        if(HAVE_SNPRINTF_PROTO)
            set(NEED_SNPRINTF_PROTO 0 CACHE INTERNAL "")
        else()
            set(NEED_SNPRINTF_PROTO 1 CACHE INTERNAL "")
        endif()

        # NEED_SOCKET_PROTO
        check_prototype_definition(socket
                "int socket(int domain, int type, int protocol)"
                "-1"
                "sys/types.h;sys/socket.h"
                HAVE_SOCKET_PROTO)
        if(HAVE_SOCKET_PROTO)
            set(NEED_SOCKET_PROTO 0 CACHE INTERNAL "")
        else()
            set(NEED_SOCKET_PROTO 1 CACHE INTERNAL "")
        endif()

        # NEED_SPRINTF_PROTO
        check_prototype_definition(sprintf
                "int sprintf(char *str, const char *format, ...)"
                "-1"
                "stdio.h"
                HAVE_SPRINTF_PROTO)
        if(HAVE_SPRINTF_PROTO)
            set(NEED_SPRINTF_PROTO 0 CACHE INTERNAL "")
        else()
            set(NEED_SPRINTF_PROTO 1 CACHE INTERNAL "")
        endif()

        # NEED_SSCANF_PROTO
        check_prototype_definition(sscanf
                "int sscanf(const char *str, const char *format, ...)"
                "-1"
                "stdio.h"
                HAVE_SSCANF_PROTO)
        if(HAVE_SSCANF_PROTO)
            set(NEED_SSCANF_PROTO 0 CACHE INTERNAL "")
        else()
            set(NEED_SSCANF_PROTO 1 CACHE INTERNAL "")
        endif()

        # NEED_STRCASECMP_PROTO
        check_prototype_definition(strcasecmp
                "int strcasecmp(const char *s1, const char *s2)"
                "-1"
                "strings.h"
                HAVE_STRCASECMP_PROTO)
        if(HAVE_STRCASECMP_PROTO)
            set(NEED_STRCASECMP_PROTO 0 CACHE INTERNAL "")
        else()
            set(NEED_STRCASECMP_PROTO 1 CACHE INTERNAL "")
        endif()

        # NEED_STRDUP_PROTO
        check_prototype_definition(strdup
                "char *strdup(const char *s)"
                "0"
                "string.h"
                HAVE_STRDUP_PROTO)
        if(HAVE_STRDUP_PROTO)
            set(NEED_STRDUP_PROTO 0 CACHE INTERNAL "")
        else()
            set(NEED_STRDUP_PROTO 1 CACHE INTERNAL "")
        endif()

        # NEED_STRERROR_PROTO
        check_prototype_definition(strerror
                "char *strerror(int errnum)"
                "0"
                "string.h"
                HAVE_STRERROR_PROTO)
        if(HAVE_STRERROR_PROTO)
            set(NEED_STRERROR_PROTO 0 CACHE INTERNAL "")
        else()
            set(NEED_STRERROR_PROTO 1 CACHE INTERNAL "")
        endif()

        # NEED_STRICMP_PROTO - TODO - removed in C99 / linux 4.0
        check_prototype_definition(stricmp
                "int stricmp (const char *s1, const char *s2)"
                "-1"
                "stdio.h;string.h"
                HAVE_STRICMP_PROTO)
        if(HAVE_STRICMP_PROTO)
            set(NEED_STRICMP_PROTO 0 CACHE INTERNAL "")
        else()
            set(NEED_STRICMP_PROTO 1 CACHE INTERNAL "")
        endif()

        # NEED_STRLCPY_PROTO - FreeBSD [prototype] / macOS [macro]
        check_prototype_definition(strlcpy
                "size_t strlcpy(char * restrict dst, const	char * restrict	src, size_t dstsize)"
                "0"
                "string.h"
                HAVE_STRLCPY_PROTO)
        if(HAVE_STRLCPY_PROTO)
            set(NEED_STRLCPY_PROTO 0 CACHE INTERNAL "")
        else()
            # macOS use a macro
            check_symbol_exists(strlcpy "string.h" HAVE_STRLCPY_SYMBOL)
            if(HAVE_STRLCPY_SYMBOL)
                set(NEED_STRLCPY_PROTO 0 CACHE INTERNAL "")
            else()
                set(NEED_STRLCPY_PROTO 1 CACHE INTERNAL "")
            endif()
        endif()

        # NEED_STRNCASECMP_PROTO
        check_prototype_definition(strncasecmp
                "int strncasecmp(const char *s1, const char *s2, size_t n)"
                "-1"
                "strings.h"
                HAVE_STRNCASECMP_PROTO)
        if(HAVE_STRNCASECMP_PROTO)
            set(NEED_STRNCASECMP_PROTO 0 CACHE INTERNAL "")
        else()
            set(NEED_STRNCASECMP_PROTO 1 CACHE INTERNAL "")
        endif()

        # NEED_SYSTEM_PROTO
        check_prototype_definition(system
                "int system(const char *command)"
                "-1"
                "stdlib.h"
                HAVE_SYSTEM_PROTO)
        if(HAVE_SYSTEM_PROTO)
            set(NEED_SYSTEM_PROTO 0 CACHE INTERNAL "")
        else()
            set(NEED_SYSTEM_PROTO 1 CACHE INTERNAL "")
        endif()

        # NEED_TIME_PROTO
        check_prototype_definition(time
                "time_t time(time_t *tloc)"
                "-1"
                "time.h"
                HAVE_TIME_PROTO)
        if(HAVE_TIME_PROTO)
            set(NEED_TIME_PROTO 0 CACHE INTERNAL "")
        else()
            set(NEED_TIME_PROTO 1 CACHE INTERNAL "")
        endif()

        # NEED_UNLINK_PROTO
        check_prototype_definition(unlink
                "int unlink(const char *pathname)"
                "-1"
                "unistd.h"
                HAVE_UNLINK_PROTO)
        if(HAVE_UNLINK_PROTO)
            set(NEED_UNLINK_PROTO 0 CACHE INTERNAL "")
        else()
            set(NEED_UNLINK_PROTO 1 CACHE INTERNAL "")
        endif()

        # NEED_VSNPRINTF_PROTO
        check_prototype_definition(vsnprintf
                "int vsnprintf(char *str, size_t size, const char *format, va_list ap)"
                "-1"
                "stdio.h;stdarg.h"
                HAVE_VSNPRINTF_PROTO)
        if(HAVE_VSNPRINTF_PROTO)
            set(NEED_VSNPRINTF_PROTO 0 CACHE INTERNAL "")
        else()
            set(NEED_VSNPRINTF_PROTO 1 CACHE INTERNAL "")
        endif()

        # NEED_WRITE_PROTO
        check_prototype_definition(write
                "ssize_t write(int fd, const void *buf, size_t count)"
                "-1"
                "unistd.h"
                HAVE_WRITE_PROTO)
        if(HAVE_WRITE_PROTO)
            set(NEED_WRITE_PROTO 0 CACHE INTERNAL "")
        else()
            set(NEED_WRITE_PROTO 1 CACHE INTERNAL "")
        endif()

    endif()

    # write conf.h
    configure_file(
            "${CMAKE_CURRENT_SOURCE_DIR}/src/conf.h.cmakein"
            "${CMAKE_CURRENT_SOURCE_DIR}/src/conf.h"
    )

    # check that it worked
    if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/src/conf.h")
        message(STATUS "conf.h generated")
        set(CONF_H_GENERATED 1 CACHE BOOL "conf.h built, set variable 0/OFF to rebuild")
    else()
        message(ERROR "conf.h failed")
    endif()
else()
    message(STATUS "conf.h already built")
endif()
