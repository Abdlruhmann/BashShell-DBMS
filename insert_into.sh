        
SCRIPT_DIR="$(dirname "$(realpath "$BASH_SOURCE")")"
DATABASES_DIR="$2"
db_name="$1"

    echo "$DATABASE_DIR"
    echo "==================================" 
	echo " Available Tables in Database $1 " 
	echo "=================================="

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

	read -p "Choose Table To Insert Into: " choice

	if [[ "$choice" -ge 1 && "$choice" -le "$count" ]]; then
		selected_table="${tables[$choice-1]}"
		selected_table_file="$DATABASES_DIR/$db_name/$selected_table"
    	selected_table_metadata="$DATABASES_DIR/$db_name/${selected_table}_metadata.txt"

        declare -a column_names
        declare -a column_datatypes
        index=0
        while IFS=":" read -r column_name datatype; do
            column_names+=("$column_name")
            column_datatypes+=("$datatype")
            index=$((index + 1))
        done < "$selected_table_metadata"

        # Ask the user to input values for each column, and validate data types
        user_input_columns=()
        for i in "${!column_names[@]}"; do
            column_name="${column_names[$i]}"
            expected_datatype="${column_datatypes[$i]}"
            valid_input=false

            if [ "$i" -eq 0 ]; then # Auto-increment ID 
                last_line=$(tail -n 1 "${selected_table_file}.txt") 
                if [ -z "$last_line" ]; then 
                    next_id=1 
                else 
                    last_id=$(echo "$last_line" | awk -F, '{print $1}') 
                    next_id=$((last_id + 1)) 
                fi 
                user_input_columns+=("$next_id") 
                continue 
            fi

            while [ "$valid_input" == false ]; do
                read -p "Enter value for column '$column_name' of type '$expected_datatype': " user_input

                case "$expected_datatype" in
                    VARCHAR)
                        # Accept any non-empty string for VARCHAR
                        if [[ -n "$user_input" ]]; then
                            valid_input=true
                        else
                            echo "Invalid input: VARCHAR expects a non-empty string."
                        fi
                        ;;
                    INT)
                        # Validate integer input
                        if [[ "$user_input" =~ ^-?[0-9]+$ ]]; then
                            valid_input=true
                        else
                            echo "Invalid input: INT expects an integer."
                        fi
                        ;;
                    FLOAT)
                        # Validate float input
                        if [[ "$user_input" =~ ^-?[0-9]+\.[0-9]+$ ]]; then
                            valid_input=true
                        else
                            echo "Invalid input: FLOAT expects a float number."
                        fi
                        ;;
                    DATE)
                        # Validate date format (YYYY-MM-DD)
                        if [[ "$user_input" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
                            valid_input=true
                        else
                            echo "Invalid input: DATE expects a valid date in format YYYY-MM-DD."
                        fi
                        ;;
                     BOOLEAN) 
                        if [[ "$user_input" =~ ^(true|false|TRUE|FALSE)$ ]]; then 
                            valid_input=true 
                        else 
                            echo "Invalid input: BOOLEAN expects either true or false." 
                        fi 
                        ;;
                    *)
                        echo "Unknown datatype: $expected_datatype"
                        valid_input=true  # exit loop for unrecognized types (but you may add more validation here)
                        ;;
                esac
            done
            user_input_columns+=("$user_input")
        done


        # If all inputs are valid, write the new values to the table file
        echo "Inserting into table $selected_table..."
        echo "$(IFS=,; echo "${user_input_columns[*]}")" >> "${selected_table_file}.txt"
        echo "Data inserted successfully."

    else
        echo "Invalid selection. Please choose a valid table number."
        read -p "Press Enter to try again."
        clear
        insert_into "$1"
    fi
