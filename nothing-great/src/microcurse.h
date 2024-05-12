#pragma once

#include <math.h>
#include <stdio.h>

// ANSI escape sequences
#define ESC "\033"
#define CSI ESC "["

#define BLACK 0

volatile int rows, cols;

void measure_screen()
{
    struct winsize winsz;
    ioctl(0, TIOCGWINSZ, &winsz);
    rows = winsz.ws_row;
    cols = winsz.ws_col;
}

// Positioning
void move(int row, int column)
{
    printf(CSI "%d;%dH", row + 1, column + 1);
}

void save_cursor_position()
{
    printf(CSI "s");
}

void restore_cursor_position()
{
    printf(CSI "u");
}

void clear_screen()
{
    printf(CSI "2J");
}

void hide_cursor()
{
    printf(CSI "?25l");
}

void show_cursor()
{
    printf(CSI "?25h");
}

void set_fg(int r, int g, int b)
{
    printf(CSI "38;2;%d;%d;%dm", r, g, b);
}

void set_bg(int r, int g, int b)
{
    printf(CSI "48;2;%d;%d;%dm", r, g, b);
}

void set_bg_rgb(int rgb)
{
    set_bg(rgb >> 16, (rgb >> 8) & 0xff, rgb & 0xff);
}

int hsl_to_rgb(float h, float s, float l)
{
    float c = (1 - fabs(2 * l - 1)) * s;
    float x = c * (1 - fabs(fmod(h / 60, 2) - 1));
    float m = l - c / 2;
    float r_p, g_p, b_p;
    switch ((int)(h / 60))
    {
    case 0:
        r_p = c;
        g_p = x;
        b_p = 0;
        break;
    case 1:
        r_p = x;
        g_p = c;
        b_p = 0;
        break;
    case 2:
        r_p = 0;
        g_p = c;
        b_p = x;
        break;
    case 3:
        r_p = 0;
        g_p = x;
        b_p = c;
        break;
    case 4:
        r_p = x;
        g_p = 0;
        b_p = c;
        break;
    default:
        r_p = c;
        g_p = 0;
        b_p = x;
        break;
    }

    int r = (int)(255 * (r_p + m));
    int g = (int)(255 * (g_p + m));
    int b = (int)(255 * (b_p + m));
    return r << 16 | g << 8 | b;
}
