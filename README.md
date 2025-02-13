# Simple-Bash-Utils
School 21 Core Program - SimpleBashUtils. Cat and grep programs.

## Installation
 - Clone the repo:
   ```sh
   git clone https://github.com/khondamiri/Simple-Bash-Utils.git
   ```
 - To use Cat navigate to the project directory and compile the program:
   ```sh
   cd Simple-Bash-Utils/cat
   make
   ```
 - To use Grep navigate to the project directory and compile the program:
   ```sh
   cd Simple-Bash-Utils/grep
   make
   ```

## 3. Cat

 - Cat is used for reading files.

### Options
| No. | Options | Description |
| ------ | ------ | ------ |
| 1 | -b (GNU: --number-nonblank) | numbers only non-empty lines |
| 2 | -e (GNU only: -E the same, but without implying -v) | but also display end-of-line characters as $  |
| 3 | -n (GNU: --number) | number all output lines |
| 4 | -s (GNU: --squeeze-blank) | squeeze multiple adjacent blank lines |
| 5 | -t (GNU: -T the same, but without implying -v) | but also display tabs as ^I  |

### Usage

 - To run the program:
    ```
    ./s21_cat options file_name
    ```

## 4. Grep

- Searches for patterns in a file or input stream.

### Options
| No. | Options | Description |
| ------ | ------ | ------ |
| 1 | -e | pattern |
| 2 | -i | Ignore uppercase vs. lowercase.  |
| 3 | -v | Invert match. |
| 4 | -c | Output count of matching lines only. |
| 5 | -l | Output matching files only.  |
| 6 | -n | Precede each matching line with a line number. |
| 7 | -h | Output matching lines without preceding them by file names. |
| 8 | -s | Suppress error messages about nonexistent or unreadable files. |
| 9 | -f file | Take regexes from a file. |
| 10 | -o | Output the matched parts of a matching line. |

### Usage

 - To run the program:
    ```
    ./s21_grep options pattern file_name
    ```
    ```
    ./s21_grep options pattern_file file_name
    ```
    ```
    ./s21_grep options -e pattern -e pattern file_name
    ```