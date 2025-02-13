#!/bin/bash

intro() {
    divider
    empty
    echo "Verter is watching your grep tests..."
    empty
}

styleCheck() {
    divider
    empty
    echo "Style test"
    empty
    echo "Style test output:"
    clangFormatOutput=$(clang-format -n s21_grep.c 2>&1)
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
    # Test file 1: Simple text file
    echo -e "apple\nbanana\ncherry" > test1.txt

    # Test file 2: Case-sensitive text
    echo -e "Apple\nBanana\nCherry" > test2.txt

    # Test file 3: Multiline with patterns
    echo -e "Error: file not found\nSuccess: operation completed\nWarning: low disk space" > test3.txt

    # Test file 4: Special characters
    echo -e "[ERROR]\n(SUCCESS)\nWARNING:" > test4.txt

    # Test file 5: Pattern file for -f flag
    echo -e "apple\nError" > patterns.txt

    # Test file 6: Large text file
    yes "Test line for large file" | head -n 1000 > test6.txt
}

noFlag() {
    divider
    empty
    echo "Test #1: no flags -> simple test, Name: ./s21_grep apple test1.txt test2.txt"
    empty
    echo "Test output:"
    valgrind --tool=memcheck --leak-check=yes ./s21_grep apple test1.txt test2.txt
    empty
    valgrind --tool=memcheck --leak-check=yes ./s21_grep apple test1.txt test2.txt 2>&1 | grep -q "ERROR SUMMARY: 0" && echo "    Memory test: OK" || echo "    Memory test: FAIL"
 
    grepExpected=$(grep apple test1.txt test2.txt 2>&1 | tr -d '\0')
    grepOutput=$(./s21_grep apple test1.txt test2.txt 2>&1 | tr -d '\0')

    if [[ "$grepExpected" != "$grepOutput" ]]; then
        echo "error: ./s21_grep apple test1.txt test2.txt"
        empty
        echo "    Functional test: FAIL"
        empty
        echo "Result for test #1: 0"
        divider
        return 1
    fi
    empty
    echo "    Functional test: OK"
    empty
    echo "Result for test #1: 1"
    divider
}

iFlag() {
    divider
    empty
    echo "Test #2: -i flag -> Case-sensitive test, Name: ./s21_grep -i cherry test1.txt test2.txt"
    empty
    echo "Test output:"
    valgrind --tool=memcheck --leak-check=yes ./s21_grep -i cherry test1.txt test2.txt
    empty
    valgrind --tool=memcheck --leak-check=yes ./s21_grep -i cherry test1.txt test2.txt 2>&1 | grep -q "ERROR SUMMARY: 0" && echo "    Memory test: OK" || echo "    Memory test: FAIL"
 
    grepExpected=$(grep -i cherry test1.txt test2.txt 2>&1 | tr -d '\0')
    grepOutput=$(./s21_grep -i cherry test1.txt test2.txt 2>&1 | tr -d '\0')

    if [[ "$grepExpected" != "$grepOutput" ]]; then
        echo "error: ./s21_grep -i cherry test1.txt test2.txt"
        empty
        echo "    Functional test: FAIL"
        empty
        echo "Result for test #2: 0"
        divider
        return 1
    fi
    empty
    echo "    Functional test: OK"
    empty
    echo "Result for test #2: 1"
    divider
}

vFlag() {
    divider
    empty
    echo "Test #3: -v flag -> Invert test, Name: ./s21_grep -v cherry test1.txt test2.txt"
    empty
    echo "Test output:"
    valgrind --tool=memcheck --leak-check=yes ./s21_grep -v cherry test1.txt test2.txt
    empty
    valgrind --tool=memcheck --leak-check=yes ./s21_grep -v cherry test1.txt test2.txt 2>&1 | grep -q "ERROR SUMMARY: 0" && echo "    Memory test: OK" || echo "    Memory test: FAIL"
 
    grepExpected=$(grep -v cherry test1.txt test2.txt 2>&1 | tr -d '\0')
    grepOutput=$(./s21_grep -v cherry test1.txt test2.txt 2>&1 | tr -d '\0')

    if [[ "$grepExpected" != "$grepOutput" ]]; then
        echo "error: ./s21_grep -v cherry test1.txt test2.txt"
        empty
        echo "    Functional test: FAIL"
        empty
        echo "Result for test #3: 0"
        divider
        return 1
    fi
    empty
    echo "    Functional test: OK"
    empty
    echo "Result for test #3: 1"
    divider
}

