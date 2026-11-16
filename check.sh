#!/bin/bash

overall_status=0

for number in 1 2 3 4; do
    testcase_dir="Testcase$number"
    diff_dir="Testcase${number}Diff"

    testcase_ok=1
    has_differences=0

    for first_file in "$testcase_dir"/*.1.txt; do
        second_file="${first_file%.1.txt}.2.txt"

        filename="${first_file##*/}"
        output_file="${filename%.1.txt}Diff.txt"
        output_path="$diff_dir/$output_file"

        if diff -u "$first_file" "$second_file" > /dev/null; then
            # Identical pairs must not have an output file.
            if [ -e "$output_path" ]; then
                testcase_ok=0
            fi
        else
            status=$?

            if [ "$status" -ne 1 ]; then
                testcase_ok=0
                continue
            fi

            has_differences=1

            if [ ! -f "$output_path" ]; then
                testcase_ok=0
                continue
            fi

            # Skip filename/timestamp headers in both reports.
            if ! cmp -s \
                <(diff -u "$first_file" "$second_file" | tail -n +3) \
                <(tail -n +3 "$output_path"); then
                testcase_ok=0
            fi
        fi
    done

    if [ "$has_differences" -eq 1 ]; then
        if [ ! -d "$diff_dir" ]; then
            testcase_ok=0
        fi
    else
        if [ -e "$diff_dir" ]; then
            testcase_ok=0
        fi
    fi

    if [ "$testcase_ok" -eq 1 ]; then
        echo "Testcase$number: PASS"
    else
        echo "Testcase$number: FAIL"
        overall_status=1
    fi
done

exit "$overall_status"