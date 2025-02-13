#!/bin/bash

combinations=(
    ""
    "-n"
    "-b"
    "-v"
    "-t"
    "-e"
    "-s"
    "-n -b"
    "-n -v"
    "-n -t"
    "-n -e"
    "-n -s"
    "-b -v"
    "-b -t"
    "-b -e"
    "-b -s"
    "-v -t"
    "-v -e"
    "-v -s"
    "-t -e"
    "-t -s"
    "-e -s"
    "-n -b -v"
    "-n -b -t"
    "-n -b -e"
    "-n -b -s"
    "-n -v -t"
    "-n -v -e"
    "-n -v -s"
    "-n -t -e"
    "-n -t -s"
    "-n -e -s"
    "-b -v -t"
    "-b -v -e"
    "-b -v -s"
    "-b -t -e"
    "-b -t -s"
    "-b -e -s"
    "-v -t -e"
    "-v -t -s"
    "-v -e -s"
    "-t -e -s"
    "-n -b -v -t"
    "-n -b -v -e"
    "-n -b -v -s"
    "-n -b -t -e"
    "-n -b -t -s"
    "-n -b -e -s"
    "-n -v -t -e"
    "-n -v -t -s"
    "-n -v -e -s"
    "-n -t -e -s"
    "-b -v -t -e"
    "-b -v -t -s"
    "-b -v -e -s"
    "-b -t -e -s"
    "-v -t -e -s"
    "-n -b -v -t -e"
    "-n -b -v -t -s"
    "-n -b -v -e -s"
    "-n -b -t -e -s"
    "-n -v -t -e -s"
    "-b -v -t -e -s"
    "-n -b -v -t -e -s"
)

intro() {
    divider
    empty
    echo "Verter is watching your code..."
    empty
}

styleCheck() {
    divider
    empty
    echo "Style test"
    empty
    echo "Style test output:"
    clangFormatOutput=$(clang-format -n s21_cat.c 2>&1)
    if [[ -n "$clangFormatOutput" ]]; then
        echo "$clangFormatOutput"
        empty
        echo "    Style test: FAIL"
        empty
        echo "Style test result: 0"
    else
        empty
        empty
        echo "    Style test: OK"
        empty
        echo "Style test result: 1"
    fi
    divider
}

buildProject() {
    divider
    empty
    echo "Build test"
    empty
    echo "Build output:"
    make
    build_status=$?
    empty 
    empty
    if [[ $build_status -eq 0 ]]; then
        echo "    Build test: OK"
        empty
        echo "Build test result: 1"
    else
        echo "    Build test: FAIL"
        empty
        echo "Build test result: 0"
    fi
    divider
}

createTestFiles() {
    # Test file 1: Empty file
    touch test1.txt

    # Test file 2: Single line of text
    echo "This is a single line of text." > test2.txt

    # Test file 3: Multiple lines of text
    echo "Line 1: This is the first line." > test3.txt
    echo "" >> test3.txt
    echo "" >> test3.txt
    echo "" >> test3.txt
    echo "" >> test3.txt
    echo "Line 5: This is the fifth line." >> test3.txt
    echo "Line 6: This is the sixth line." >> test3.txt

    # Test file 4: Special characters
    echo "Special characters: ~!@#$%^&*()_+{}|:\"<>?-=[]\\;',./" > test4.txt

    # Test file 5: Unicode characters
    echo "Unicode test: 你好, мир, 안녕하세요, नमस्ते, hello!" > test5.txt

    # Test file 6: Binary-like content
    echo -e "Binary content:\x00\x01\x02\x03\x04" > test6.bin

    # Test file 7: Very large file (1000 lines)
    yes "This is a repeated line for large file testing." | head -n 1000 > test7.txt
}