cFlag() {
    divider
    empty
    echo "Test #4: -c flag -> count test, Name: ./s21_grep -c Banana test1.txt test2.txt"
    empty
    echo "Test output:"
    valgrind --tool=memcheck --leak-check=yes ./s21_grep -c Banana test1.txt test2.txt
    empty
    valgrind --tool=memcheck --leak-check=yes ./s21_grep -c Banana test1.txt test2.txt 2>&1 | grep -q "ERROR SUMMARY: 0" && echo "    Memory test: OK" || echo "    Memory test: FAIL"
 
    grepExpected=$(grep -c Banana test1.txt test2.txt 2>&1 | tr -d '\0')
    grepOutput=$(./s21_grep -c Banana test1.txt test2.txt 2>&1 | tr -d '\0')

    if [[ "$grepExpected" != "$grepOutput" ]]; then
        echo "error: ./s21_grep -c Banana test1.txt test2.txt"
        empty
        echo "    Functional test: FAIL"
        empty
        echo "Result for test #4: 0"
        divider
        return 1
    fi
    empty
    echo "    Functional test: OK"
    empty
    echo "Result for test #4: 1"
    divider
}

lFlag() {
    divider
    empty
    echo "Test #5: -l flag -> file-match test, Name: ./s21_grep -l banana test1.txt test2.txt test3.txt"
    empty
    echo "Test output:"
    valgrind --tool=memcheck --leak-check=yes ./s21_grep -l banana test1.txt test2.txt test3.txt
    empty
    valgrind --tool=memcheck --leak-check=yes ./s21_grep -l banana test1.txt test2.txt test3.txt 2>&1 | grep -q "ERROR SUMMARY: 0" && echo "    Memory test: OK" || echo "    Memory test: FAIL"
 
    grepExpected=$(grep -l banana test1.txt test2.txt test3.txt 2>&1 | tr -d '\0')
    grepOutput=$(./s21_grep -l banana test1.txt test2.txt test3.txt 2>&1 | tr -d '\0')

    if [[ "$grepExpected" != "$grepOutput" ]]; then
        echo "error: ./s21_grep -l banana test1.txt test2.txt test3.txt"
        empty
        echo "    Functional test: FAIL"
        empty
        echo "Result for test #5: 0"
        divider
        return 1
    fi
    empty
    echo "    Functional test: OK"
    empty
    echo "Result for test #5: 1"
    divider
}

nFlag() {
    divider
    empty
    echo "Test #6: -n flag -> line-number test, Name: ./s21_grep -n banana test1.txt test2.txt test3.txt"
    empty
    echo "Test output:"
    valgrind --tool=memcheck --leak-check=yes ./s21_grep -n banana test1.txt test2.txt test3.txt
    empty
    valgrind --tool=memcheck --leak-check=yes ./s21_grep -n banana test1.txt test2.txt test3.txt 2>&1 | grep -q "ERROR SUMMARY: 0" && echo "    Memory test: OK" || echo "    Memory test: FAIL"
 
    grepExpected=$(grep -n banana test1.txt test2.txt test3.txt 2>&1 | tr -d '\0')
    grepOutput=$(./s21_grep -n banana test1.txt test2.txt test3.txt 2>&1 | tr -d '\0')

    if [[ "$grepExpected" != "$grepOutput" ]]; then
        echo "error: ./s21_grep -n banana test1.txt test2.txt test3.txt"
        empty
        echo "    Functional test: FAIL"
        empty
        echo "Result for test #6: 0"
        divider
        return 1
    fi
    empty
    echo "    Functional test: OK"
    empty
    echo "Result for test #6: 1"
    divider
}

