#include <ctype.h>
#include <locale.h>
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
#include "microcurse.h"

// This is just to work around a bug in the VScode LSP
#define PI 3.14159265358979323846

#define BG_COLOR 0xe0e0e0

float current_time = 0;

int color_at(int y, int x)
{
    float dy = (float)rows / 2 - y;
    float dx = (float)cols / 2 - x;
    float angle = fmod(atan2(dy, dx) / PI + 1 + current_time, 2);
    float distance = sqrt(dx * dx + dy * dy);

    float h = angle * 180;
    float l = distance * 2 / sqrt(rows * rows + cols * cols);
    l = 0.3;
    return hsl_to_rgb(h, 1, l);
}

void letter_at(int y, int x, letter letter)
{
    for (int ly = 0; ly < LETTER_HEIGHT; ly++)
    {
        move(y + ly, x);
        for (int lx = 0; lx < LETTER_WIDTH; lx++)
        {
            int color = color_at(y + ly, x + lx);
            set_fg_rgb(color);
            wchar_t str[2] = {letter[ly][lx], 0};
            printf("%ls", str);
        }
    }
}

letter *char_to_letter(char c)
{
    switch (c)
    {
    case 'a':
        return &LETTER_A;
    case 'e':
        return &LETTER_E;
    case 'g':
        return &LETTER_G;
    case 'h':
        return &LETTER_H;
    case 'i':
        return &LETTER_I;
    case 'n':
        return &LETTER_N;
    case 'o':
        return &LETTER_O;
    case 'r':
        return &LETTER_R;
    case 't':
        return &LETTER_T;
    default:
        return 0;
    }
}

void write_at(int y, int x, char *string)
{
    int len = strlen(string);
    for (int i = 0; i < len; i++)
    {
        letter *letter;
        if ((letter = char_to_letter(string[i])) != 0)
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

    setlocale(LC_ALL, "");

    save_cursor_position();
    clear_screen();
    hide_cursor();
}

void sig_handler(int signal)
{
    if (signal == SIGWINCH)
    {
        measure_screen();
        clear_with_color(BG_COLOR);
        return;
    }

    show_cursor();
    restore_cursor_position();

    // Restore the original terminal settings
    tcsetattr(STDIN_FILENO, TCSANOW, &original);

    exit(0);
}

int main()
{
    struct sigaction action = {0};
    action.sa_handler = sig_handler;
    sigaction(SIGINT, &action, 0);
    sigaction(SIGTERM, &action, 0);
    sigaction(SIGWINCH, &action, 0);

    setup_terminal();

    measure_screen();

    clear_with_color(BG_COLOR);

    while (1)
    {
        current_time = fmod(current_time + 1. / 60, 2);

        write_at(rows / 2 - LETTER_HEIGHT, cols / 2 - (LETTER_WIDTH + 1) * strlen("nothing") / 2, "nothing");
        write_at(rows / 2 + 1, cols / 2 - (LETTER_WIDTH + 1) * strlen("great") / 2, "great");

        usleep(1000 * 1000 / 60); // Very approximately 60 fps
    }
}