test_1() {
    divider
    empty
    echo "Test #1: Empty file, Name: s21_cat"
    empty
    echo "Test output:"
    valgrind --tool=memcheck --leak-check=yes ./s21_cat test1.txt
    empty
    empty
    valgrind --tool=memcheck --leak-check=yes ./s21_cat test1.txt 2>&1 | grep -q "ERROR SUMMARY: 0" && echo "    Memory test: OK" || echo "   Memory test: FAIL"
    for flags in "${combinations[@]}"; do
        catExpected=$(cat $flags test1.txt 2>&1 | tr -d '\0')
        catOutput=$(./s21_cat $flags test1.txt 2>&1 | tr -d '\0')
        if [[ "$catExpected" != "$catOutput" ]]; then
            echo "error: ./s21_cat $flags test.txt"
            empty
            echo "    Functional test #1: FAIL"
            empty
            echo "Result for test #1: 0"
            divider
            return 1
        fi
    done
    empty
    echo "    Functional test #1: OK"
    empty
    echo "Result for test #1: 1"
    divider
}

test_2() {
    divider
    empty
    echo "Test #2: Single line of text, Name: s21_cat"
    empty
    echo "Test output:"
    valgrind --tool=memcheck --leak-check=yes ./s21_cat test2.txt
    empty
    empty
    valgrind --tool=memcheck --leak-check=yes ./s21_cat test2.txt 2>&1 | grep -q "ERROR SUMMARY: 0" && echo "    Memory test: OK" || echo "   Memory test: FAIL"
    for flags in "${combinations[@]}"; do
        catExpected=$(cat $flags test2.txt 2>&1 | tr -d '\0')
        catOutput=$(./s21_cat $flags test2.txt 2>&1 | tr -d '\0')
        if [[ "$catExpected" != "$catOutput" ]]; then
            echo "error: ./s21_cat $flags test2.txt"
            empty
            echo "    Functional test #2: FAIL"
            empty
            echo "Result for test #2: 0"
            divider
            return 1
        fi
    done
    empty
    echo "    Functional test #2: OK"
    empty
    echo "Result for test #2: 1"
    divider
}

test_3() {
    divider
    empty
    echo "Test #3: Multiple lines of text, Name: s21_cat"
    empty
    echo "Test output:"
    valgrind --tool=memcheck --leak-check=yes ./s21_cat test3.txt
    empty
    empty
    valgrind --tool=memcheck --leak-check=yes ./s21_cat test3.txt 2>&1 | grep -q "ERROR SUMMARY: 0" && echo "    Memory test: OK" || echo "   Memory test: FAIL"
    for flags in "${combinations[@]}"; do
        catExpected=$(cat $flags test3.txt 2>&1 | tr -d '\0')
        catOutput=$(./s21_cat $flags test3.txt 2>&1 | tr -d '\0')
        if [[ "$catExpected" != "$catOutput" ]]; then
            echo "error: ./s21_cat $flags test3.txt"
            empty
            echo "    Functional test #3: FAIL"
            empty
            echo "Result for test #3: 0"
            divider
            return 1
        fi
    done
    empty
    echo "    Functional test #3: OK"
    empty
    echo "Result for test #3: 1"
    divider
}

test_4() {
    divider
    empty
    echo "Test #4: Special characters, Name: s21_cat"
    empty
    echo "Test output:"
    valgrind --tool=memcheck --leak-check=yes ./s21_cat test4.txt
    empty
    empty
    valgrind --tool=memcheck --leak-check=yes ./s21_cat test4.txt 2>&1 | grep -q "ERROR SUMMARY: 0" && echo "    Memory test: OK" || echo "   Memory test: FAIL"
    for flags in "${combinations[@]}"; do
        catExpected=$(cat $flags test4.txt 2>&1 | tr -d '\0')
        catOutput=$(./s21_cat $flags test4.txt 2>&1 | tr -d '\0')
        if [[ "$catExpected" != "$catOutput" ]]; then
            echo "error: ./s21_cat $flags test4.txt"
            empty
            echo "    Functional test #4: FAIL"
            empty
            echo "Result for test #4: 0"
            divider
            return 1
        fi
    done
    empty
    echo "    Functional test #4: OK"
    empty
    echo "Result for test #4: 1"
    divider
}

