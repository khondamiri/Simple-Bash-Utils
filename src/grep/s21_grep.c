#include "s21_grep.h"

int main(int argc, char *argv[]) {
  char *expv[MAX_ARGS];
  int expc = 0;
  char *patternFileName = "";

  FLAGS flags = readFlags(argc, argv, expv, &expc, &patternFileName);

  if (flags.lineAsExpression) {
    grepFile(argc, argv, flags, patternFileName);
  } else if (flags.multiExpressions) {
    grepMulti(argc, argv, flags, expv, &expc);
  } else {
    grepBasic(argc, argv, flags);
  }

  return 0;
}

void grepBasic(int argc, char *argv[], FLAGS flags) {
  char **pattern = &argv[1];
  char **end = &argv[argc];
  regex_t preg_storage;
  regex_t *preg = &preg_storage;
  int multipleFiles = 0;

  for (; pattern != end && pattern[0][0] == '-'; ++pattern);
  // pattern[0][0] points to argv[1] initially.
  // after iteration ++pattern, pattern[0][0] will point to the argv[2] and so
  // on if true. it will skip the flags and will stop when it finds a pattern.

  if (argc - optind - 1 > 1) {
    multipleFiles = 1;
  }

  if (pattern == end) {
    if (!flags.noError) {
      fprintf(stderr, "s21_grep: no pattern provided\n");
    }
    exit(1);
  }

  if (regcomp(preg, *pattern, flags.regex_flag)) {
    if (!flags.noError) {
      fprintf(stderr, "s21_grep: grepBasic: pattern compilation failed\n");
    }
    exit(1);
  }

  for (char **fileName = pattern + 1; fileName != end; ++fileName) {
    if (**fileName == '-') {
      continue;
    }

    FILE *file = fopen(*fileName, "rb");
    if (!file) {
      if (!flags.noError) {
        fprintf(stderr, "s21_grep: %s: no such file or directory\n", *fileName);
      }
      continue;
    }

    int printed = 0;
    if (flags.count) {
      int totalCount = 0;
      size_t len = 0;
      char *line = NULL;

      while (getline(&line, &len, file) > 0) {
        line[strcspn(line, "\n")] = '\0';
        bool matchFound = (regexec(preg, line, 0, NULL, 0) == 0);

        if ((!flags.invert && matchFound) || (flags.invert && !matchFound)) {
          totalCount++;
        }
      }

      if (!flags.fileMatch) {
        if (multipleFiles && !flags.noFileName) {
          printf("%s:", *fileName);
        }
        printf("%d\n", totalCount);
      }
      free(line);
    } else if (flags.fileMatch) {
      fileMatch(file, *fileName, preg, 1, &printed);
    } else {
      performGrep(file, flags, *fileName, preg, 1, multipleFiles);
    }

    fclose(file);
  }
  regfree(preg);
}

