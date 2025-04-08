import streamlit as st
import pandas as pd
from src.utils.db_connection import create_connection


def data_entry_page_1():

    st.title("Data Entry Page 1")
    display_table()

    # df = pd.DataFrame(np.random.randn(50, 20), columns=("col %d" % i for i in range(20)))
    # st.dataframe(df)  # Same as st.write(df)


def fetch_users():
    """Fetch all users from the MySQL table."""
    conn = create_connection()
    cursor = conn.cursor(dictionary=True)  # Use dictionary for column mapping
    cursor.execute(
        "SELECT UserId, UserName, FirstName, LastName, UserAddress FROM users"
    )
    data = cursor.fetchall()
    conn.close()

    if data:
        return pd.DataFrame(data)  # Convert to a Pandas DataFrame for table display
    else:
        return pd.DataFrame(
            columns=["ID", "Username", "First Name", "Last Name", "Address"]
        )


def update_user(user_id, username, first_name, last_name, address):
    """Update user details in the database."""
    try:
        conn = create_connection()
        cursor = conn.cursor()
        query = """
            UPDATE users
            SET UserName = %s, FirstName = %s, LastName = %s, UserAddress = %s
            WHERE UserId = %s
        """
        cursor.execute(query, (username, first_name, last_name, address, user_id))
        conn.commit()
        conn.close()
    except Exception as e:
        st.error(f"Error updating user: {e}")


def delete_user(user_id):
    """Delete a user by ID."""
    conn = create_connection()
    cursor = conn.cursor()
    cursor.execute("DELETE FROM users WHERE UserId = %s", (user_id,))
    conn.commit()
    conn.close()


def display_table():
    # Fetch data from MySQL
    try:
        users_df = fetch_users()
        selected_user = None  # For tracking which user to edit

        if not users_df.empty:
            # Table headers
            headers = st.columns([2, 2, 2, 3, 1, 1])  # Define column widths
            headers[0].markdown("**Username**")
            headers[1].markdown("**First Name**")
            headers[2].markdown("**Last Name**")
            headers[3].markdown("**Address**")
            headers[4].markdown("**Edit**")
            headers[5].markdown("**Delete**")

            # Table rows with buttons
            for _, row in users_df.iterrows():
                cols = st.columns([2, 2, 2, 3, 1, 1])  # Match column widths
                cols[0].write(row["UserName"])
                cols[1].write(row["FirstName"])
                cols[2].write(row["LastName"])
                cols[3].write(row["UserAddress"])

                # When Edit button is clicked, assign selected_user as a dictionary
                if cols[4].button("Edit", key=f"edit_{row['UserId']}"):
                    selected_user = row.to_dict()  # Convert Series to dictionary

                # Delete button
                if cols[5].button("Delete", key=f"delete_{row['UserId']}"):
                    delete_user(row["UserId"])
                    st.warning(f"User ID: {row['UserId']} deleted successfully!")
                    st.rerun()  # Refresh table after deletion

            # Conditional popup for editing user details
            if selected_user:
                st.write("---")  # Separator line for the popup
                st.subheader(f"Edit User: {selected_user['UserName']}")

                # Create a form for editing user details
                with st.form(f"edit_form_{selected_user['UserId']}"):
                    new_username = st.text_input("Username", selected_user["UserName"])
                    new_first_name = st.text_input(
                        "First Name", selected_user["FirstName"]
                    )
                    new_last_name = st.text_input(
                        "Last Name", selected_user["LastName"]
                    )
                    new_address = st.text_area("Address", selected_user["UserAddress"])

                    # Submit button
                    if st.form_submit_button("Save Changes"):
                        update_user(
                            selected_user["UserId"],
                            new_username,
                            new_first_name,
                            new_last_name,
                            new_address,
                        )
                        st.success("User details updated successfully!")
                        st.rerun()  # Refresh the table after editing

        else:
            st.warning("No data found in the users table.")
    except Exception as e:
        st.error(f"Error fetching data: {e}")