test_5() {
    divider
    empty
    echo "Test #5: Unicode characters, Name: s21_cat"
    empty
    echo "Test output:"
    valgrind --tool=memcheck --leak-check=yes ./s21_cat test5.txt
    empty
    empty
    valgrind --tool=memcheck --leak-check=yes ./s21_cat test5.txt 2>&1 | grep -q "ERROR SUMMARY: 0" && echo "    Memory test: OK" || echo "   Memory test: FAIL"
    for flags in "${combinations[@]}"; do
        catExpected=$(cat $flags test5.txt 2>&1 | tr -d '\0')
        catOutput=$(./s21_cat $flags test5.txt 2>&1 | tr -d '\0')
        if [[ "$catExpected" != "$catOutput" ]]; then
            echo "error: ./s21_cat $flags test5.txt"
            empty
            echo "    Functional test #5: FAIL"
            empty
            echo "Result for test #5: 0"
            divider
            return 1
        fi
    done
    empty
    echo "    Functional test #5: OK"
    empty
    echo "Result for test #5: 1"
    divider
}

test_6() {
    divider
    empty
    echo "Test #6: Binary-like content, Name: s21_cat"
    empty
    echo "Test output:"
    valgrind --tool=memcheck --leak-check=yes ./s21_cat test6.bin
    empty
    empty
    valgrind --tool=memcheck --leak-check=yes ./s21_cat test6.bin 2>&1 | grep -q "ERROR SUMMARY: 0" && echo "    Memory test: OK" || echo "   Memory test: FAIL"
    for flags in "${combinations[@]}"; do
        catExpected=$(cat $flags test6.bin 2>&1 | tr -d '\0')
        catOutput=$(./s21_cat $flags test6.bin 2>&1 | tr -d '\0')
        if [[ "$catExpected" != "$catOutput" ]]; then
            echo "error: ./s21_cat $flags test6.bin"
            empty
            echo "    Functional test #6: FAIL"
            empty
            echo "Result for test #6: 0"
            divider
            return 1
        fi
    done
    empty
    echo "    Functional test #6: OK"
    empty
    echo "Result for test #6: 1"
    divider
}

test_7() {
    divider
    empty
    echo "Test #7: Very large file, Name: s21_cat"
    empty
    echo "Test output:"
    # valgrind --tool=memcheck --leak-check=yes ./s21_cat test7.txt
    empty
    empty
    valgrind --tool=memcheck --leak-check=yes ./s21_cat test7.txt 2>&1 | grep -q "ERROR SUMMARY: 0" && echo "    Memory test: OK" || echo "   Memory test: FAIL"
    for flags in "${combinations[@]}"; do
        catExpected=$(cat $flags test7.txt 2>&1)
        catOutput=$(./s21_cat $flags test7.txt 2>&1)
        if [[ "$catExpected" != "$catOutput" ]]; then
            echo "error: ./s21_cat $flags test7.txt"
            empty
            echo "    Functional test #7: FAIL"
            empty
            echo "Result for test #7: 0"
            divider
            return 1
        fi
    done
    empty
    echo "    Functional test #7: OK"
    empty
    echo "Result for test #7: 1"
    divider
}

cleanUp() {
    rm -f test1.txt test2.txt test3.txt test4.txt test5.txt test6.bin test7.txt
    rm -f s21_cat
}

divider() {
    echo "------------------------------------------------------------"
}
empty() {
    echo ""
}

intro
styleCheck
empty
buildProject
empty
createTestFiles
test_1
empty
test_2
empty
test_3
empty
test_4
empty
test_5
empty
test_6
empty
test_7
cleanUp