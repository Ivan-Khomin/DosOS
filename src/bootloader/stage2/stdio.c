#include "stdio.h"
#include "x86.h"
#include <stdint.h>
#include <stdarg.h>
#include <stdbool.h>

static uint8_t* screenBuffer = (uint8_t*)0xB8000;
static const unsigned SCREEN_WIDTH = 80;
static const unsigned SCREEN_HEIGHT = 25;
static const uint8_t DEFAULT_COLOR = 0x07;
static int screenX, screenY = 0;

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

void putchar(int x, int y, char c)
{
    screenBuffer[2 * (y * SCREEN_WIDTH + x)] = c;
}

void putcolor(int x, int y, uint8_t color)
{
    screenBuffer[2 * (y * SCREEN_WIDTH + x) + 1] = color;
}

char getchar(int x, int y)
{
    return screenBuffer[2 * (y * SCREEN_WIDTH + x)];
}

uint8_t getcolor(int x, int y)
{
    return screenBuffer[2 * (y * SCREEN_WIDTH + x) + 1];
}

void setcursor(int x, int y)
{
    uint16_t pos = y * SCREEN_WIDTH + x;

    x86_outb(0x3D4, 0x0F);
    x86_outb(0x3D5, (uint8_t)(pos & 0xFF));
    x86_outb(0x3D4, 0x0E);
    x86_outb(0x3D5, (uint8_t)((pos >> 8) & 0xFF));
}

void clrscr()
{
    for (int y = 0; y < SCREEN_HEIGHT; y++)
        for (int x = 0; x < SCREEN_WIDTH; x++)
        {
            putchar(x, y, '\0');
            putcolor(x, y, DEFAULT_COLOR);
        }

    screenX, screenY = 0;
    setcursor(screenX, screenY);
}

void scrollback(int lines)
{
    for (int y = lines; y < SCREEN_HEIGHT; y++)
        for (int x = 0; x < SCREEN_WIDTH; x++)
        {
            putchar(x, y - lines, getchar(x, y));
            putcolor(x, y - lines, getcolor(x, y));
        }

    for (int y = SCREEN_HEIGHT - lines; y < SCREEN_HEIGHT; y++)
        for (int x = 0; x < SCREEN_WIDTH; x++)
        {
            putchar(x, y, '\0');
            putcolor(x, y, DEFAULT_COLOR);
        }

    screenY -= lines;
}

void putc(char c)
{
    switch (c)
    {
    case '\n':
        screenX = 0;
        screenY++;
        break;
    case '\r':
        screenX = 0;
        break;
    case '\t':
        for (int i = 0; i < 4 - (screenX % 4); i++)
            putc(' ');
        break;
    default:
        putchar(screenX, screenY, c);
        screenX++;
    }

    if (screenX >= SCREEN_WIDTH)
    {
        screenX = 0;
        screenY++;
    }
    if (screenY >= SCREEN_HEIGHT)
        scrollback(1);

    setcursor(screenX, screenY);
}

void puts(const char* str)
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
            default: putc(*fmt);
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
            default: goto PRINTF_STATE_SPEC_;
            }
            break;
        case PRINTF_STATE_LENGTH_SHORT:
            if (*fmt == 'h')
            {
                state = PRINTF_STATE_SPEC;
                length = PRINTF_LENGTH_SHORT_SHORT;
            }
            else goto PRINTF_STATE_SPEC_;
            break;
        case PRINTF_STATE_LENGTH_LONG:
            if (*fmt == 'l')
            {
                state = PRINTF_STATE_SPEC;
                length = PRINTF_LENGTH_LONG_LONG;
            }
            else goto PRINTF_STATE_SPEC_;
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