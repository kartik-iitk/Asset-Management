from cryptography.fernet import Fernet
import sys

# Predefined key (must be kept secret)
KEY = "OBmSxkzVXgVowuRmWJa_kz8FkXjSDtKge1Nbkb0W_XE="  # Replace this with a stored key
cipher = Fernet(KEY)

def encrypt_text(text: str) -> str:
    return cipher.encrypt(text.encode()).decode()

def decrypt_text(text: str) -> str:
    return cipher.decrypt(text.encode()).decode()

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python crypto.py <encrypt|decrypt> <text>")
        sys.exit(1)

    action, text = sys.argv[1], sys.argv[2]

    if action.lower() == "encrypt":
        print(f"Encrypted: {encrypt_text(text)}")
    elif action.lower() == "decrypt":
        print(f"Decrypted: {decrypt_text(text)}")
    else:
        print("Invalid action! Use 'encrypt' or 'decrypt'.")