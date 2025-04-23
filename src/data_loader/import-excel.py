import argparse
import pandas as pd
import mysql.connector
from mysql.connector import Error


def import_excel_to_mysql(
    database_name, excel_file, sheet_name=None, mysql_config=None
):
    try:
        # Configure MySQL connection (include the database in the config)
        mysql_config["database"] = database_name
        connection = mysql.connector.connect(**mysql_config)
        cursor = connection.cursor()

        # Read the Excel file
        excel_data = pd.ExcelFile(excel_file)
        sheets_to_import = [sheet_name] if sheet_name else excel_data.sheet_names
        print(f"Sheets to import: {sheets_to_import}")

        for sheet in sheets_to_import:
            # Read the sheet into a DataFrame
            df = excel_data.parse(sheet)

            # Create table based on the sheet name and DataFrame columns;
            # all columns are defined as TEXT
            columns_def = ", ".join([f"`{col}` TEXT" for col in df.columns])
            create_table_query = f"CREATE TABLE IF NOT EXISTS `{sheet}` ({columns_def})"
            cursor.execute(create_table_query)

            # Construct raw insertion query
            placeholders = ", ".join(["%s"] * len(df.columns))
            insert_query = f"INSERT INTO `{sheet}` VALUES ({placeholders})"

            # Prepare data: replace NaN with None so that NULL is inserted
            data = [
                tuple(None if pd.isna(value) else value for value in row)
                for row in df.itertuples(index=False, name=None)
            ]

            cursor.executemany(insert_query, data)
            connection.commit()
    except Error as err:
        print("Error:", err)
        if connection.is_connected():
            connection.rollback()

        print("Data import completed successfully!")


if __name__ == "__main__":
    # Command-line argument parsing
    parser = argparse.ArgumentParser(description="Import Excel data into MySQL.")
    parser.add_argument(
        "-H", "--hostname", default="localhost", help="MySQL host (default: localhost)."
    )
    parser.add_argument(
        "-d",
        "--database",
        default="AssetManagement",
        help="Name of the MySQL database.",
    )
    parser.add_argument(
        "-u", "--user", default="kartik", help="MySQL username (default: root)."
    )
    parser.add_argument("-p", "--password", default="kartik", help="MySQL password.")
    parser.add_argument(
        "-e",
        "--workbook",
        default="../../data/data1.xlsx",
        help="Path to the Excel file.",
    )
    parser.add_argument(
        "-s", "--worksheet", help="Optional sheet (tab) name to import."
    )

    args = parser.parse_args()

    mysql_config = {
        "host": args.hostname,
        "user": args.user,
        "password": args.password,
    }

    import_excel_to_mysql(args.database, args.workbook, args.worksheet, mysql_config)
