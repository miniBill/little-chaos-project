#include <ctype.h>
#include <math.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/ioctl.h>
#include <termios.h>
#include <time.h>
#include <unistd.h>

#include "letters.h"

// ANSI escape sequences
#define ESC "\033"
#define CSI ESC "["

// This is just to work around a bug in the VScode LSP
#define PI 3.14159265358979323846

#define BLACK 0

volatile int rows, cols;
float current_time = 0;

void measure_screen()
{
    struct winsize winsz;
    ioctl(0, TIOCGWINSZ, &winsz);
    rows = winsz.ws_row;
    cols = winsz.ws_col;
}

void move(int row, int column)
{
    printf(CSI "%d;%dH", row + 1, column + 1);
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

int rgb(float h, float s, float l)
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

int color_at(int y, int x)
{
    float dy = (float)rows / 2 - y;
    float dx = (float)cols / 2 - x;
    float angle = fmod(atan2(dy, dx) / PI + 1 + current_time, 2);
    float distance = sqrt(dx * dx + dy * dy);

    float h = angle * 180;
    float l = distance * 2 / sqrt(rows * rows + cols * cols);
    return rgb(h, 1, l);
}

void letter_at(int y, int x, letter letter)
{
    move(y, x);
    for (int ly = 0; ly < LETTER_HEIGHT; ly++)
    {
        for (int lx = 0; lx < LETTER_WIDTH; lx++)
        {
            int color = color_at(y + ly, x + lx);
            if (letter[ly][lx] == ' ')
                set_bg_rgb(BLACK);
            else
                set_bg_rgb(color);
            printf(" ");
        }
        move(y + ly, x);
    }
}

int char_to_letter(char c, letter **result)
{
#define char_to_letter_l(l, u) \
    case l:                    \
        *result = &u;          \
        return 1;
    switch (c)
    {
        char_to_letter_l('g', LETTER_G);
        char_to_letter_l('h', LETTER_H);
        char_to_letter_l('i', LETTER_I);
        char_to_letter_l('n', LETTER_N);
        char_to_letter_l('o', LETTER_O);
        char_to_letter_l('t', LETTER_T);
    }
    return 0;
#undef char_to_letter_l
}

void write_at(int y, int x, char *string)
{
    int len = strlen(string);
    for (int i = 0; i < len; i++)
    {
        letter *letter;
        if (char_to_letter(string[i], &letter))
            letter_at(y, x + i * (LETTER_WIDTH + 1), *letter);
    }
}

void clear_with_color(int rgb)
{
    move(0, 0);
    set_bg_rgb(rgb);
    for (int y = 0; y < rows; y++)
        for (int x = 0; x < cols; x++)
            printf(" ");
}

struct termios original, changed;

void setup_terminal()
{
    // Set the terminal to non-canonical, no echo
    tcgetattr(STDIN_FILENO, &original);
    changed = original;
    changed.c_lflag &= ~(ICANON | ECHO);
    changed.c_cc[VMIN] = 1;
    changed.c_cc[VTIME] = 0;
    tcsetattr(STDIN_FILENO, TCSANOW, &changed);

    // disable stdout buffering
    setbuf(stdout, NULL);

    printf(CSI "s");    // save cursor position
    printf(CSI "2J");   // clear screen
    printf(CSI "3J");   // clear backscroll
    printf(CSI "?25l"); // hide cursor
}

void sig_handler(int signal)
{
    (void)signal; // value of `signal` is ignored

    printf(CSI "?25h"); // show cursor
    printf(CSI "u");    // restore cursor position

    // Restore the original terminal settings
    tcsetattr(STDIN_FILENO, TCSANOW, &original);

    exit(0);
}

int main()
{
    signal(SIGINT, sig_handler);
    signal(SIGTERM, sig_handler);

    setup_terminal();

    measure_screen();

    clear_with_color(BLACK);

    while (1)
    {
        current_time = fmod(current_time + 1. / 360, 2);

        write_at(2, 2, "nothing");

        usleep(1000 * 1000 / 60); // Very approximately 60 fps
    }
}
