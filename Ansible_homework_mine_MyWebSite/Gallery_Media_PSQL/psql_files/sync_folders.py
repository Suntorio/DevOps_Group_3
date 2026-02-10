import os
import psycopg2
from psycopg2.extras import RealDictCursor

# --- CONFIGURATION ---
user = os.getenv("PSQLDB_USER")
password = os.getenv("PSQLDB_PASSWORD")

DB_CONFIG = {
    "host": "localhost",
    "database": "media_vault",
    "user": user, # Use 'aleks_admin' if you went with the 'ks' spelling
    "password": password
}
MEDIA_PATH = "/var/www/html/fancy-media" # Update this to your actual folder

def sync_database_paths():
    try:
        conn = psycopg2.connect(**DB_CONFIG)
        cur = conn.cursor(cursor_factory=RealDictCursor)
        print("🚀 Starting filesystem-to-DB sync...")

        updated_count = 0

        # 1. Walk through the physical directory
        for root, dirs, files in os.walk(MEDIA_PATH):
            for filename in files:
                # Calculate the relative folder path
                # e.g., if root is /media/Pictures/03_2023, rel_path is "Pictures/03_2023"
                rel_path = os.path.relpath(root, MEDIA_PATH)
                
                # If the file is in the root, we call it "fancy-media" 
                # (matching your previous frontend logic)
                if rel_path == ".":
                    folder_name = "fancy-media"
                else:
                    folder_name = rel_path.replace("\\", "/") # Ensure Linux-style slashes

                # 2. Update the database for this specific filename
                # We only update if the folder_name is DIFFERENT to save resources
                cur.execute("""
                    UPDATE gallery_metadata 
                    SET folder_name = %s 
                    WHERE filename = %s AND folder_name != %s
                """, (folder_name, filename, folder_name))

                if cur.rowcount > 0:
                    print(f"✅ Moved: {filename} -> {folder_name}")
                    updated_count += cur.rowcount

        conn.commit()
        print(f"--- Sync Complete! {updated_count} files updated. ---")

    except Exception as e:
        print(f"❌ Error during sync: {e}")
    finally:
        if conn:
            cur.close()
            conn.close()

if __name__ == "__main__":
    sync_database_paths()