void grepFile(int argc, char *argv[], FLAGS flags,
              const char *patternFileName) {
  FILE *patternFile = fopen(patternFileName, "rb");
  regex_t patterns[MAX_ARGS];
  int patternCount = 0;
  char **end = &argv[argc];
  char *patternLine = NULL;
  size_t len = 0;
  int multipleFiles = 0;

  if (argc < 4) {
    if (!flags.noError) {
      fprintf(stderr, "s21_grep: no files provided\n");
    }
    exit(1);
  }

  if (!patternFile) {
    if (!flags.noError) {
      fprintf(stderr, "s21_grep: %s: no such file or directory\n",
              patternFileName);
    }
    exit(1);
  }

  if (argc - optind > 1) {
    multipleFiles = 1;
  }

  while (getline(&patternLine, &len, patternFile) > 0) {
    patternLine[strcspn(patternLine, "\n")] = '\0';
    if (regcomp(&patterns[patternCount], patternLine, flags.regex_flag)) {
      if (!flags.noError) {
        fprintf(stderr, "s21_grep: grepFile: pattern compilation failed\n");
      }
      exit(1);
    }
    patternCount++;
  }

  for (char **targetFileName = &argv[optind]; targetFileName != end;
       ++targetFileName) {
    if (**targetFileName == '-') continue;

    FILE *targetFile = fopen(*targetFileName, "rb");
    if (!targetFile) {
      if (!flags.noError)
        fprintf(stderr, "s21_grep: %s: no such file or directory\n",
                *targetFileName);
      continue;
    }

    int printed = 0;
    if (flags.count) {
      int totalCount = 0;
      char *line = NULL;
      size_t line_len = 0;

      while (getline(&line, &line_len, targetFile) > 0) {
        line[strcspn(line, "\n")] = '\0';
        bool matchFound = false;

        // Check against all patterns
        for (int i = 0; i < patternCount; i++) {
          if (regexec(&patterns[i], line, 0, NULL, 0) == 0) {
            matchFound = true;
            break;
          }
        }

        if ((!flags.invert && matchFound) || (flags.invert && !matchFound)) {
          totalCount++;
        }
      }

      if (!flags.fileMatch) {
        if (multipleFiles && !flags.noFileName) {
          printf("%s:", *targetFileName);
        }
        printf("%d\n", totalCount);
      }

      free(line);

    } else if (flags.fileMatch) {
      fileMatch(targetFile, *targetFileName, patterns, patternCount, &printed);
    } else {
      performGrep(targetFile, flags, *targetFileName, patterns, patternCount,
                  multipleFiles);
    }

    fclose(targetFile);
  }

  for (int i = 0; i < patternCount; i++) {
    regfree(&patterns[i]);
  }
  free(patternLine);
  fclose(patternFile);
}

void grepMulti(int argc, char *argv[], FLAGS flags, char *expv[], int *expc) {
  regex_t patterns[MAX_ARGS];
  int multipleFiles = 0;
  if (argc - optind > 1) multipleFiles = 1;

  for (int i = 0; i < *expc; i++) {
    if (regcomp(&patterns[i], expv[i], flags.regex_flag)) {
      if (!flags.noError) {
        fprintf(stderr, "s21_grep: GrepMulti: pattern compilation failed\n");
      }
      exit(1);
    }
  }

  for (int i = optind; i < argc; i++) {
    FILE *file = fopen(argv[i], "rb");
    if (!file) {
      if (!flags.noError) {
        fprintf(stderr, "s21_grep: %s: no such file or directory\n", argv[i]);
      }
      continue;
    }

    int printed = 0;
    if (flags.count) {
      int totalCount = 0;
      char *line = NULL;
      size_t len = 0;

      while (getline(&line, &len, file) > 0) {
        line[strcspn(line, "\n")] = '\0';
        bool matchFound = false;

        for (int j = 0; j < *expc; j++) {
          if (regexec(&patterns[j], line, 0, NULL, 0) == 0) {
            matchFound = true;
            break;
          }
        }

        if ((!flags.invert && matchFound) || (flags.invert && !matchFound)) {
          totalCount++;
        }
      }

      if (!flags.fileMatch) {
        if (multipleFiles && !flags.noFileName) {
          printf("%s:", argv[i]);
        }
        printf("%d\n", totalCount);
      }
      free(line);
    } else if (flags.fileMatch) {
      fileMatch(file, argv[i], patterns, *expc, &printed);
    } else {
      performGrep(file, flags, argv[i], patterns, *expc, multipleFiles);
    }
    fclose(file);
  }
  for (int i = 0; i < *expc; i++) {
    regfree(&patterns[i]);
  }
}

void performGrep(FILE *file, FLAGS flags, char *fileName, regex_t *preg,
                 int patternCount, int multipleFiles) {
  char *line = 0;
  size_t len = 0;
  regmatch_t match;
  int lineNumber = 1;

  while (getline(&line, &len, file) > 0) {
    line[strcspn(line, "\n")] = '\0';
    bool matchFound = false;
    regmatch_t firstMatch = {0};

    for (int i = 0; i < patternCount; i++) {
      if (!regexec(&preg[i], line, 1, &match, 0)) {
        matchFound = true;

        if (!flags.invert && flags.onlyMatches) {
          firstMatch = match;
        }
        if (!flags.invert && !flags.onlyMatches) {
          break;
        }
      }
    }

    if ((!flags.invert && matchFound) || (flags.invert && !matchFound)) {
      if (!flags.noFileName && multipleFiles) {
        printf("%s:", fileName);
      }
      if (flags.lineNumbers) {
        printf("%d:", lineNumber);
      }
      if (flags.onlyMatches && !flags.invert && matchFound) {
        printf("%.*s\n", (int)(firstMatch.rm_eo - firstMatch.rm_so),
               line + firstMatch.rm_so);
      } else {
        printf("%s\n", line);
      }
    }
    ++lineNumber;
  }
  free(line);
}

