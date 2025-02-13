#ifndef S21_CAT_H
#define S21_CAT_H

#include <ctype.h>
#include <getopt.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void cat(const char* filePath, int bFlag, int eFlag, int vFlag, int nFlag,
         int sFlag, int tFlag);
int isBinaryFile(const char* fileName);

#endif