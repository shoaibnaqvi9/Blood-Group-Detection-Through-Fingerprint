from googleapiclient.discovery import build
from google.oauth2.service_account import Credentials

SERVICE_ACCOUNT_FILE = 'biobloodtracker-b9af200f9cbf.json'
SCOPES = ['https://www.googleapis.com/auth/drive']

creds = Credentials.from_service_account_file(SERVICE_ACCOUNT_FILE, scopes=SCOPES)
drive_service = build('drive', 'v3', credentials=creds)

# Function to list all subfolders in a folder
def list_subfolders(folder_id):
    results = drive_service.files().list(
        q=f"'{folder_id}' in parents and mimeType = 'application/vnd.google-apps.folder' and trashed = false",
        fields="files(id, name)"
    ).execute()
    return results.get('files', [])

# Function to list files in a specific folder
def list_files_in_folder(folder_id):
    
    results = drive_service.files().list(
        q=f"'{folder_id}' in parents and trashed = false",
        fields="files(id, name)"
    ).execute()
    return results.get('files', [])

# Main folder ID (replace this with your main folder's ID)
main_folder_id = '1-9DagGfSQwRJVf5S17qbRDrW5iURwiy8'

# List subfolders (blood group folders)
subfolders = list_subfolders(main_folder_id)

# Fetch files within each blood group folder
for subfolder in subfolders:
    print(f"Blood Group: {subfolder['name']}")
    files = list_files_in_folder(subfolder['id'])
    for file in files:
        print(f"  File ID: {file['id']}, Name: {file['name']}")
