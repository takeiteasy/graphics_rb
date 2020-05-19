#ifndef TIME_H
#define TIME_H
#if defined(__gnu_linux__) || defined(__linux__) || defined(__unix__)
#define TIME_LINUX
#elif defined(macintosh) || defined(Macintosh) || (defined(__APPLE__) && defined(__MACH__))
#define TIME_OSX
#elif defined(_WIN32) || defined(_WIN64) || defined(__WIN32__) || defined(__WINDOWS__)
#define TIME_WINDOWS
#else
#define TIME_NO_WINDOW
#endif
#if defined(__cplusplus)
extern "C" {
#endif

long long ticks(void);

#if defined(__cplusplus)
}
#endif
#endif