# Transfering data from DNN activeForum to WpForo

In Last Step of transfering data to wordpress you should do steps as below:


## Run SQL Queries in SSMS:

- Go through all SQL scripts in the folder named "1.SSMS" in order. These queries create tables in SQL Server (SSMS) that match the wpForo table structure in MySQL, using your ActiveForum data as a base.
- Note: These queries assume that your DotNetNuke (DNN) database is named "Simorgh975".

## Setup Data Migration to MySQL:

- Configure the MySQL Migration Wizard to transfer the new database called "transfering" from SSMS to MySQL.
- (Details for this setup will be provided in a future step.)

## Merge Data with wpForo:

- Run the SQL scripts in the "2.MySQL" folder in order to combine your ActiveForum data into your wpForo tables. This will complete the migration.