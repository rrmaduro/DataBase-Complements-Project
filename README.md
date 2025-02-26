# Project Development - AdventureWorks ERP System

## Introduction

The Adventure group, which included the cycling equipment company AdventureWorks, underwent a restructuring process.  
One of the measures taken by the management was to develop a new ERP system that would allow the integrated management of all the sales processes for its products. Until then, the company had been managing all the information in an outdated ERP, with the help of Excel files.  
With the implementation of a new ERP, it became necessary to model and integrate, into a new database, the fragmented data exported from the old ERP and other existing applications that had been supporting AdventureWorks until that point.  
An attachment to this statement included a set of files containing the data extracted from the systems. However, these files were poorly related, requiring optimization according to the best modeling practices and normalization rules to provide efficient support for operations and scalability interventions.

## 2 Development

### 2.1 Requirements and Data Model

#### 2.1.1 Entity Relationship Model (ERM)

I proposed an Entity Relationship Model (ERM) with the respective diagram, which included:
- **Business Information**
  - I included the business entities inferred from the analysis of the provided dataset.
  - The products were organized into Subcategories, which in turn were grouped into broader Categories (I facilitated navigation and filtering by Category and/or Subcategory).
- **Additional Requirements: ERP User Management**
  - The system supported users who accessed the application.
    - The authentication of customer access to the application was done using an email account and password.
    - Whenever a new access was created or a password recovery request was made for an existing customer, the system automatically generated a new password and sent an email to the customer with this information (for the project, I simulated writing to a "sentEmails" table with fields: recipient, message, timestamp, instead of configuring an email server).
    - For password recovery, the customer had to define a security question and answer it correctly to proceed with the recovery.

*The ERD diagram was created using the ERD Plus tool: https://erdplus.com/*

#### 2.1.2 Relational Model

Once the ERM was characterized and the respective DER diagram was proposed, I converted it into a relational model, considering a normalization corresponding to at least the 3rd normal form.  
During the development of the relational model, I carefully selected the appropriate data types, default values, constraints (primary key, foreign key, unique, and check), and triggers.  
I explicitly created the DDL code for the implementation of the model in SQL Server.

### 2.2 Database Layout

The definition of the database layout, which I justified in the report, was based on a set of data, including:
- The space occupied by each record in each table;
- The space occupied by each table with the current number of records;
- I proposed a growth rate for each table, inferred from the existing data;
- I dimensioned the number and types of accesses.
The definition of Filegroups, with the respective type, initial size, growth rate, and maximum size, was clearly documented by the previous survey.

### 2.3 Verifying the New Database

**Original Data:** For the original data, I defined a new database called "AdventureOldData" where all the information from the old system was imported.  
**Data Migration:** I created the necessary scripts for migrating the old data to the new database.  
I produced a set of queries that, when run on both databases, allowed me to verify the conformity of the data in the new database against the originally provided data.

Each group requested the specific set of queries from the instructor.

### 2.4 Programming

I considered developing stored procedures and functions:
- Supporting data migration.
- Supporting the implementation of additional requirements, including:
  - Access management:
    - Editing, Adding, and Removing Accesses.
    - Password Recovery (Security Questions and Answer verification).
  - Creating views for purchases made by a given customer.

#### Error Handling

All the code developed in the project performed necessary validations and included error handling. I managed error handling centrally. In case of an error, a user-friendly message was sent to the user, and an error log was created that identified the error, the user (SQL Server), and the timestamp of the event.

### 2.5 Catalog/Metadata

**Monitoring Support:**  
I created the following objects in the database for monitoring support:
- A stored procedure that queried the catalog to generate entries in dedicated tables, where I stored the following information about the databases: all the fields of all tables, their respective data types, sizes, and associated constraints (in the case of foreign keys, I indicated the referenced table and the type of action defined for maintaining referential integrity in “update” and “delete” operations). I also kept a history of schema changes in successive executions of the stored procedure.
- A view that presented data about the most recent execution, reporting the information from the table mentioned above.
- A stored procedure that also recorded, in a dedicated table, the number of records and the most reliable estimate of space occupied for each table. I kept a history of the results from successive executions of this stored procedure.

