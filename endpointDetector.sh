#!/bin/bash

# Check if the required arguments are provided
if [ $# -lt 3 ]; then
    echo "Usage: $0 <pattern_file> <output_file> <file1.js> [<file2.js> ...]"
    exit 1
fi

pattern_file="$1"
output_file="$2"
shift 2
files=("$@")

# Check if the pattern file exists
if [ ! -f "$pattern_file" ]; then
    echo "Error: Pattern file '$pattern_file' not found."
    exit 1
fi

# Clear the output file if it exists
> "$output_file"

# Function to search patterns in a prettified JS file
search_patterns() {
    local file="$1"
    local temp_file=$(mktemp)

    # Prettify the JS file
    js-beautify "$file" > "$temp_file"

    # Search for patterns in the prettified file
    while IFS= read -r pattern || [[ -n "$pattern" ]]; do
        # Trim leading and trailing whitespace
        pattern=$(echo "$pattern" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
        
        # Skip empty lines
        [ -z "$pattern" ] && continue

        grep --line-number "$pattern" "$temp_file" >> "$output_file"
    done < "$pattern_file"

    # Remove the temporary file
    rm "$temp_file"
}

# Process each file
for file in "${files[@]}"; do
    if [[ -f "$file" && "$file" == *.js ]]; then
        search_patterns "$file"
    else
        echo "Warning: File '$file' is not a JavaScript file or doesn't exist. Skipping."
    fi
done

echo "Search completed. Results saved in $output_file"
