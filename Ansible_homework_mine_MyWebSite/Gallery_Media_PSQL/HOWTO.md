MY GOAL:
a. To build my private web site with gallery (photos and videos are about 50GB)
b. I want to do it with DevOps best practices based on AWS
b1. What is CloudFront?
c. My media files are going to be uploaded to S3 Bucket
d. I'm going to use Terraform and Ansible
e. Nginx web-server will be used on my EC2 instance
f. Elastic IP:
    * Running vs. Stopped: There is no longer a price "discount" for having the IP attached to a running instance. You pay the $0.005/hour regardless of the instance state.
    * EBS Costs: Remember that while your instance is stopped, you are still being charged for the EBS storage (disk) attached to that instance (usually ~$0.08–$0.10 per GB per month for gp3 volumes), in addition to the Elastic IP cost.
    * Release vs. Stop: If you don't need the static IP while the server is off, you should Disassociate and then Release the IP to stop the charges entirely. Simply stopping the  instance will not stop the IP billing.

Solution:  

1.  Deploy an instance with Terraform
    * Create an EC2
    * Request a new Elastic IP  
    * Assign the Elastic IP to the EC2
 
2.  Ansible is an open-source automation tool used for configuration management, application deployment, and task automation.
    It simplifies IT automation by using a declarative approach, allowing users to define what needs to be done rather than how to do it.

*Run the playbook
$ ansible-playbook -i inventory.ini nginx_setup.yml
OR
$ ansible-playbook playbook.yaml -i hosts --private-key=~/Documents/PASV_DevOps/SSH-Keys/lesson_7_ansible.pem -u ubuntu #IT WORKS!
________________________________________________________________________________________
IF WE CREATE ansible.cfg then:
$ ansible-playbook playbook.yaml

01/24/2026 SUMMARY: WORKING NGINX SERVER WEBSITE WITH HTTPS (SECURE with SSL)!

$$$ All files and folders on S3 Bucket are JUST LINKS to S3 Bucket storage! $$$

HOW TO CONNECT NGINX TO S3 BUCKET:

Connecting your NGINX server to an AWS S3 bucket is a classic DevOps pattern. It allows you to serve large files (images, videos, backups) cheaply from S3 while keeping your clean alex-tech.us domain name in the browser.

This setup makes NGINX act as a Reverse Proxy. The user asks NGINX for a file, NGINX silently fetches it from AWS S3, and hands it to the user. The user never sees the ugly s3.amazonaws.com URL.

Step 1: The AWS Side (Bucket Policy)
You could make your bucket 100% public, but that's insecure. The "DevOps way" is to allow only your EC2 instance to read from the bucket.

Go to your S3 Bucket > Permissions > Bucket Policy.

Paste this policy (replace YOUR_BUCKET_NAME and YOUR_EC2_PUBLIC_IP):

JSON

{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowNginxAccess",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::YOUR_BUCKET_NAME/*",
            "Condition": {
                "IpAddress": {
                    "aws:SourceIp": "YOUR_EC2_PUBLIC_IP/32"
                }
            }
        }
    ]
}
Now, if someone tries to open the S3 link directly, they get "Access Denied." But your NGINX server (which has that IP) can read it.


!!!_IMPORTANT_!!!
Fancyindex needs to "look" at a local folder on your hard drive to see what files are there so it can build the table.
S3 is a remote web service. When you use proxy_pass, Nginx isn't "looking" at a folder; it's just passing a request to Amazon.
The result: If you just use proxy_pass, Fancyindex won't work. You'll either see an ugly AWS XML list or a 403 error.

To use Fancyindex with S3, you have to mount the S3 bucket as a local folder using a tool called s3fs.
This makes the server think the S3 bucket is just another folder on the disk.

When you use s3fs, files are NOT downloaded to your EC2 instance. Your hard drive does not fill up with 100GB of photos.

3. Install and create PostgreSQL database
# Update the package list and install the software
sudo apt update
sudo apt install -y postgresql postgresql-contrib python3-psycopg2

# Start the service and set it to run on boot
sudo systemctl start postgresql
sudo systemctl enable postgresql

# Create the database named media_vault
$ sudo -u postgres createdb media_vault

# Create the user aleks_admin with a password
$ sudo -u postgres psql -c "CREATE USER aleks_admin WITH PASSWORD 'aleks2pgsql';"

# Give aleks_admin full control over the media_vault database
$ sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE media_vault TO aleks_admin;"

# Specifically allow the user to create tables inside that database
$ sudo -u postgres psql -d media_vault -c "GRANT ALL ON SCHEMA public TO aleks_admin;"

# You can test your new credentials by trying to log in manually:
# Log in to your new database as your new user
$ psql -h localhost -U aleks_admin -d media_vault

# It uses psql to connect as your admin user and execute the table creation in one shot:
$ psql -h localhost -U alex_admin -d media_vault -c "
    CREATE TABLE gallery_metadata (
        id SERIAL PRIMARY KEY,
        filename TEXT NOT NULL,
        folder_name TEXT,
        upload_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        file_size_kb INT,
        camera_model TEXT,
        shot_date TIMESTAMP;
        likes INT DEFAULT 0,
        is_hidden BOOLEAN DEFAULT FALSE
    );"

# To make sure PostgreSQL actually built your "vault," run this command to list all tables:
$ psql -h localhost -U alex_admin -d media_vault -c "\dt"

# Once you see the media_vault=> prompt, run this to see your photos:
media_vault=> SELECT * FROM gallery_metadata;

A. Show me the biggest files (Top 5):

SQL
SELECT filename, file_size_kb 
FROM gallery_metadata 
ORDER BY file_size_kb DESC 
LIMIT 5;

B. What cameras am I using?

SQL
-- This groups your photos by camera model
SELECT camera_model, COUNT(*) 
FROM gallery_metadata 
GROUP BY camera_model;

C. How many photos are currently in the vault?

SQL
SELECT COUNT(*) FROM gallery_metadata;

#"Hiding" photos directly in the database with one command:

SQL
UPDATE gallery_metadata 
SET is_hidden = TRUE 
WHERE filename = 'AlexTechLogo-03.png';

To give your website a "nervous system," we’ll build a simple REST API using Flask. This API will sit between your PostgreSQL database and your frontend, serving up your photo data as JSON:

Step 1: Install Flask and CORS
Since your website (Frontend) and your API (Backend) might technically be viewed as different origins by the browser, we need flask-cors to allow them to talk to each other.

Run this inside your virtual environment:

Bash

# Ensure you are in your bubble
source ~/media_env/bin/activate

# Install the web server tools
pip install flask flask-cors

Step 2: Create the API (app.py)
Create a new file named app.py in your project folder. This script will connect to the media_vault and send the data to the web.

Step 3: Run and Test
Start your backend server:

Bash

(media_env) aleks@dell-ubuntu: python3 app.py

Now, open your browser and go to: http://your-ec2-ip:5000/api/photos You should see a clean list of all your photos, their camera models, and their "likes" in a format like this:

JSON
[
  {
    "camera_model": "iPhone 15 Pro",
    "filename": "sunset.jpg",
    "id": 1,
    "likes": 5,
    "is_hidden": false
  }
]