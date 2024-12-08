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
			"List Databases") echo "Hi from list databases"
			break
			;;
			"Connect To Databases") echo "Hi from connect to databases"
			break
			;;
			"Drop Database") echo "Hi from drop database"
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

# Start the main menu
clear
main_menu