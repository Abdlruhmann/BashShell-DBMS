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
				break
				;;
			*) echo "Invalid Choice."
			;;
		esac
	done
}

# Create Database
create_database() {
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
	echo "Welcome Here you can manage Database $1 "
}

# Start the main menu
clear
main_menu