hFlag() {
    divider
    empty
    echo "Test #7: -h flag -> no file name test, Name: ./s21_grep -h Apple test1.txt test2.txt test3.txt"
    empty
    echo "Test output:"
    valgrind --tool=memcheck --leak-check=yes ./s21_grep -h Apple test1.txt test2.txt test3.txt
    empty
    valgrind --tool=memcheck --leak-check=yes ./s21_grep -h Apple test1.txt test2.txt test3.txt 2>&1 | grep -q "ERROR SUMMARY: 0" && echo "    Memory test: OK" || echo "    Memory test: FAIL"
 
    grepExpected=$(grep -h Apple test1.txt test2.txt test3.txt 2>&1 | tr -d '\0')
    grepOutput=$(./s21_grep -h Apple test1.txt test2.txt test3.txt 2>&1 | tr -d '\0')

    if [[ "$grepExpected" != "$grepOutput" ]]; then
        echo "error: ./s21_grep -h Apple test1.txt test2.txt test3.txt"
        empty
        echo "    Functional test: FAIL"
        empty
        echo "Result for test #7: 0"
        divider
        return 1
    fi
    empty
    echo "    Functional test: OK"
    empty
    echo "Result for test #7: 1"
    divider
}

sFlag() {
    divider
    empty
    echo "Test #8: -s flag -> no errors test, Name: ./s21_grep -s Apple test1.txt test2.txt missing_file.txt"
    empty
    echo "Test output:"
    valgrind --tool=memcheck --leak-check=yes ./s21_grep -s Apple test1.txt test2.txt missing_file.txt
    empty
    valgrind --tool=memcheck --leak-check=yes ./s21_grep -s Apple test1.txt test2.txt missing_file.txt 2>&1 | grep -q "ERROR SUMMARY: 0" && echo "    Memory test: OK" || echo "    Memory test: FAIL"
 
    grepExpected=$(grep -s Apple test1.txt test2.txt missing_file.txt 2>&1 | tr -d '\0')
    grepOutput=$(./s21_grep -s Apple test1.txt test2.txt missing_file.txt 2>&1 | tr -d '\0')

    if [[ "$grepExpected" != "$grepOutput" ]]; then
        echo "error: ./s21_grep -s Apple test1.txt test2.txt missing_file.txt"
        empty
        echo "    Functional test: FAIL"
        empty
        echo "Result for test #8: 0"
        divider
        return 1
    fi
    empty
    echo "    Functional test: OK"
    empty
    echo "Result for test #8: 1"
    divider
}

fFlag() {
    divider
    empty
    echo "Test #9: -f flag -> file as pattern test, Name: ./s21_grep -f patterns.txt test1.txt test2.txt test3.txt test4.txt"
    empty
    echo "Test output:"
    valgrind --tool=memcheck --leak-check=yes ./s21_grep -f patterns.txt test1.txt test2.txt test3.txt test4.txt
    empty
    valgrind --tool=memcheck --leak-check=yes ./s21_grep -f patterns.txt test1.txt test2.txt test3.txt test4.txt 2>&1 | grep -q "ERROR SUMMARY: 0" && echo "    Memory test: OK" || echo "    Memory test: FAIL"
 
    grepExpected=$(grep -f patterns.txt test1.txt test2.txt test3.txt test4.txt 2>&1 | tr -d '\0')
    grepOutput=$(./s21_grep -f patterns.txt test1.txt test2.txt test3.txt test4.txt 2>&1 | tr -d '\0')

    if [[ "$grepExpected" != "$grepOutput" ]]; then
        echo "error: ./s21_grep -f patterns.txt test1.txt test2.txt test3.txt test4.txt"
        empty
        echo "    Functional test: FAIL"
        empty
        echo "Result for test #9: 0"
        divider
        return 1
    fi
    empty
    echo "    Functional test: OK"
    empty
    echo "Result for test #9: 1"
    divider
}

oFlag() {
    divider
    empty
    echo "Test #10: -o flag -> only matches output test, Name: ./s21_grep -o low test1.txt test2.txt test3.txt"
    empty
    echo "Test output:"
    valgrind --tool=memcheck --leak-check=yes ./s21_grep -o low test1.txt test2.txt test3.txt
    empty
    valgrind --tool=memcheck --leak-check=yes ./s21_grep -o low test1.txt test2.txt test3.txt 2>&1 | grep -q "ERROR SUMMARY: 0" && echo "    Memory test: OK" || echo "    Memory test: FAIL"
 
    grepExpected=$(grep -o low test1.txt test2.txt test3.txt 2>&1 | tr -d '\0')
    grepOutput=$(./s21_grep -o low test1.txt test2.txt test3.txt 2>&1 | tr -d '\0')

    if [[ "$grepExpected" != "$grepOutput" ]]; then
        echo "error: ./s21_grep -o low test1.txt test2.txt test3.txt"
        empty
        echo "    Functional test: FAIL"
        empty
        echo "Result for test #10: 0"
        divider
        return 1
    fi
    empty
    echo "    Functional test: OK"
    empty
    echo "Result for test #10: 1"
    divider
}