void fileMatch(FILE *file, const char *fileName, regex_t *preg,
               int patternCount, int *printed) {
  char *line = NULL;
  size_t len = 0;
  regmatch_t match;

  while (getline(&line, &len, file) > 0) {
    for (int i = 0; i < patternCount; i++) {
      if (!regexec(preg, line, 1, &match, 0)) {
        if (*printed == 0) {
          printf("%s\n", fileName);
          *printed = 1;
          break;
        }
      }
    }
  }
  free(line);
}

FLAGS readFlags(int argc, char *argv[], char *expv[], int *expc,
                char **patternFileName) {
  FLAGS flags = {0,     false, false, false, false,
                 false, false, false, false, false};
  int option;

  while ((option = getopt(argc, argv, "e:ivclnhsf:o")) != -1) {
    switch (option) {
      case 'e':  // done
        flags.multiExpressions = true;
        expv[*expc] = optarg;
        (*expc)++;
        break;
      case 'i':  // done
        flags.regex_flag |= REG_ICASE;
        break;
      case 'v':  // done
        flags.invert = true;
        break;
      case 'c':  // done
        flags.count = true;
        break;
      case 'l':  // done
        flags.fileMatch = true;
        break;
      case 'n':  // done
        flags.lineNumbers = true;
        break;
      case 'h':  // done
        flags.noFileName = true;
        break;
      case 's':  // done
        flags.noError = true;
        break;
      case 'f':  // done
        *patternFileName = optarg;
        flags.lineAsExpression = true;
        break;
      case 'o':  // done
        flags.onlyMatches = true;
        break;
      case '?':
        fprintf(stderr, "s21_grep: illegal option: -%d\n", optopt);
        break;
    }
  }
  return flags;
}

