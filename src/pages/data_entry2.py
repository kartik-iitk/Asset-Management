import streamlit as st
import pandas as pd
from utils.db_connection import create_connection

def data_entry_page_2():
    st.title("Table using Dataframe")
 
    df = fetch_users()
    # edited_df = st.data_editor(df, num_rows="dynamic")
    edited_df = st.data_editor(
        df,
        column_config={
            "UserId": "ID",
            "UserName": "User Name",
            "FirstName": "First Name", 
            "LastName": "Last Name",
            "UserAddress": "Address",
            "DOB" : "Date of Birth",
            "Email" : "Email",
        },
        disabled=["UserId", "UserName"],
        hide_index=True,
        )

def fetch_users():
    """Fetch all users from the MySQL table."""
    conn = create_connection()
    cursor = conn.cursor(dictionary=True)  # Use dictionary for column mapping
    cursor.execute("SELECT UserId, UserName, FirstName, LastName, UserAddress, DOB, Email FROM users")
    data = cursor.fetchall()
    conn.close()

    if data:
        return pd.DataFrame(data)  # Convert to a Pandas DataFrame for table display
    else:
        return pd.DataFrame(columns=["ID", "User Name", "First Name", "Last Name", "Address", "Date of Birth", "Email"])