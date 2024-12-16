#!/bin/bash

db_name="$1"
table_name="$2"
SCRIPT_DIR="$(dirname "$(realpath "$BASH_SOURCE")")"
DATABASES_DIR="$SCRIPT_DIR/databases"
DB_PATH="$DATABASES_DIR/$db_name/"


allowed_data_types=("INT" "VARCHAR" "DATE" "FLOAT" "BOOLEAN")

while true; do
    read -p "Enter the number of columns(Including Primary Key): " num_columns
    if [[ -n "$num_columns" && "$num_columns" =~ ^[1-9][0-9]*$ ]]; then
        break
    else
        echo "Invalid: number of columns cannot be blank and must be number greater than 0"
    fi
done

table_file="$DB_PATH/$table_name.txt"
touch "$table_file"

table_name_metadata="${table_name}_metadata.txt"
metadata_file="$DB_PATH/$table_name_metadata"
touch "$metadata_file"

echo "Enter details for each column:"

for ((i = 1; i <= num_columns; i++)); do
    while true; do 
        if [[ $i -eq 1 ]]; then
            echo "Column #$i"
            read -p "Enter The Name for Primary Key: " column_name
        else 
            echo "Column #$i"
            read -p "Enter column name: " column_name
        fi

        if [[ -n "$column_name" ]] && [[ ! "$column_name" =~ ^[0-9]+$ ]]; then
            break
        else
            if [[ $i -eq 1 ]]; then 
            echo "Primary Key Name cannot be NUll / Blank or number."
            else
            echo "Column Name cannot be blank or number."
            fi
        fi
    done
    
    while true; do
        if [[ $i -eq 1 ]]; then
            read -p "Enter datatype for Primary Key (INT preferred): " "column_type"
        else 
            read -p "Enter column datatype for column $i (e.g., INT, VARCHAR, DATE, FLOAT, BOOLEAN): " column_type
        fi
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

