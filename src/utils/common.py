import streamlit as st

from src.utils.db_connection import create_connection


def check_authentication(username, password):
    conn = create_connection()
    cursor = conn.cursor()
    cursor.execute(
        "SELECT * FROM users WHERE UserName=%s AND UserPassword=%s",
        (username, password),
    )
    user = cursor.fetchone()
    conn.close()
    return user
