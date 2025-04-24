# Lab Asset & Inventory Management

## CS315 Mini Project 2024-25-II

## Group Details

| Name                   | Roll No. |
| ---------------------- | -------- |
| Kartik Anant Kulkarni  | 210493   |
| Sharvil Sachin Athaley | 210961   |
| Samyak Singhania       | 210917   |
| Sanath Salampuria      | 210919   |
| Raghav Shukla          | 210800   |

## Requirements

### Hardware

Tested on osx-arm64 M2Pro 16 GB RAM

### Software

- Python 3.13.2 (miniforge, conda 24.7.1)
- MySQL Community Server 9.2.0 Innovation
- Visual Studio Code Version: 1.99.3

## How to Run?

1. Create the conda environment from `environment.yml` as follows by first going to the main directory:

```bash
conda env create -f environment.yml
conda activate DBMS
```

2. Install MySQL Community Server and create a root user. (part of the installation procedure)

3. Install **MySQL Shell for VS Code** Extension by Oracle in VSCode for easy access to the database.

4. From the MySQL Shell create a new connection and give it the username of root and set the password so that the database can be modified. Keep the hostname as localhost.

5. Open a new notebook and run the following code to create a database and its administrator user.

```
CREATE DATABASE AssetManagement;
CREATE USER 'kartik'@'localhost' IDENTIFIED BY 'kartik';
GRANT ALL ON AssetManagement.* TO 'kartik'@'localhost';
```

6. Run the sql file in `./scripts/initialisation/create_table.sql` by opening the file in VSCode and Right Click and select execute in MySQL Shell. This should add empty tables as required.

7. Now `cd` to the `./src/data_loader` directory in a terminal and run the bash file by running:

```bash
bash import-data.sh
```

This should import a bare minimum amount of test data into your database.

8. Now similar to step 6, run the sql file in `./scripts/initialisation/create_procedures.sql` file by opening it in VSCode. This will create all the stored procedures for the database.

9. Finally create triggers by running the sql file in `./scripts/initialisation/create_triggers.sql`.

10. Now `cd` to the `src/Streamlit` and run:

```bash
streamlit run streamlit_last.py
```

Note: In the login screen, please access as the admin user using Username: A00001 and Password: A00001 (and press login button twice).
