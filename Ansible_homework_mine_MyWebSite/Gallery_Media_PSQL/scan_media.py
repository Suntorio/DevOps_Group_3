import os
import psycopg2
from datetime import datetime
from PIL import Image
from PIL.ExifTags import TAGS

# --- CONFIGURATION ---
DB_CONFIG = {
    "host": "localhost",
    "database": "media_vault",
    "user": "aleks_admin", # Use 'aleks_admin' if you went with the 'ks' spelling
    "password": "aleks2pgsql"
}
MEDIA_PATH = "/var/www/html/fancy-media" # Update this to your actual folder
# ---------------------

def get_exif_data(file_path):
    camera = "Unknown"
    shot_date = None  # Default is NULL
    
    try:
        with Image.open(file_path) as img:
            exif = img._getexif()
            if exif:
                for tag, value in exif.items():
                    decoded = TAGS.get(tag, tag)
                    if decoded == 'Model':
                        camera = value
                    if decoded == 'DateTimeOriginal':
                        # Convert 'YYYY:MM:DD HH:MM:SS' to 'YYYY-MM-DD HH:MM:SS'
                        shot_date = value.replace(':', '-', 2)
    except Exception:
        pass 
        # We do NOTHING here. If it fails, shot_date stays None.

    return camera, shot_date

def scan_and_save():
    conn = psycopg2.connect(**DB_CONFIG)
    cur = conn.cursor()
    print("Scanning for pure metadata...")

    for root, dirs, files in os.walk(MEDIA_PATH):
        folder_name = os.path.basename(root)
        for file in files:
            if file.lower().endswith(('.png', '.jpg', '.jpeg', '.gif')):
                file_path = os.path.join(root, file)
                file_size_kb = int(os.path.getsize(file_path) / 1024)

                # Get the modification time from the file system
                mtime = os.path.getmtime(file_path)
                # Convert epoch (17373...) to PostgreSQL format
                mod_date = datetime.fromtimestamp(mtime).strftime('%Y-%m-%d %H:%M:%S')
                
                # Get strictly EXIF data (or None)
                camera, date_taken = get_exif_data(file_path)

                # Update the SQL query to include the new field
                query = """
                INSERT INTO gallery_metadata (filename, folder_name, file_size_kb, camera_model, shot_date, modified_date)
                VALUES (%s, %s, %s, %s, %s, %s)
                ON CONFLICT (filename) DO UPDATE SET 
                    shot_date = EXCLUDED.shot_date,
                    modified_date = EXCLUDED.modified_date,
                    camera_model = EXCLUDED.camera_model;
                """
                cur.execute(query, (file, folder_name, file_size_kb, camera, date_taken, mod_date))

    conn.commit()
    cur.close()
    conn.close()
    print("Vault cleaned and updated!")

if __name__ == "__main__":
    scan_and_save()