// -- backups --
/*
void grepFile(int argc, char *argv[], FLAGS flags) {
  FILE *patternFile = fopen(optarg, "rb");

  size_t len = 0;
  regex_t preg_storage;
  regex_t *preg = &preg_storage;
  char **end = &argv[argc];
  char *patternLine = NULL;
  int multipleFiles = 0;

  if (argc < 4) {
    printf("no files provided\n");
    exit(1);
  }

  if (!patternFile) {
    if (!flags.noError) perror(optarg);
    exit(1);
  }

  if (argc - optind > 1) {
    multipleFiles = 1;
  }

  for (char **targetFileName = &argv[optind]; targetFileName != end;
       ++targetFileName) {
    if (**targetFileName == '-') continue;

    FILE *targetFile = fopen(*targetFileName, "rb");

    if (!targetFile) {
      if (!flags.noError) perror(*targetFileName);
      continue;
    }

    int printed = 0;
    int totalCount = 0;

    fseek(patternFile, 0, SEEK_SET);

    while (getline(&patternLine, &len, patternFile) > 0) {
      patternLine[strcspn(patternLine, "\n")] = 0;

      if (regcomp(preg, patternLine, flags.regex_flag)) {
        fprintf(stderr, "compilation failed");
        exit(1);
      }

      if (flags.count) {
        totalCount += count(targetFile, flags, preg);
      } else if (flags.fileMatch) {
        fileMatch(targetFile, *targetFileName, preg, &printed);
      } else {
        performGrep(targetFile, flags, *targetFileName, preg, multipleFiles);
      }

      regfree(preg);
      fseek(targetFile, 0, SEEK_SET);
    }

    if (flags.count && !flags.fileMatch) {
      if (multipleFiles && !flags.noFileName) {
        printf("%s:", *targetFileName);
      }
      printf("%d\n", totalCount);
    }

    fclose(targetFile);
  }
  free(patternLine);
  fclose(patternFile);
}
*/
/*
void grepFile(int argc, char *argv[], FLAGS flags,
              const char *patternFileName) {
  FILE *patternFile = fopen(patternFileName, "rb");

  regex_t patterns[MAX_ARGS];
  int patternCount = 0;

  char **end = &argv[argc];
  char *patternLine = NULL;
  size_t len = 0;

  int multipleFiles = 0;
  int printed = 0;

  if (argc < 4) {
    if (!flags.noError) {
      fprintf(stderr, "s21_grep: no files provided\n");
    }
    exit(1);
  }

  if (!patternFile) {
    if (!flags.noError) {
      fprintf(stderr, "s21_grep: %s: no such file or directory\n",
              patternFileName);
    }
    exit(1);
  }

  if (argc - optind > 1) {
    multipleFiles = 1;
  }

  // ################################# //
  // int temp = 0;
  // ################################# //

  while (getline(&patternLine, &len, patternFile) > 0) {
    patternLine[strcspn(patternLine, "\n")] = '\0';

    // ################################# //
    // printf("[DEBUG] pattern[%d]: %s\n", temp++, patternLine);
    // printf("[DEBUG] pattern count: %d\n", patternCount);
    // ################################# //

    if (regcomp(&patterns[patternCount], patternLine, flags.regex_flag)) {
      if (!flags.noError) {
        fprintf(stderr, "s21_grep: pattern compilation failed\n");
      }
      exit(1);
    }
    patternCount++;
  }

  // printf("\n[#################################]\n\n");

  for (char **targetFileName = &argv[optind]; targetFileName != end;
       ++targetFileName) {
    if (**targetFileName == '-') continue;
    int totalCount = 0;
    int printedFileName = 0;

    FILE *targetFile = fopen(*targetFileName, "rb");

    if (!targetFile) {
      if (!flags.noError)
        fprintf(stderr, "s21_grep: %s: no such file or directory\n",
                *targetFileName);
      continue;
    }

    // ################################# //
    // printf("[DEBUG] target file name: %s\n", *targetFileName);
    // ################################# //

    for (int index = 0; index < patternCount; index++) {
      regex_t *preg = &patterns[index];

      // ################################# //

      // // printf("[DEBUG] pattern count: %d\n", patternCount);
      // printf("[DEBUG] pattern index: %d\n", index);
      // // printf("[DEBUG] address of regex_t object: %p\n", (void *)preg);

      // const char *testString = "apple";
      // int ret = regexec(preg, testString, 0, NULL, 0);
      // if (ret == 0) {
      //   printf("[DEBUG] +++Regex matches the test string: %s\n", testString);
      // } else if (ret == REG_NOMATCH) {
      //   printf("[DEBUG] ---Regex does not match the test string: %s\n",
      //          testString);
      // } else {
      //   char errorBuffer[256];
      //   regerror(ret, preg, errorBuffer, sizeof(errorBuffer));
      //   printf("[DEBUG] Regex execution error: %s\n", errorBuffer);
      // }

      // ################################# //

      if (flags.count) {
        totalCount += count(targetFile, flags, preg);
      } else if (flags.fileMatch) {
        fileMatch(targetFile, *targetFileName, preg, &printed);
      } else {
        performGrep(targetFile, flags, *targetFileName, preg, multipleFiles);
      }

      if (flags.count && !flags.fileMatch && !printedFileName) {
        if (multipleFiles && !flags.noFileName) {
          printf("%s:", *targetFileName);
        }
        printf("%d\n", totalCount);
        printedFileName = 1;
      }
    }

    fseek(targetFile, 0, SEEK_SET);
    fclose(targetFile);
  }

  for (int i = 0; i < patternCount; i++) {
    regfree(&patterns[i]);
  }
  free(patternLine);
  fclose(patternFile);
}
*/
/*
int count(FILE *file, FLAGS flags, regex_t *preg) {
  char *line = 0;
  size_t len = 0;
  int count = 0;
  regmatch_t match;

  while (getline(&line, &len, file) > 0) {
    if (flags.invert) {
      if (regexec(preg, line, 1, &match, 0)) {
        ++count;
      }
    } else {
      if (!regexec(preg, line, 1, &match, 0)) {
        ++count;
      }
    }
  }

  free(line);
  return count;
}
*/
// -------------
