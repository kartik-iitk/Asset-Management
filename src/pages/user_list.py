import streamlit as st
import pandas as pd
import mysql.connector
from sqlalchemy import create_engine, Table, MetaData


def user_list_page():
    st.title("User List")

    # Database connection details
    username = "kartik"
    password = "kartik"
    host = "localhost"
    database = "assetmanagement"

    # Create a connection engine
    engine = create_engine(f"mysql+pymysql://{username}:{password}@{host}/{database}")

    # SQL query to fetch data
    query = "SELECT * FROM users"

    # Read data into a DataFrame
    df = pd.read_sql(query, engine)

    # Allow user to edit the dataframe
    edited_df = st.data_editor(df)

    if st.button("Save Data"):
        # Identify changed rows
        changed_rows = edited_df[edited_df.ne(df).any(axis=1)]
        update_users(engine, changed_rows)

        st.success("Data saved successfully!")


def update_users(engine, df):
    # Define the table name
    table_name = "users"

    # Define the column names and values to update
    id_column = "UserId"
    columns_to_update = ["InstituteId", "Email"]

    # Update rows in the database
    try:
        with engine.connect() as connection:
            metadata = MetaData()
            table = Table(table_name, metadata, autoload_with=engine)

            # Iterate over rows in the DataFrame
            for _, row in df.iterrows():
                update_statement = (
                    table.update()
                    .where(table.c[id_column] == row[id_column])
                    .values({col: row[col] for col in columns_to_update})
                )

                # Execute the update query
                connection.execute(update_statement)
                connection.commit()
            print("Update successful!")
    except Exception as e:
        print(f"Error: {e}")
