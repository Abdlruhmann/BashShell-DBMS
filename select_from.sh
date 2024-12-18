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

read -p "Choose Table To Select From: " choice

if [[ "$choice" -ge 1 && "$choice" -le "$count" ]]; then
	selected_table="${tables[$choice-1]}"
	selected_table_file="$DATABASES_DIR/$db_name/${selected_table}.txt"
    selected_table_metadata="$DATABASES_DIR/$db_name/${selected_table}_metadata.txt"
fi

if [[ ! -f "$selected_table_file" || ! -f "$selected_table_metadata" ]]; then
    echo "Table or metadata file is not exits"
    exit 1
fi 


declare -a column_names
declare -A column_indices 
index=1

while IFS=":" read -r column_name datatype; do 
    column_names+=("$column_name")
    column_indices["$column_name"]=$index
    index=$((index+1))
done < "$selected_table_metadata"

echo "Avaliable Columns: ${column_names[*]}"
read -p "Enter columns you want to select (user * for all) seperated by speace: " input_columns

if [[ "$input_columns" == "*" ]]; then
    selected_columns=("${column_names[@]}")
else 
    read -a selected_columns <<< "$input_columns"
    
    for col in "${selected_columns[@]}"; do
        if [[ ! " ${column_names[*]} " =~ " $col " ]]; then
                echo "Invalid column: $col"
                exit 1
        fi 
    done 
fi 

# conditioning 
read -p "Enter condtion (leave it blank for no condition): " condition

if [[ -n "$condition" ]]; then
    # Replace column names in the condition with their respective indices
    for column in "${column_names[@]}"; do
        col_index="${column_indices[$column]}"
        condition=$(echo "$condition" | sed "s/\b$column\b/\$$col_index/g")
    done
fi

# Start constructing the awk command
awk_command='BEGIN {'
awk_command+='print "---------------------------------------------";'

# Adding header to the table for selected columns
for column in "${selected_columns[@]}"; do
    awk_command+='printf "| %-15s ", "'$column'"; '
done
awk_command+='print "|";'
awk_command+='print "---------------------------------------------"; }'

# Skip the first row (header) and add the data for selected columns
awk_command+='NR > 1 {'

# If a condition is provided, add it as a filter
if [[ -n "$condition" ]]; then
    awk_command+="if ($condition) {"
fi

# Handle column selection: print only selected columns
for column in "${selected_columns[@]}"; do
    col_index="${column_indices[$column]}"
    awk_command+='printf "| %-15s ", $'$col_index'; '
done
awk_command+='print "|";'

# Close the condition block
if [[ -n "$condition" ]]; then
    awk_command+='}'
fi

awk_command+='}'

# Add the footer to the table
awk_command+='END { print "---------------------------------------------" }'

# Apply the final awk command to the selected table file
awk -F',' "$awk_command" "$selected_table_file"
