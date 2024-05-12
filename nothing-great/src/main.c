#include <ctype.h>
#include <errno.h>
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

#define BG_COLOR 0xc0e0e0

float current_time = 0;

int color_at(int y, int x)
{
    float dy = (float)rows / 2 - y;
    float dx = (float)cols / 2 - x;
    float raw_angle = (float)x / rows + 2.5 * (float)y / cols + 2 * current_time;
    // float raw_angle = atan2(dy, dx) / PI + 1;
    float angle = fmod(raw_angle, 2); // [0, 2]
    float distance = sqrt(dx * dx + dy * dy);

    float h = fabs(angle - 1) * 120 + 120; //[100, 160];
    float l = distance * 2 / sqrt(rows * rows + cols * cols);
    l = l / 3.0 + 0.275;
    // return hsl_to_rgb(h, 1, l);

    return hsl_to_rgb(h, 0.8, l);
}

void letter_at(int y, int x, char c)
{
    letter *letter = char_to_letter(c);
    if (letter == 0)
    {
        return;
    }

    for (int ly = 0; ly < LETTER_HEIGHT; ly++)
    {
        move(y + ly, x);
        for (int lx = 0; lx < LETTER_WIDTH; lx++)
        {
            int color = color_at(y + ly, x + lx);
            set_fg_rgb(color);
            wchar_t str[2] = {(*letter)[ly][lx], 0};
            printf("%ls", str);
        }
    }
}

void write_at(int y, int x, int spacing, char *string)
{
    int len = strlen(string);
    for (int i = 0, dx = 0; i < len; i++)
    {
        letter_at(y, x + dx, string[i]);
        switch (string[i])
        {
        case 'i':
            dx += 3 + spacing;
            break;
        case 't':
            dx += 4 + spacing;
            break;
        default:
            dx += LETTER_WIDTH + spacing;
            break;
        }
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

void setup_terminal(void)
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
        return;
    }

    show_cursor();
    restore_cursor_position();

    // Restore the original terminal settings
    tcsetattr(STDIN_FILENO, TCSANOW, &original);

    exit(0);
}

void set_signals(void)
{
    struct sigaction action = {0};
    action.sa_handler = sig_handler;
    if (sigaction(SIGINT, &action, 0) == -1)
    {
        perror("sigaction(SIGINT, &action, 0)");
        exit(EXIT_FAILURE);
    }
    if (sigaction(SIGTERM, &action, 0) == -1)
    {
        perror("sigaction(SIGTERM, &action, 0)");
        exit(EXIT_FAILURE);
    }
    if (sigaction(SIGWINCH, &action, 0) == -1)
    {
        perror("sigaction(SIGWINCH, &action, 0)");
        exit(EXIT_FAILURE);
    }
}

void draw_rings(void)
{
    char little_chaos[] = "Nothing Great "; // "Little Chaos ";
    int len = strlen(little_chaos);

    int shift = current_time * 10;
    while (shift > 0)
        shift -= len;

    for (int ring = 1; ring < 4; ring += 2)
    {
        int i = -shift;

        for (int y = rows - ring - 1; y > ring; y--)
        {
            move(y, ring);
            printf("%c", little_chaos[i++ % len]);
        }

        for (int x = ring; x < cols - ring; x++)
        {
            move(ring, x);
            printf("%c", little_chaos[i++ % len]);
        }

        for (int y = ring + 1; y < rows - ring - 1; y++)
        {
            move(y, cols - ring - 1);
            printf("%c", little_chaos[i++ % len]);
        }

        for (int x = cols - ring - 1; x > ring; x--)
        {
            move(rows - ring - 1, x);
            // if (x == ring + 1)
            //     printf(" ");
            // else
            printf("%c", little_chaos[i++ % len]);
        }
    }
}

int main()
{
    set_signals();

    setup_terminal();

    measure_screen();

    while (1)
    {
        clear_with_color(BG_COLOR);

        current_time += 1. / 60;

        draw_rings();

        int topx = cols / 2 - (LETTER_WIDTH + 1) * strlen("nothing") / 2 + 1; //+1 is the 'i'
        int bottomx = cols / 2 - (LETTER_WIDTH + 2) * strlen("great") / 2;

        write_at(rows / 2 - LETTER_HEIGHT, topx, 1, "nothing");
        write_at(rows / 2 + 1, bottomx, 2, "great");

        usleep(1000 * 1000 / 60); // Very approximately 60 fps
    }
}
