# DotNetNuke (DNN) to WordPress wpForo Migration

## Overview
This repository provides a step-by-step guide and all necessary files for migrating data from a DotNetNuke (DNN) forum (ActiveForum) to a WordPress site running the wpForo plugin. The migration process includes creating tables in SQL Server, transferring data to MySQL, and integrating data with wpForo. The guide assumes familiarity with SQL Server Management Studio (SSMS) and MySQL.

## Project Structure
- **1.SSMS**: SQL scripts for creating wpForo-compatible tables in SSMS.
- **2.MySQL**: SQL scripts for merging the transferred ActiveForum data with your wpForo installation.

## Setup Steps
[Guide to Transfer tables from SSMS to MySQL and merge them](0.Documentation/2%20%20Transfering%20data%20from%20DNN%20activeForum%20to%20WpForo.md)
1. **Preparing Tables in SSMS**:   
   Run the scripts in the **1.SSMS** folder to create tables matching the wpForo format. This step assumes your DNN database is named **Simorgh975**.

2. **Migrating Data to MySQL**: 
   This document (coming soon) will guide you through using the MySQL Migration Wizard to transfer the data to MySQL.

3. **Merging Data with wpForo**:
   Run the scripts in the **2.MySQL** folder to combine the ActiveForum data into wpForo’s tables.

## Additional Setup Documentation
- **PHP Installation using IIS** [Setting Up PHP using IIS](0.Documentation/0.0%20PHP%20intsallation%20using%20IIS.md)
 step by step of PHP Installation using IIS
- **WordPress Installation and Theme Setup**: [Setting Up WordPress](0.Documentation/0.1%20WP%20and%20MySQL%20installation.md)  
   Instructions for installing WordPress, setting up the Astra theme, and preparing for wpForo.
  
- **wpForo Installation and Configuration**: [Configuring wpForo](0.Documentation/1%20wpforo%20Setup.md)  
   Detailed steps to install wpForo, configure necessary permissions, and solve common issues.

- **Troubleshooting Common Issues**: [Common Bug Fixes](0.Documentation/1%20wpforo%20Setup.md)  
   Solutions for common issues, such as fixing 404 errors and enabling embedded attachments.

## Repository Contents
- **README.md**: Main overview and setup information.
- **Documentation**: Folder containing all supporting documentation and setup files.
- **SQL Scripts**: SQL files for setting up tables and transferring data between SSMS and MySQL.

---

**Note**: For specific setup instructions, refer to the relevant documents linked above.
