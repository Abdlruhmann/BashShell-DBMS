#!/bin/bash

# Global Variables
DATABASES_DIR="/home/dodger/Bash_Project/databases"
PS3="Please enter your choice: "

# Main Menu 
main_menu() {

	select option in "Create Database" "List Databases" "Connect To Databases" "Drop Database" "Quit"
	do 
		case $option in
			"Create Database") 
			clear
			create_database
			break
			;;
			"List Databases")
			clear
			list_databases
			break
			;;
			"Connect To Databases") echo "Hi from connect to databases"
			break
			;;
			"Drop Database") echo 
			clear
			drop_database
			break
			;;
			"Quit") 
				echo "Exiting the program.."
				break
				;;
			*) echo "Invalid Choice."
			;;
		esac
	done
}

# Create Database
create_database() {
    read -p "Please enter a name for the database: " database_name

    #if find "$DATABASES_DIR" -type f -name "$database_name.txt" > /dev/null 2>&1; then
	if [ -d "$DATABASES_DIR/$database_name" ]; then 
        echo "This Name Already Exists!"
    else
        mkdir "$DATABASES_DIR/$database_name"
        echo "Database '$database_name' created successfully."
    fi

    read -p "Press Enter to return to the main menu..."
    clear
    main_menu
}

# List Databases
list_databases() {
	echo "==================================" 
	echo " Available Databases " 
	echo "=================================="
	count=0
	for dir in "$DATABASES_DIR"/*/; do
		if [ -d "$dir" ]; then
			count=$((count + 1))
			dir_name=$(basename "$dir")
			echo "$count. $dir_name"
		fi
	done

	if [ $count -eq 0 ]; then
		echo "No Databases Yet."
	fi

	echo "==================================" 
	echo
	read -p "Press Enter to return to the main menu..." 
	clear 
	main_menu
}

# Drop Database
drop_database() {

	read -p "Please enter database name to delete: " db_name
	db_dir="$DATABASES_DIR/$db_name"

	if [ ! -d "$db_dir" ]; then
		echo "Error: Database $db_name not found!"
		return
	fi

	read -p "Are you sure want to delete $db_name ? (y/n)" choice	
	if [[ "$choice" == 'y' || "$choice" == 'Y' ]]; then
		rm -rf "$db_dir"
		echo "Database $db_name has beed deleted."
		read -p "Press Enter to return to the main menu..." 
		clear 
		main_menu
	else 
		echo "Database deletion cancelled."
		read -p "Press Enter to return to the main menu..." 
		clear 
		main_menu
	fi
}

# Start the main menu
clear
main_menu