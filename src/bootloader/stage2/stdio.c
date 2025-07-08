#include "stdio.h"
#include "x86.h"
#include <stdint.h>
#include <stdarg.h>
#include <stdbool.h>

static const char hexChars[] = "0123456789abcdef";

#define PRINTF_STATE_NORMAL         0
#define PRINTF_STATE_LENGTH         1
#define PRINTF_STATE_LENGTH_SHORT   2
#define PRINTF_STATE_LENGTH_LONG    3
#define PRINTF_STATE_SPEC           4

#define PRINTF_LENGTH_DEFAULT       0
#define PRINTF_LENGTH_SHORT         1
#define PRINTF_LENGTH_SHORT_SHORT   2
#define PRINTF_LENGTH_LONG          3
#define PRINTF_LENGTH_LONG_LONG     4

void putc(char c)
{
    switch (c)
    {
    case '\n':
        putc('\r');
        goto PUTC_DEFAULT;
        break;
    case '\t':
        for (int i = 0; i < 4; i++)
            putc(' ');
        break;
    default:
    PUTC_DEFAULT:
        x86_Video_WriteCharTTY(c, 0);
    }
}

void puts(const char* str)
{
    while (*str)
    {
        putc(*str);
        str++;
    }
}

void puts_far(const char far* str)
{
    while (*str)
    {
        putc(*str);
        str++;
    }
}

void printf_unsigned(unsigned long long number, int base)
{
    char buffer[32];
    int pos = 0;

    // convert number to ASCII
    do
    {
        unsigned long long rem = number % base;
        buffer[pos++] = hexChars[rem];
        number /= base;
    } while (number > 0);
    
    // print number in reverse order
    while (--pos >= 0)
        putc(buffer[pos]);
}

void printf_signed(long long number, int base)
{
    if (number < 0)
    {
        putc('-');
        printf_unsigned(-number, base);
    }
    else printf_unsigned(number, base);
}


void printf(const char* fmt, ...)
{
    va_list args;
    va_start(args, fmt);
    int state = PRINTF_STATE_NORMAL;
    int length = PRINTF_LENGTH_DEFAULT;
    int base = 10;
    bool number = false;
    bool sign = false;

    while (*fmt)
    {
        switch (state)
        {
        case PRINTF_STATE_NORMAL:
            switch (*fmt)
            {
            case '%':
                state = PRINTF_STATE_LENGTH;
                break;
            default:
                putc(*fmt);
            }
            break;
        case PRINTF_STATE_LENGTH:
            switch (*fmt)
            {
            case 'h':
                state = PRINTF_STATE_LENGTH_SHORT;
                length = PRINTF_LENGTH_SHORT;
                break;
            case 'l':
                state = PRINTF_STATE_LENGTH_LONG;
                length = PRINTF_LENGTH_LONG;
                break;
            default:
                goto PRINTF_STATE_SPEC_;
            }
            break;
        case PRINTF_STATE_LENGTH_SHORT:
            if (*fmt == 'h')
            {
                state = PRINTF_STATE_SPEC;
                length = PRINTF_LENGTH_SHORT_SHORT;
            }
            else
                goto PRINTF_STATE_SPEC_;
            break;
        case PRINTF_STATE_LENGTH_LONG:
            if (*fmt == 'l')
            {
                state = PRINTF_STATE_SPEC;
                length = PRINTF_LENGTH_LONG_LONG;
            }
            else
                goto PRINTF_STATE_SPEC_;
            break;
        case PRINTF_STATE_SPEC:
        PRINTF_STATE_SPEC_:
            switch (*fmt)
            {
            case '%':
                putc('%');
                break;
            case 'c':
                putc((char)va_arg(args, int));
                break;
            case 's':
                if (length == PRINTF_LENGTH_LONG || length == PRINTF_LENGTH_LONG_LONG)
                    puts_far(va_arg(args, const char far*));
                else
                    puts(va_arg(args, const char*));
                break;
            case 'd':
            case 'i':
                number = true;
                base = 10;
                sign = true;
                break;
            case 'u':
                number = true;
                base = 10;
                sign = false;
                break;
            case 'X':
            case 'x':
            case 'p':
                number = true;
                base = 16;
                sign = false;
                break;
            case 'o':
                number = true;
                base = 8;
                sign = false;
                break;
            }

            if (number)
            {
                if (sign)
                {
                    switch (length)
                    {
                    case PRINTF_LENGTH_DEFAULT:
                    case PRINTF_LENGTH_SHORT:
                    case PRINTF_LENGTH_SHORT_SHORT:
                        printf_signed(va_arg(args, int), base);
                        break;
                    case PRINTF_LENGTH_LONG:
                        printf_signed(va_arg(args, long), base);
                        break;
                    case PRINTF_LENGTH_LONG_LONG:
                        printf_signed(va_arg(args, long long), base);
                        break;
                    }
                }
                else
                {
                    switch (length)
                    {
                    case PRINTF_LENGTH_DEFAULT:
                    case PRINTF_LENGTH_SHORT:
                    case PRINTF_LENGTH_SHORT_SHORT:
                        printf_unsigned(va_arg(args, unsigned int), base);
                        break;
                    case PRINTF_LENGTH_LONG:
                        printf_unsigned(va_arg(args, unsigned long), base);
                        break;
                    case PRINTF_LENGTH_LONG_LONG:
                        printf_unsigned(va_arg(args, unsigned long long), base);
                        break;
                    }
                }
            }

            state = PRINTF_STATE_NORMAL;
            length = PRINTF_LENGTH_DEFAULT;
            base = 10;
            number = false;
            sign = false;
            break;
        }

        fmt++;
    }

    va_end(args);
}