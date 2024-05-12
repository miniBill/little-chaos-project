#pragma once

#include <stddef.h>

#define LETTER_HEIGHT 7
#define LETTER_WIDTH 5

typedef wchar_t *letter[];

letter LETTER_A = {
    L"▟███▙",
    L"█   █",
    L"█   █",
    L"▟███▙",
    L"█   █",
    L"█   █",
    L"█   █"};

letter LETTER_E = {
    L"▟███▙",
    L"█    ",
    L"█    ",
    L"▝███▙",
    L"█    ",
    L"█    ",
    L"▜███▙"};

letter LETTER_G = {
    L"▟███▖",
    L"█   ▜",
    L"█    ",
    L"█  ▄▄",
    L"█  ▐▌",
    L"█  ▐▌",
    L"▜███▘"};

letter LETTER_H = {
    L"▙   ▟",
    L"█   █",
    L"█   █",
    L"█████",
    L"█   █",
    L"█   █",
    L"▛   ▜"};

letter LETTER_I = {
    L" ▙   ",
    L" █   ",
    L" █   ",
    L" █   ",
    L" █   ",
    L" █   ",
    L" ▜   "};

letter LETTER_N = {
    L"▙   ▟",
    L"█▖  █",
    L"██▖ █",
    L"█▝█▖█",
    L"█ ▝██",
    L"█  ▝█",
    L"▛   ▜"};

letter LETTER_O = {
    L"▟███▙",
    L"█   █",
    L"█   █",
    L"█   █",
    L"█   █",
    L"█   █",
    L"▜███▛"};

letter LETTER_R = {
    L"▟███▙",
    L"█   █",
    L"█   █",
    L"████▘",
    L"█   █",
    L"█   █",
    L"▛   ▜"};

letter LETTER_T = {
    L"▟██▙ ",
    L" ▐▌  ",
    L" ▐▌  ",
    L" ▐▌  ",
    L" ▐▌  ",
    L" ▐▌  ",
    L" ▝▌  "};

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
