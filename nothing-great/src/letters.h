#pragma once

#define LETTER_HEIGHT 7
#define LETTER_WIDTH 5

typedef char letter[LETTER_HEIGHT][LETTER_WIDTH + 1];

letter LETTER_N = {
    {"X   X"},
    {"X   X"},
    {"XX  X"},
    {"X X X"},
    {"X  XX"},
    {"X   X"},
    {"X   X"}};

letter LETTER_O = {
    {"XXXXX"},
    {"X   X"},
    {"X   X"},
    {"X   X"},
    {"X   X"},
    {"X   X"},
    {"XXXXX"}};

letter LETTER_T = {
    {"XXXXX"},
    {"  X  "},
    {"  X  "},
    {"  X  "},
    {"  X  "},
    {"  X  "},
    {"  X  "}};

letter LETTER_H = {
    {"X   X"},
    {"X   X"},
    {"X   X"},
    {"XXXXX"},
    {"X   X"},
    {"X   X"},
    {"X   X"}};

letter LETTER_I = {
    {"  X  "},
    {"  X  "},
    {"  X  "},
    {"  X  "},
    {"  X  "},
    {"  X  "},
    {"  X  "}};

letter LETTER_G = {
    {"XXXXX"},
    {"X   X"},
    {"X    "},
    {"X XXX"},
    {"X  X "},
    {"X  X "},
    {"XXXX "}};
