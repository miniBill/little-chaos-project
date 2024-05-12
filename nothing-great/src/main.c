#include <ctype.h>
#include <math.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <termios.h>
#include <time.h>
#include <unistd.h>

#define ESC "\033"

#define CSI ESC "["

struct termios original, changed;

void term(int signal)
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

int main()
{
    tcgetattr(STDIN_FILENO, &original);
    changed = original;
    changed.c_lflag &= ~(ICANON | ECHO);
    changed.c_cc[VMIN] = 1;
    changed.c_cc[VTIME] = 0;
    tcsetattr(STDIN_FILENO, TCSANOW, &changed);

    signal(SIGINT, term);
    signal(SIGTERM, term);
    setbuf(stdout, NULL);

    printf(CSI "9999;9999H"); // cursor should move as far as it can

    printf(CSI "6n"); // ask for cursor position
    char ch;
    char in[100] = "";
    int each = 0;
    while ((ch = getchar()) != 'R')
    { // R terminates the response
        if (EOF == ch)
        {
            break;
        }
        if (isprint(ch))
        {
            if (each + 1 < 100)
            {
                in[each] = ch;
                each++;
                in[each] = '\0';
            }
        }
    }

    move(1, 1);
    int rows, cols;
    if (2 != sscanf(in, "[%d;%d", &rows, &cols))
    {
        raise(SIGTERM);
    }

    printf(CSI "2J");
    printf(CSI "3J");
    printf(CSI "?25l");

    for (int l = 0;; l = (l + 10) % 512)
    {
        for (int y = 1; y <= rows; y++)
        {
            for (int x = 1; x <= cols; x++)
            {
                move(y, x);
                int r = (y - 1) * 255 / (rows - 1);
                int g = abs(l - 256);
                int b = (x - 1) * 255 / (cols - 1);
                set_fg(r, g, b);
                set_bg(r, g, b);
                printf("X");
            }
        }

        usleep(1000 * 1000 / 60);
    }

    return pause();
}
