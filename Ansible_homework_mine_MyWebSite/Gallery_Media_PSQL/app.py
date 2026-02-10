from flask import Flask, jsonify
from flask_cors import CORS
import psycopg2
import psycopg2.extras

app = Flask(__name__)
CORS(app)

DB_CONFIG = {
    "host": "localhost",
    "database": "media_vault",
    "user": "aleks_admin", # Or 'aleks_admin'
    "password": "aleks2pgsql"
}

def get_db_connection():
    return psycopg2.connect(**DB_CONFIG)

@app.route('/api/photos', methods=['GET'])
def get_photos():
    conn = get_db_connection()
    cur = conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
    
    # We select both: the raw date for sorting, and the string for the UI
    # Pro-Tip: I used ORDER BY COALESCE(shot_date, modified_date) DESC.
    # This is a smart sorting trick. It sorts by the "Shot Date" if it exists;
    # if not, it uses the "Modified Date" as a fallback so your newest files always stay at the top.
    query = """
        SELECT 
            id, 
            filename, 
            folder_name, 
            file_size_kb, 
            camera_model, 
            likes, 
            TO_CHAR(shot_date, 'Mon DD, YYYY - HH12:MI AM') as formatted_date,
            TO_CHAR(modified_date, 'Mon DD, YYYY - HH12:MI AM') as formatted_modified,
            shot_date,
            modified_date
        FROM gallery_metadata 
        WHERE is_hidden = FALSE 
        ORDER BY COALESCE(shot_date, modified_date) DESC;
        """
    
    cur.execute(query)
    photos = cur.fetchall()
    cur.close()
    conn.close()
    return jsonify(photos)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)