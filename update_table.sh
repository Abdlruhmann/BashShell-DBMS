#!/bin/bash

echo "==================================" 
echo " Available Tables in Database $1 " 
echo "=================================="

DATABASES_DIR="$2"
db_name="$1"

# Step 1: List all tables
count=0
tables=()
for file in "$DATABASES_DIR/$db_name"/*; do
    if [ -f "$file" ] && [[ ! "$file" =~ _metadata\.txt$ ]]; then
        count=$((count + 1))
        file_name=$(basename "$file")
        echo "$count. ${file_name%.txt}"
        echo "------------------"
        tables+=("${file_name%.txt}")
    fi
done

if [ $count -eq 0 ]; then
    echo "No Tables Yet."
    exit 1
fi

read -p "Choose Table To Update: " choice

if [[ "$choice" -ge 1 && "$choice" -le "$count" ]]; then
    selected_table="${tables[$choice-1]}"
    selected_table_file="$DATABASES_DIR/$db_name/${selected_table}.txt"
    selected_table_metadata="$DATABASES_DIR/$db_name/${selected_table}_metadata.txt"
else 
    echo "Invalid Choice!"
    exit 1
fi

if [[ ! -f "$selected_table_file" || ! -f "$selected_table_metadata" ]]; then
    echo "Table or metadata file does not exist."
    exit 1
fi

# Step 2: Check if the table has rows
row_count=$(wc -l < "$selected_table_file")
if [[ $row_count -le 1 ]]; then
    echo "The table has no rows to update."
    exit 1
fi

# Step 3: Read metadata to get column names
declare -a column_names
declare -A column_indices
index=1
while IFS=":" read -r column_name datatype; do 
    column_names+=("$column_name")
    column_indices["$column_name"]=$index
    index=$((index + 1))
done < "$selected_table_metadata"

# Display columns
echo "Columns in the table:"
for ((i = 0; i < ${#column_names[@]}; i++)); do
    echo "$((i + 1)). ${column_names[$i]}"
done

# Step 4: Ask user to set condition
read -p "Enter condition to match rows for update (leave blank to update all rows): " condition

# Parse the condition
if [[ -n "$condition" ]]; then
    for column in "${column_names[@]}"; do
        col_index="${column_indices[$column]}"
        condition=$(echo "$condition" | sed "s/\b$column\b/\$$col_index/g")
    done
else
    condition="1" # Match all rows if no condition is specified
fi

# Step 5: Ask for columns and values to update
declare -A updates
while true; do
    read -p "Enter the column to update (or press Enter to finish): " update_column
    if [[ -z "$update_column" ]]; then
        break
    fi

    if [[ -n "${column_indices[$update_column]}" ]]; then
        read -p "Enter the new value for $update_column: " new_value
        updates["${column_indices[$update_column]}"]="$new_value"
    else
        echo "Invalid column name. Please try again."
    fi
done

if [[ ${#updates[@]} -eq 0 ]]; then
    echo "No updates specified. Aborting."
    exit 1
fi

# Step 6: Check for duplicate primary key and update rows matching the condition
primary_key_column="ID"  # Define your primary key column

# Collect all existing primary key values
declare -A primary_keys
while IFS=',' read -r line; do
    pk_value=$(echo "$line" | cut -d',' -f"${column_indices[$primary_key_column]}")
    primary_keys["$pk_value"]=1
done < <(tail -n +2 "$selected_table_file")  # Skip header row

# Initialize flag to check if any rows match the condition
rows_matched=false

awk_command='NR == 1 { print $0; next }'
awk_command+='NR > 1 { if ('$condition') { matched = 1;'

# Loop through updates to construct the `awk` command
for col_index in "${!updates[@]}"; do
    new_value="${updates[$col_index]}"

    # Check if updating the primary key
    if [[ "${column_names[$col_index-1]}" == "$primary_key_column" ]]; then
        # Validate for duplicates
        if [[ -n "${primary_keys[$new_value]}" ]]; then
            echo "Error: Value $new_value for $primary_key_column already exists. Update aborted."
            exit 1
        fi
    fi

    awk_command+="\$${col_index}=\"${new_value}\"; "
done

awk_command+='} print $0 }'
awk_command+='END { if (!matched) print "No rows matched the condition." }'

# Apply the command
awk -F',' -v OFS=',' "$awk_command" "$selected_table_file" > "$selected_table_file.tmp" && mv "$selected_table_file.tmp" "$selected_table_file"

if [[ "$rows_matched" == false ]]; then
    echo "No rows matched the condition."
    exit 1
fi

echo "Rows have been updated successfully."
