import streamlit as st
from src.pages.login import login_page
from src.pages.home import home_page
from src.pages.user_list import user_list_page
from src.pages.add_user import add_user_page
from src.pages.data_entry1 import data_entry_page_1
from src.pages.data_entry2 import data_entry_page_2
from src.pages.data_entry3 import data_entry_page_3


def main():
    # Apply custom styles and initialize session state
    apply_custom_styles()

    if "logged_in" not in st.session_state:
        st.session_state.logged_in = False
    if "current_page" not in st.session_state:
        st.session_state.current_page = "Login"

    # Debugging: Ensure session state initialization
    print("Logged In:", st.session_state.logged_in)
    print("Current Page:", st.session_state.current_page)

    # Logout functionality
    if st.session_state.logged_in:
        with st.sidebar:
            if st.button("Logout"):
                st.session_state.logged_in = False
                st.session_state.current_page = "Login"
                st.rerun()  # Trigger reset and redirect to login

    # Page navigation logic
    pages = {
        "Home": home_page,
        "User List": user_list_page,
        "Add User": add_user_page,
        "Data Entry 1": data_entry_page_1,
        "Data Entry 2": data_entry_page_2,
        "Data Entry 3": data_entry_page_3,
    }

    # Navigation for logged-in users
    if st.session_state.logged_in:
        with st.sidebar:
            st.title("Navigation")
            for page_name in pages.keys():
                if st.button(page_name):  # Update current page when link clicked
                    st.session_state.current_page = page_name
                    st.rerun()  # Force re-render with new page

    # Page rendering logic
    if st.session_state.current_page == "Login":
        login_page()
    elif st.session_state.current_page in pages:
        pages[st.session_state.current_page]()


def apply_custom_styles():
    """Apply custom styles for sidebar width and adjust margins for main content."""
    st.markdown(
        """
        <style>
        /* Adjust Sidebar Width */
        [data-testid="stSidebar"] {
            min-width: 200px !important;
            max-width: 200px !important;
        }
        /* Hide Default Page List in Sidebar */
        [data-testid="stSidebarNav"] {
            display: none !important;
        }
        /* Add Padding Between Sidebar and Main Content */
        div.block-container {
            padding-top: 10px !important;
            padding-left: 20px !important; /* Add space from sidebar */
            margin: 0px !important; /* Reset all margins */
        }
        /* Outer Container Adjustment */
        .main {
            padding-left: 10px !important; /* Ensure content isn't pressed against the edge */
        }
        </style>
        """,
        unsafe_allow_html=True,
    )


# Page Configuration to Center Content
st.set_page_config(
    layout="wide",  # Set wide layout to override default padding
)

if __name__ == "__main__":
    main()
