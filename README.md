Online Store - E-Commerce Platform THIS ARCHIVE CONTAINS:

Application source code.

SQL scripts for structure generation and data population.

Project documentation. To run the application, you need:

Microsoft SQL Server 2014 Express.

SQL Server Management Studio (SSMS).

Visual Studio Code.

Python (version 3.x installed and added to PATH). Download: https://www.microsoft.com/en-us/download/details.aspx?id=42299 Then download requirements using: pip install -r requirements.txt The scripts are located in the folder: /sql_scripts STEP 1: Database Creation and Population

Open SSMS and connect to the server (e.g., localhost or .\SQLEXPRESS).

File -> Open -> File -> Select "01create_db_sp_users.sql".

Press the "Execute" button (F5).

This script will create the "Website_Database" database, tables, and stored procedures.

File -> Open -> File -> Select "02populare_tabele.sql".

Ensure that the "Website_Database" database is selected in the top-left dropdown.

Press the "Execute" button (F5). Open the source code from the archive or clone the repository locally using: https://github.com/Dragos-Coticeru/Laptop-Webstore.git STEP 2: Connection Configuration Navigate to /app/services.py

Modify "Server=" with your local instance name. Common examples:

"Server=.;Database=Website_Database;Trusted_Connection=True;"

"Server=localhost;Database=Website_Database;Trusted_Connection=True;"

"Server=.\SQLEXPRESS;Database=Website_Database;Trusted_Connection=True;" STEP 3: Running Navigate to the application root level using cd Run the application using python app.py Role: ADMIN (Access to reports and stock management) Email: admin@test.com Password: Admin123! Role: CUSTOMER (Can place orders) Email: user@test.com Password: User123! Role: VIP CUSTOMER (Rich order history) Email: vip@test.com Password: User123!
