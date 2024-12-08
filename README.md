# BashShell-DBMS: Command-Line Database Management System

This project is a simple **Database Management System (DBMS)** built using Bash shell scripting. It allows users to create, manage, and interact with databases and tables directly from the command line. The DBMS stores data on the hard disk in directories and files.

The application features an easy-to-use menu-based interface for interacting with the database. As a bonus, it supports SQL code execution and a GUI interface (optional).

---

## Features:

### **Main Menu:**
- **Create Database**: Create a new database.
- **List Databases**: List all existing databases.
- **Connect To Database**: Connect to a specific database for further operations.
- **Drop Database**: Delete a database and its contents.

### **Database Menu (After Connecting to a Database):**
- **Create Table**: Create a new table within the connected database.
- **List Tables**: List all the tables in the connected database.
- **Drop Table**: Delete a table from the database.
- **Insert into Table**: Insert a new record (row) into a table.
- **Select From Table**: Retrieve and display records from a table.
- **Delete From Table**: Delete a record from a table.
- **Update Table**: Modify an existing record in a table.

---

## Requirements:
- **Bash shell**: This project uses basic shell scripting, so you need a Bash-compatible shell environment.
- **Unix-based system**: Linux or macOS is recommended.

---

### **How it Works:**
- **Databases** are represented as directories under the `databases/` folder.
- **Tables** are stored as files within each database directory.
- The first line of each table file contains column names and data types.
- Data rows are stored in subsequent lines.
- Users can perform CRUD (Create, Read, Update, Delete) operations on tables and rows using a simple text interface.

---

## Usage:

### 1. **Clone the Repository:**
```bash
git clone https://github.com/yourusername/BashShell-DBMS.git
cd BashShell-DBMS
- Run the follwoing commands:
chmod +x dbms.sh 
./dbms.sh


