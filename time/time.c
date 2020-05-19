#include "time.h"

#if defined(TIME_OSX)
#include <mach/mach_time.h>
static mach_timebase_info_data_t info;
#elif defined(TIME_WINDOWS)
#define WIN32_LEAN_AND_MEAN
#include <windows.h>
static LARGE_INTEGER freq;
#else
#define HAVE_POSIX_TIMER
#include <time.h>
#ifdef CLOCK_MONOTONIC
#define CLOCKID CLOCK_MONOTONIC
#else
#define CLOCKID CLOCK_REALTIME
#endif
static struct timespec ts;
#endif
static int is_started = 0;

long long ticks() {
  if (!is_started) {
#if defined(TIME_OSX)
    mach_timebase_info(&info);
#elif defined(TIME_WINDOWS)
    QueryPerformanceFrequency(&freq);
#else
    clock_getres(CLOCKID, &ts);
#endif
    is_started = 1;
  }
  
#if defined(TIME_OSX)
  return (long long)((mach_absolute_time() * info.numer) / info.denom);
#elif defined(TIME_WINDOWS)
  LARGE_INTEGER now;
  QueryPerformanceCounter(&now);
  return (long long)((1e9 * now.QuadPart)  / freq.QuadPart);
#else
  struct timespec tts
  clock_gettime(CLOCKID, &tts);
  return (long long)(tts.tv_sec * 1.0e9 + tts.tv_nsec)
#endif
}