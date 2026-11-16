#!/bin/bash

# Compare file pairs and save only those with differences.
for number in 1 2 3 4; do
    testcase_dir="Testcase$number"
    diff_dir="Testcase${number}Diff"

    # Remove old generated results before comparing again.
    rm -rf -- "$diff_dir"

    for first_file in "$testcase_dir"/*.1.txt; do
        second_file="${first_file%.1.txt}.2.txt"

        # Skip identical pairs.
        if diff -u "$first_file" "$second_file" > /dev/null; then
            continue
        else
            status=$?

            # diff returns 1 for differences and greater than 1 for errors.
            if [ "$status" -ne 1 ]; then
                echo "Could not compare $first_file and $second_file" >&2
                exit 1
            fi
        fi

        # Create the output directory only when a pair differs.
        mkdir -p -- "$diff_dir" || exit 1

        filename="${first_file##*/}"
        output_file="${filename%.1.txt}Diff.txt"

        diff -u "$first_file" "$second_file" >| "$diff_dir/$output_file"
        status=$?

        if [ "$status" -ne 1 ]; then
            echo "Could not save differences for $first_file" >&2
            exit 1
        fi
    done
done

exit 0