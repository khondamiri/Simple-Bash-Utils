#ifndef S21_GREP_H
#define S21_GREP_H

#define MAX_ARGS 100

#define _GNU_SOURCE
#include <getopt.h>
#include <regex.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

typedef struct {
  int regex_flag;
  bool invert, count, fileMatch, lineNumbers, multiExpressions;
  bool noError, lineAsExpression, onlyMatches, noFileName;
} FLAGS;

void grepBasic(int argc, char *argv[], FLAGS flags);
void grepFile(int argc, char *argv[], FLAGS flags, const char *patternFileName);
void grepMulti(int argc, char *argv[], FLAGS flags, char *expv[], int *expc);
void performGrep(FILE *file, FLAGS flags, char *fileName, regex_t *preg,
                 int patternCount, int multipleFiles);
void fileMatch(FILE *file, const char *fileName, regex_t *preg,
               int patternCount, int *printed);
FLAGS readFlags(int argc, char *argv[], char *expv[], int *expc,
                char **patternFileName);

// int count(FILE *file, FLAGS flags, regex_t *preg);

#endif