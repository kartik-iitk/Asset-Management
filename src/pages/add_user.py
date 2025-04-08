import streamlit as st
import mysql.connector

# Function to connect to MySQL database
def connect_db():
    return mysql.connector.connect(
        host="localhost",
        user="root",
        password="rootuser",
        database="assetmanagement"
    )

# Function to insert user into table
def insert_user(username, first_name, last_name, dob, address, email):
    conn = connect_db()
    cursor = conn.cursor()
    cursor.execute("""
        INSERT INTO users (UserName, FirstName, LastName, DOB, UserAddress, Email) 
        VALUES (%s, %s, %s, %s, %s, %s)
    """, (username, first_name, last_name, dob, address, email))
    conn.commit()
    conn.close()

def add_user_page():
    # Streamlit UI
    st.title("User Registration Form")

    with st.form("user_form"):
        col1, col2 = st.columns(2)
        
        with col1:
            username = st.text_input("User Name")
            first_name = st.text_input("First Name")
            last_name = st.text_input("Last Name")
        
        with col2:
            dob = st.date_input("Date of Birth")
            address = st.text_area("Address")
            email = st.text_input("Email ID")
        
        submit_button = st.form_submit_button("Submit")

        if submit_button:
            if username and first_name and last_name and dob and address and email:
                try:
                    insert_user(username, first_name, last_name, dob.strftime("%Y-%m-%d"), address, email)
                    st.success("User added successfully!")
                except Exception as e:
                    st.error(f"Error: {str(e)}")
            else:
                st.warning("Please fill all the fields.")