eFlag() {
    divider
    empty
    echo "Test #11: -e flag -> multiple expressions test, Name: ./s21_grep -e ERROR -e Apple test1.txt test2.txt test3.txt test4.txt"
    empty
    echo "Test output:"
    valgrind --tool=memcheck --leak-check=yes ./s21_grep -e ERROR -e Apple test1.txt test2.txt test3.txt test4.txt
    empty
    valgrind --tool=memcheck --leak-check=yes ./s21_grep -e ERROR -e Apple test1.txt test2.txt test3.txt test4.txt 2>&1 | grep -q "ERROR SUMMARY: 0" && echo "    Memory test: OK" || echo "    Memory test: FAIL"
 
    grepExpected=$(grep -e ERROR -e Apple test1.txt test2.txt test3.txt test4.txt 2>&1 | tr -d '\0')
    grepOutput=$(./s21_grep -e ERROR -e Apple test1.txt test2.txt test3.txt test4.txt 2>&1 | tr -d '\0')

    if [[ "$grepExpected" != "$grepOutput" ]]; then
        echo "error: ./s21_grep -e ERROR -e Apple test1.txt test2.txt test3.txt test4.txt"
        empty
        echo "    Functional test: FAIL"
        empty
        echo "Result for test #11: 0"
        divider
        return 1
    fi
    empty
    echo "    Functional test: OK"
    empty
    echo "Result for test #11: 1"
    divider
}

multiFlags_1() {
    divider
    empty
    echo "Test #12: -i -c -e flags, Name: ./s21_grep -i -c -e apple -e error test1.txt test2.txt test3.txt test4.txt"
    empty
    echo "Test output:"
    valgrind --tool=memcheck --leak-check=yes ./s21_grep -i -c -e apple -e error test1.txt test2.txt test3.txt test4.txt
    empty
    valgrind --tool=memcheck --leak-check=yes ./s21_grep -i -c -e apple -e error test1.txt test2.txt test3.txt test4.txt 2>&1 | grep -q "ERROR SUMMARY: 0" && echo "    Memory test: OK" || echo "    Memory test: FAIL"
 
    grepExpected=$(grep -i -c -e apple -e error test1.txt test2.txt test3.txt test4.txt 2>&1 | tr -d '\0')
    grepOutput=$(./s21_grep -i -c -e apple -e error test1.txt test2.txt test3.txt test4.txt 2>&1 | tr -d '\0')

    if [[ "$grepExpected" != "$grepOutput" ]]; then
        echo "error: ./s21_grep -i -c -e apple -e error test1.txt test2.txt test3.txt test4.txt"
        empty
        echo "    Functional test: FAIL"
        empty
        echo "Result for test #12: 0"
        divider
        return 1
    fi
    empty
    echo "    Functional test: OK"
    empty
    echo "Result for test #12: 1"
    divider
}

multiFlags_2() {
    divider
    empty
    echo "Test #13: -i -h -e flags, Name: ./s21_grep -i -h -e apple -e error test1.txt test2.txt test3.txt test4.txt"
    empty
    echo "Test output:"
    valgrind --tool=memcheck --leak-check=yes ./s21_grep -i -h -e apple -e error test1.txt test2.txt test3.txt test4.txt
    empty
    valgrind --tool=memcheck --leak-check=yes ./s21_grep -i -h -e apple -e error test1.txt test2.txt test3.txt test4.txt 2>&1 | grep -q "ERROR SUMMARY: 0" && echo "    Memory test: OK" || echo "    Memory test: FAIL"
 
    grepExpected=$(grep -i -h -e apple -e error test1.txt test2.txt test3.txt test4.txt 2>&1 | tr -d '\0')
    grepOutput=$(./s21_grep -i -h -e apple -e error test1.txt test2.txt test3.txt test4.txt 2>&1 | tr -d '\0')

    if [[ "$grepExpected" != "$grepOutput" ]]; then
        echo "error: ./s21_grep -i -h -e apple -e error test1.txt test2.txt test3.txt test4.txt"
        empty
        echo "    Functional test: FAIL"
        empty
        echo "Result for test #13: 0"
        divider
        return 1
    fi
    empty
    echo "    Functional test: OK"
    empty
    echo "Result for test #13: 1"
    divider
}

