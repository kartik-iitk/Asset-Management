import streamlit as st
from src.utils.common import check_authentication


def login_page():
    st.title("Login Page")

    # Two-column layout: Image on the left, fields on the right
    col1, col2 = st.columns([1, 2])  # Adjust column proportions as needed

    with col1:
        # Display the image (replace 'image_path.jpg' with your actual image file path)
        st.image("assets/images/login_image.jpg", caption="Welcome!", width=400)

    with col2:
        # Input fields
        username = st.text_input("Username")
        password = st.text_input("Password", type="password")

        if st.button("Login"):
            user = check_authentication(username, password)
            if user:
                st.session_state.logged_in = True
                st.session_state.current_page = "Home"  # Redirect to Home
                st.rerun()  # Trigger re-run to apply redirection
            else:
                st.error("Invalid username or password")
