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

#define ESC "\033"

#define CSI ESC "["

volatile int rows, cols;

struct termios original, changed;

void measure_screen()
{
    struct winsize winsz;
    ioctl(0, TIOCGWINSZ, &winsz);
    rows = winsz.ws_row;
    cols = winsz.ws_col;
}

void sig_handler(int signal)
{
    (void)signal;
    printf(CSI "?25h");
    tcsetattr(STDIN_FILENO, TCSANOW, &original);
    exit(0);
}

void move(int row, int column)
{
    printf(CSI "%d;%dH", row, column);
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

int main()
{
    tcgetattr(STDIN_FILENO, &original);
    changed = original;
    changed.c_lflag &= ~(ICANON | ECHO);
    changed.c_cc[VMIN] = 1;
    changed.c_cc[VTIME] = 0;
    tcsetattr(STDIN_FILENO, TCSANOW, &changed);

    signal(SIGINT, sig_handler);
    signal(SIGTERM, sig_handler);

    setbuf(stdout, NULL);

    measure_screen();

    printf(CSI "2J");
    printf(CSI "3J");
    printf(CSI "?25l");

    for (float l = 0;; l = fmod(l + 1. / 360, 2))
    {
        move(1, 1);
        for (int y = 1; y <= rows; y++)
        {
            for (int x = 1; x <= cols; x++)
            {
                // move(y, x);

                float dy = rows / 2 - y;
                float dx = cols / 2 - x;
                float angle = fmod(atan2(dy, dx) / M_PI + 1 + l, 2);
                float distance = sqrt(dx * dx + dy * dy);

                float h = angle * 180;
                float l = distance * 2 / sqrt(rows * rows + cols * cols);

                set_bg_rgb(rgb(h, 1, l));

                printf(" ");
            }
        }

        usleep(1000 * 1000 / 60);
    }
}