multiFlags_3() {
    divider
    empty
    echo "Test #14: -n -s -e flags, Name: ./s21_grep -n -s -e apple -e error test1.txt test2.txt test3.txt test4.txt missing_file.txt"
    empty
    echo "Test output:"
    valgrind --tool=memcheck --leak-check=yes ./s21_grep -n -s -e apple -e error test1.txt test2.txt test3.txt test4.txt missing_file.txt
    empty
    valgrind --tool=memcheck --leak-check=yes ./s21_grep -n -s -e apple -e error test1.txt test2.txt test3.txt test4.txt missing_file.txt 2>&1 | grep -q "ERROR SUMMARY: 0" && echo "    Memory test: OK" || echo "    Memory test: FAIL"
 
    grepExpected=$(grep -n -s -e apple -e error test1.txt test2.txt test3.txt test4.txt missing_file.txt 2>&1 | tr -d '\0')
    grepOutput=$(./s21_grep -n -s -e apple -e error test1.txt test2.txt test3.txt test4.txt missing_file.txt 2>&1 | tr -d '\0')

    if [[ "$grepExpected" != "$grepOutput" ]]; then
        echo "error: ./s21_grep -n -s -e apple -e error test1.txt test2.txt test3.txt test4.txt missing_file.txt"
        empty
        echo "    Functional test: FAIL"
        empty
        echo "Result for test #14: 0"
        divider
        return 1
    fi
    empty
    echo "    Functional test: OK"
    empty
    echo "Result for test #14: 1"
    divider
}

multiFlags_4() {
    divider
    empty
    echo "Test #15: -c -v -f flags, Name: ./s21_grep -c -v -f patterns.txt test1.txt test2.txt test3.txt test4.txt"
    empty
    echo "Test output:"
    valgrind --tool=memcheck --leak-check=yes ./s21_grep -c -v -f patterns.txt test1.txt test2.txt test3.txt test4.txt
    empty
    valgrind --tool=memcheck --leak-check=yes ./s21_grep -c -v -f patterns.txt test1.txt test2.txt test3.txt test4.txt 2>&1 | grep -q "ERROR SUMMARY: 0" && echo "    Memory test: OK" || echo "    Memory test: FAIL"
 
    grepExpected=$(grep -c -v -f patterns.txt test1.txt test2.txt test3.txt test4.txt 2>&1 | tr -d '\0')
    grepOutput=$(./s21_grep -c -v -f patterns.txt test1.txt test2.txt test3.txt test4.txt 2>&1 | tr -d '\0')

    if [[ "$grepExpected" != "$grepOutput" ]]; then
        echo "error: ./s21_grep -c -v -f patterns.txt test1.txt test2.txt test3.txt test4.txt"
        empty
        echo "    Functional test: FAIL"
        empty
        echo "Result for test #15: 0"
        divider
        return 1
    fi
    empty
    echo "    Functional test: OK"
    empty
    echo "Result for test #15: 1"
    divider
}

bigFile() {
    divider
    empty
    echo "Test #16: large file test, Name: ./s21_grep -c -i -e apple -e lInE test1.txt test2.txt test3.txt test4.txt test6.txt"
    empty
    echo "Test output:"
    valgrind --tool=memcheck --leak-check=yes ./s21_grep -c -i -e apple -e lInE test1.txt test2.txt test3.txt test4.txt test6.txt
    empty
    valgrind --tool=memcheck --leak-check=yes ./s21_grep -c -i -e apple -e lInE test1.txt test2.txt test3.txt test4.txt test6.txt 2>&1 | grep -q "ERROR SUMMARY: 0" && echo "    Memory test: OK" || echo "    Memory test: FAIL"
 
    grepExpected=$(grep -c -i -e apple -e lInE test1.txt test2.txt test3.txt test4.txt test6.txt 2>&1 | tr -d '\0')
    grepOutput=$(./s21_grep -c -i -e apple -e lInE test1.txt test2.txt test3.txt test4.txt test6.txt 2>&1 | tr -d '\0')

    if [[ "$grepExpected" != "$grepOutput" ]]; then
        echo "error: ./s21_grep -c -i -e apple -e lInE test1.txt test2.txt test3.txt test4.txt test6.txt"
        empty
        echo "    Functional test: FAIL"
        empty
        echo "Result for test #16: 0"
        divider
        return 1
    fi
    empty
    echo "    Functional test: OK"
    empty
    echo "Result for test #16: 1"
    divider
}

