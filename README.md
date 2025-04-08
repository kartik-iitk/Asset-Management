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

## How to Run?

1. Create the conda environment from `environment.yml` as follows by first going to the main directory:

```bash
conda env create -f environment.yml
conda activate DBMS
```

2. Install MySQL Community Server and create a root user. (part of the installation procedure)

3. Install **MySQL Shell for VS Code** Extension by Oracle in VSCode for easy access to the database.

4. From the MySQL Shell create a new connection and give it the username of root and set the password so that the database can be modified.

5. Open a new notebook and run the following code to create a database and its administrator user.

```
CREATE DATABASE AssetManagement;
CREATE USER 'kartik'@'localhost' IDENTIFIED BY 'kartik';
GRANT ALL ON AssetManagement.* TO 'kartik'@'localhost';
```

6.
