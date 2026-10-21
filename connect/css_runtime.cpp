// Runtime helpers needed by the current CSS SDK's static libraries on Linux x86.
// This file is included by extension.cpp so it shares the SDK's declarations.
#if defined(__linux__) && !defined(__x86_64__)
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>

extern "C" struct tm *Plat_localtime(const time_t *timep, struct tm *result)
{
    return localtime_r(timep, result);
}

void ConColorMsg(const Color &color, const char *format, ...)
{
    (void)color;
    va_list arguments;
    va_start(arguments, format);
    vfprintf(stdout, format, arguments);
    va_end(arguments);
    fflush(stdout);
}

void ConMsg(const char *format, ...)
{
    va_list arguments;
    va_start(arguments, format);
    vfprintf(stdout, format, arguments);
    va_end(arguments);
    fflush(stdout);
}

extern "C" void Warning(const char *format, ...)
{
    va_list arguments;
    va_start(arguments, format);
    vfprintf(stderr, format, arguments);
    va_end(arguments);
    fflush(stderr);
}

extern "C" void Error(const char *format, ...)
{
    va_list arguments;
    va_start(arguments, format);
    vfprintf(stderr, format, arguments);
    va_end(arguments);
    fflush(stderr);
    abort();
}
#endif