bonus_1() {
    divider
    empty
    echo "Test #17: -iv flag test, Name: ./s21_grep -iv apple test1.txt test2.txt test3.txt"
    empty
    echo "Test output:"
    valgrind --tool=memcheck --leak-check=yes ./s21_grep -iv apple test1.txt test2.txt test3.txt
    empty
    valgrind --tool=memcheck --leak-check=yes ./s21_grep -iv apple test1.txt test2.txt test3.txt 2>&1 | grep -q "ERROR SUMMARY: 0" && echo "    Memory test: OK" || echo "    Memory test: FAIL"
 
    grepExpected=$(grep -iv apple test1.txt test2.txt test3.txt 2>&1 | tr -d '\0')
    grepOutput=$(./s21_grep -iv apple test1.txt test2.txt test3.txt 2>&1 | tr -d '\0')

    if [[ "$grepExpected" != "$grepOutput" ]]; then
        echo "error: ./s21_grep -iv apple test1.txt test2.txt test3.txt"
        empty
        echo "    Functional test: FAIL"
        empty
        echo "Result for test #17: 0"
        divider
        return 1
    fi
    empty
    echo "    Functional test: OK"
    empty
    echo "Result for test #17: 1"
    divider
}

bonus_2() {
    divider
    empty
    echo "Test #17: -in flag test, Name: ./s21_grep -in apple test1.txt test2.txt test3.txt"
    empty
    echo "Test output:"
    valgrind --tool=memcheck --leak-check=yes ./s21_grep -in apple test1.txt test2.txt test3.txt
    empty
    valgrind --tool=memcheck --leak-check=yes ./s21_grep -in apple test1.txt test2.txt test3.txt 2>&1 | grep -q "ERROR SUMMARY: 0" && echo "    Memory test: OK" || echo "    Memory test: FAIL"
 
    grepExpected=$(grep -in apple test1.txt test2.txt test3.txt 2>&1 | tr -d '\0')
    grepOutput=$(./s21_grep -in apple test1.txt test2.txt test3.txt 2>&1 | tr -d '\0')

    if [[ "$grepExpected" != "$grepOutput" ]]; then
        echo "error: ./s21_grep -in apple test1.txt test2.txt test3.txt"
        empty
        echo "    Functional test: FAIL"
        empty
        echo "Result for test #17: 0"
        divider
        return 1
    fi
    empty
    echo "    Functional test: OK"
    empty
    echo "Result for test #17: 1"
    divider
}

# -e +
# -i +
# -v +
# -c +
# -l +
# -n +
# -h +
# -s +
# -f +
# -o +

# -i -c -e apple -e error test1.txt test2.txt test3.txt test4.txt +
# -c -h -e apple -e error test1.txt test2.txt test3.txt test4.txt +
# -n -s -e apple -e error test1.txt test2.txt test3.txt test4.txt missing_file.txt +
# -c -v -f patterns.txt test1.txt test2.txt test3.txt test4.txt

# -c -i -e LARGE -e line test1.txt test2.txt test3.txt test4.txt test6.txt


cleanUp() {
    rm -f test1.txt test2.txt test3.txt test4.txt patterns.txt test6.txt
    rm -f s21_grep
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
noFlag
empty
iFlag
empty
vFlag
empty
cFlag
empty
lFlag
empty
nFlag
empty
hFlag
empty
sFlag
empty
fFlag
empty
oFlag
empty
eFlag
empty
multiFlags_1
empty
multiFlags_2
empty
multiFlags_3
empty
multiFlags_4
empty
bigFile
empty
bonus_1
empty
bonus_2
cleanUp
