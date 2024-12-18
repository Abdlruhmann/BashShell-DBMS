echo "==================================" 
echo " Available Tables in Database $1 " 
echo "=================================="

DATABASES_DIR="$2"
db_name="$1"

count=0
tables=()
for file in "$DATABASES_DIR/$db_name"/*; do
	if [ -f "$file" ]&& [[ ! "$file" =~ _metadata\.txt$ ]]; then
		count=$((count + 1))
		file_name=$(basename "$file")
		echo "$count. ${file_name%.txt}"
        echo "------------------"
		tables+=("${file_name%.txt}")
	fi
done

if [ $count -eq 0 ]; then
	echo "No Tables Yet."
fi

read -p "Choose Table To Delete From: " choice

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

# Read metadata to get column names
declare -a column_names
declare -A column_indices
index=1
while IFS=":" read -r column_name datatype; do 
    column_names+=("$column_name")
    column_indices["$column_name"]=$index
    index=$((index + 1))
done < "$selected_table_metadata"

# Ask the user to enter a condition
read -p "Enter condition (leave it blank for no condition): " condition

if [[ -z "$condition" ]]; then
    read -p "Are you sure you want to delete all rows? (y/n): " confirm
    if [[ "$confirm" != "y" ]]; then
        echo "Aborted deletion."
        exit 0
    fi
    awk 'NR == 1 { print $0 }' "$selected_table_file" > "$selected_table_file.tmp" && mv "$selected_table_file.tmp" "$selected_table_file"
    echo "All rows have been deleted."
else
    # Parse the condition
    for column in "${column_names[@]}"; do
        col_index="${column_indices[$column]}"
        condition=$(echo "$condition" | sed "s/\b$column\b/\$$col_index/g")
    done

    # Display matched rows
    matched_rows=$(awk -F',' '
    NR == 1 { header = $0 }
    NR > 1 { if ('"$condition"') print $0 }
    ' "$selected_table_file")

    if [[ -z "$matched_rows" ]]; then
        echo "No rows matched the condition."
        exit 1
    fi

    echo "The following rows will be deleted:"
    echo "$matched_rows"
    read -p "Are you sure you want to delete these rows? (y/n): " confirm
    if [[ "$confirm" != "y" ]]; then
        echo "Aborted deletion."
        exit 0
    fi

    # Delete rows matching the condition
    awk -F',' '
    NR == 1 { print $0 }
    NR > 1 { if (!('"$condition"')) print $0 }
    ' "$selected_table_file" > "$selected_table_file.tmp" && mv "$selected_table_file.tmp" "$selected_table_file"

    echo "Rows matching the condition have been deleted."
fi
