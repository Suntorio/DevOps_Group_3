import datetime # Make sure this is imported at the top

# ... inside the loop ...
for file in files:
    file_path = os.path.join(root, file)
    
    # 1. Get the modification time from the file system
    mtime = os.path.getmtime(file_path)
    # Convert epoch (17373...) to PostgreSQL format
    mod_date = datetime.datetime.fromtimestamp(mtime).strftime('%Y-%m-%d %H:%M:%S')

    # 2. Get the pure EXIF data as before
    camera, date_taken = get_exif_data(file_path)

    # 3. Update the SQL query to include the new field
    query = """
    INSERT INTO gallery_metadata (filename, folder_name, file_size_kb, camera_model, shot_date, modified_date)
    VALUES (%s, %s, %s, %s, %s, %s)
    ON CONFLICT (filename) DO UPDATE SET 
        shot_date = EXCLUDED.shot_date,
        modified_date = EXCLUDED.modified_date,
        camera_model = EXCLUDED.camera_model;
    """
    cur.execute(query, (file, folder_name, file_size_kb, camera, date_taken, mod_date))