# SKS National Bank – DATA2201 Database Project

## Course Information
- **Course:** DATA2201 – Relational Databases  
- **Institution:** Bow Valley College  
- **Project Type:** Group Project  
- **Phase Covered:** Phase 1 (Database Design) & Phase 2 (Advanced Database Operations)

## Group Members
- Dylan Retana (Group Leader)
- Freddy Munini
- Ime Iquoho

---

## Project Overview
This project represents the design and implementation of a relational database system for **SKS National Bank**.  
The goal of the project is to demonstrate proper database design, normalization, SQL implementation, and advanced database features using **Microsoft SQL Server**.

The repository includes:
- A fully normalized database schema based on a validated ERD
- Data population scripts
- Prepared queries
- Advanced database features such as users, permissions, triggers, JSON data, and spatial data
- Validation and test evidence screenshots
- A full database backup file

---

## Technologies Used
- Microsoft SQL Server
- SQL Server Management Studio (SSMS)
- T-SQL
- GitHub for version control
- Lucidchart (ERD design)

---

## Repository Structure

| File / Folder | Description |
|---------------|------------|
| `01_create_database.sql` | Creates the SKS National Bank database and tables |
| `02_populate_database.sql` | Inserts sample data into all tables |
| `03_prepared_queries.sql` | Required prepared queries for Phase 1 |
| `04_create_users.sql` | Creates database users and roles |
| `04_Create_Users_and_Permissions_Test.png` | Evidence of user/permission setup |
| `05_create_triggers.sql` | Audit triggers for tracking data changes |
| `06_create_json_spatial.sql` | JSON storage and spatial data implementation |
| `07_additional_validation_tests.sql` | Additional validation and integrity tests |
| `*_Test.png` files | Execution and validation screenshots |
| `Banking_System_ERD_*.png` | Final ERD diagram |
| `DATA2201_Phase1_Final_Report_*.pdf` | Phase 1 final report |
| `DATA2201_SQL_References.txt` | References for SQL functions and features |
| `SKS_National_Bank_GroupJ_Final.bak` | Full database backup file |

---

## Database Features Implemented

### Phase 1
- Fully normalized relational schema
- Primary keys and foreign key relationships
- Sample data population
- Prepared queries
- ERD validation

### Phase 2
- Role-based users and permissions
- Audit logging using triggers
- JSON data storage for customer preferences
- Spatial data for branch locations
- Additional validation queries
- Full database backup

---

## How to Run the Project

1. Open **SQL Server Management Studio**
2. Execute scripts in the following order:
01_create_database.sql
02_populate_database.sql
03_prepared_queries.sql
04_create_users.sql
05_create_triggers.sql
06_create_json_spatial.sql
07_additional_validation_tests.sql

3. Review the included `*_Test.png` files for execution evidence
4. (Optional) Restore the database using:
SKS_National_Bank_GroupJ_Final.bak


---

## Notes for Evaluation
- All scripts were executed successfully in SSMS
- The database schema matches the submitted ERD
- Screenshots are provided as execution evidence
- References are documented in `DATA2201_SQL_References.txt`

---

## References
See **DATA2201_SQL_References.txt** for all external references used in this project.

