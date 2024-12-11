#!/bin/bash

db_name="$1"
table_name="$2"
SCRIPT_DIR="$(dirname "$(realpath "$BASH_SOURCE")")"
DATABASES_DIR="$SCRIPT_DIR/databases"
DB_PATH="$DATABASES_DIR/$db_name/"


allowed_data_types=("INT" "VARCHAR" "DATE" "FLOAT" "BOOLEAN")

read -p "Enter the number of columns: " num_columns

table_file="$DB_PATH/$table_name.txt"
touch "$table_file"

table_name_metadata="table_name_metadata.txt"
metadata_file="$DB_PATH/$table_name_metadata"
touch "$metadata_file"

echo "Enter details for each column:"

for ((i = 1; i <= num_columns; i++)); do
    echo "Column #$i"
    read -p "Enter column name: " column_name
    
    while true; do
        read -p "Enter column datatype for column $i (e.g., INT, VARCHAR, DATE, FLOAT, BOOLEAN): " column_type
        
        # Check if the entered datatype is valid
        if [[ " ${allowed_data_types[@]} " =~ " $column_type " ]]; then
            break
        else
            echo "Invalid datatype! Please enter one of the following: ${allowed_data_types[@]}"
        fi
    done
    
    echo "$column_name:$column_type" >> "$metadata_file"
    column_names+=("$column_name")
done

echo "$(IFS=','; echo "${column_names[*]}")" > "$table_file"

echo "Table '$table_name' created successfully with $num_columns columns."
echo "Metadata saved in '$table_name_metadata.txt'."

echo "Table Metadata:"
cat "$metadata_file"

