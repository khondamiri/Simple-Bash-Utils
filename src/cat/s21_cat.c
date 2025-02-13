#include "s21_cat.h"

int main(int argc, char* argv[]) {
  int bFlag = 0, eFlag = 0, vFlag = 0;
  int nFlag = 0, sFlag = 0, tFlag = 0;

  struct option long_options[] = {{"number-nonblank", no_argument, &bFlag, 1},
                                  {"number", no_argument, &nFlag, 1},
                                  {"squeeze-blank", no_argument, &sFlag, 1},
                                  {0, 0, 0, 0}};

  int c;
  int option_index = 0;

  while ((c = getopt_long(argc, argv, "beEvnstT", long_options,
                          &option_index)) != -1) {
    switch (c) {
      case 0:
        if (long_options[option_index].flag != 0) {
          printf("long option\n");
          break;
        }
        printf("option %s", long_options[option_index].name);
        if (optarg) printf(" with arg %s", optarg);
        printf("\n");
        break;

      case 'b':
        bFlag = 1;
        break;
      case 'e':
        eFlag = 1;
        break;
      case 'v':
        vFlag = 1;
        break;
      case 'n':
        nFlag = 1;
        break;
      case 's':
        sFlag = 1;
        break;
      case 't':
        tFlag = 1;
        break;
      case '?':
        fprintf(stderr, "illegal option: -%d\n", optopt);
        return 1;
    }
  }

  for (int i = optind; i < argc; i++) {
    cat(argv[i], bFlag, eFlag, vFlag, nFlag, sFlag, tFlag);
    if (argc - 1 > i) printf("\n");
  }
  return 0;
}

void cat(const char* filePath, int bFlag, int eFlag, int vFlag, int nFlag,
         int sFlag, int tFlag) {
  bool binaryMode = false;
  FILE* file = fopen(filePath, "rb");

  if (!file) {
    perror("filePath");
    return;
  }

  if (isBinaryFile(filePath)) {
    binaryMode = true;
  }

  int previousBlank = 0;
  int lineNumber = 1;
  int lineStart = 1;
  int prevCh = '\n';
  int ch;

  while ((ch = fgetc(file)) != EOF) {
    if (sFlag && ch == '\n' && prevCh == '\n') {
      previousBlank++;
      if (previousBlank > 1) {
        prevCh = ch;
        continue;
      }
    } else {
      previousBlank = 0;
    }

    if (lineStart) {
      if (nFlag && !bFlag) {
        printf("%6d\t", lineNumber++);
      } else if (bFlag && ch != '\n') {
        printf("%6d\t", lineNumber++);
      } /*else if (bFlag && ch == '\n' && eFlag) {
        printf("%6s\t", "");
      }*/ // this is for MacOS based cat
      lineStart = 0;
    }

    if (ch == '\n') {
      lineStart = 1;
      if (eFlag) {
        printf("$");
      }
      putchar(ch);
    } else {
      if (vFlag) {
        if (ch == '\t') {
          printf("^I");
        } else if (ch == 127) {
          printf("^?");
        } else if (ch < 32) {
          printf("^%c", ch + 64);
        } else if (ch > 127) {
          printf("M-%c", ch & 127);
        } else {
          putchar(ch);
        }
      } else if (binaryMode && (eFlag || tFlag)) {
        if (ch < 32) {
          printf("^%c", ch + 64);
        } else if (ch > 127) {
          printf("M-%c", ch & 127);
        } else {
          putchar(ch);
        }
      } else if (tFlag && ch == '\t') {
        printf("^I");
      } else {
        putchar(ch);
      }
    }
    prevCh = ch;
  }
  fclose(file);
}

int isBinaryFile(const char* fileName) {
  const char* dot = strrchr(fileName, '.');
  if (!strcmp((dot + 1), "bin")) return 1;
  return 0;
}

// -- backup --
/* line by line
void cat(const char* filePath, int bFlag, int eFlag, int vFlag, int nFlag,
         int sFlag, int tFlag) {
  FILE* file = fopen(filePath, "rb");

  if (file == NULL) {
    perror("filePath");
    return;
  }

  int previousBlank = 0;
  char line[1024];
  int lineNumber = 1;

  char* currentLine = fgets(line, sizeof(line), file);

  while (currentLine != NULL) {
    if (sFlag && strlen(line) == 1 && line[0] == '\n') {
      if (previousBlank) {
        currentLine = fgets(line, sizeof(line), file);
        continue;
      }
      previousBlank = 1;
    } else {
      previousBlank = 0;
    }

    if (nFlag && !bFlag) {
      printf("%6d\t", lineNumber++);
    } else if (bFlag && strlen(line) != 1) {
      printf("%6d\t", lineNumber++);
    }

    for (int i = 0; line[i] != '\0'; i++) {
      char ch = line[i];

      if (vFlag) {
        if (ch == '\t')
          printf("^I");
        else if (ch == '\r')
          printf("^M");
        else if (ch == '\f')
          printf("^L");
        else if (ch == '\b')
          printf("^H");
        else if (ch != '\n')
          putchar(ch);
      } else if (tFlag && ch == '\t') {
        printf("^I");
      } else {
        if (ch != '\n') putchar(ch);
      }
    }

    if (eFlag) {
      if (currentLine != NULL && !bFlag) printf("$");
      if (currentLine != NULL && strlen(line) != 1 && bFlag) printf("$");
      if (strlen(line) == 1 && line[0] == '\n' && bFlag) printf("%6s\t$", "");
    }

    if (currentLine != NULL) {
      printf("\n");
    }

    currentLine = fgets(line, sizeof(line), file);
  }

  fclose(file);
}
*/
// ------------
