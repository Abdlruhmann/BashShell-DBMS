#!/bin/bash

# Global Variables
SCRIPT_DIR="$(dirname "$(realpath "$BASH_SOURCE")")"
DATABASES_DIR="$SCRIPT_DIR/databases"
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
			"Connect To Databases") 
			clear
			connect_database
			break
			;;
			"Drop Database") echo 
			clear
			drop_database
			break
			;;
			"Quit") 
				echo "Exiting the program.."
				exit 0
				;;
			*) echo "Invalid Choice."
			;;
		esac
	done
}

# Create Database
create_database() {

	if [[ ! -d "$DATABASES_DIR" ]]; then
        echo "Database directory does not exist. Creating it..."
        mkdir "$DATABASES_DIR"
		echo "Created databases dir successfully in current directory." 
    fi

    read -p "Enter a name for the database: " database_name


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

	read -p "Enter database name to delete: " db_name
	db_dir="$DATABASES_DIR/$db_name"

	if [ ! -d "$db_dir" ]; then
		echo "Error: Database $db_name not found!"
		return
	fi

	read -p "Are you sure want to delete $db_name ? (y/n): " choice	
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

# Connect Database
connect_database(){
	echo "==================================" 
	echo " Available Databases To Connect " 
	echo "=================================="
	count=0
	databased=()
	for dir in "$DATABASES_DIR"/*/; do
		if [ -d "$dir" ]; then
			count=$((count + 1))
			dir_name=$(basename "$dir")
			databases+=("$dir_name")
			echo "$count. $dir_name"
		fi
	done
	echo "=================================="

	if [ $count -eq 0 ]; then
		echo "No Available Databases."
		return
	fi

	read -p "Enter the number of the database you want to connect: " choice

	if [[ "$choice" -ge 1 && "$choice" -le "$count" ]]; then
		selected_db="${databases[$choice-1]}"
		clear
		db_menu "$selected_db"
	else 
        echo "Invalid selection. Please choose a valid database number."
		read -p "Press Enter to try again."
		clear
		connect_database
	fi
}

# Database Menu
db_menu(){
	db_name="$1"
	echo "=================================="
	echo "Connected To Database $db_name "
	echo "=================================="
	
	select option in "Create Table" "List Tables" "Insert into Table" "Select From Table" "Delete From Table" "Update Table" "Main Menu"
	do 
		case $option in 
			"Create Table")
			clear
			create_table "$db_name"
			break
			;;
			"List Tables") echo "Hi from List tables"
			break
			;;
			"Insert into Table") echo "Hi from insert into"
			break
			;;
			"Delete From Table") echo "Hi from Delete from"
			break
			;;
			"Update Table") echo "Hi from update"
			break
			;;
			"Main Menu")
			clear
			main_menu
			;;
		esac
	done 
			

}

# Create Table
create_table() {
	db_name="$1"
	DB_PATH="$DATABASES_DIR/$db_name/"
	
	#! 
	if [[ ! -d "$DB_PATH" ]]; then
        echo "Database $db_name does not exist. Please create the database first."
        return
    fi

	read -p "Enter a name for the table: " table_name

	if [[ -f "$DB_PATH/$table_name.txt" ]]; then
		echo "This Name Already Exists!"
	else
		touch "$DB_PATH/$table_name.txt"
		echo "Table '$table_name' created successfully."
	fi
	read -p "Press Enter to return to your database page..."
    clear
    db_menu "$db_name"
}

# Start the main menu
clear
main_menu