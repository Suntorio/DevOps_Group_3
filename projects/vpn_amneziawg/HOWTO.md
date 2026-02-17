1. The "All-in-One" Installation Script
If you are on a fresh Ubuntu VPS (like RU VDS or Aeza), this script handles the dependencies, the "Junk" packet settings, and the WireGuard kernel module all at once.

Run this on your Ubuntu Server:

# Update the system first
sudo apt update && sudo apt upgrade -y

# Download and run the AmneziaWG auto-installer
wget https://raw.githubusercontent.com/amnezia-vpn/amnezia-wg/master/install.sh NOT FOUND!
chmod +x install.sh
sudo ./install.sh

What happens during this script?
It installs the Amnezia-specific WireGuard module (Standard WireGuard won't work).
It asks you for a Port (use something common like 51820 or 443 to hide in plain sight).
It generates the QR Codes and .conf files for your 5 users.

2. The "Stealth" Parameters (The Secret Sauce)
Once installed, your configuration file will look different from a normal WireGuard file. It adds these 5 critical parameters to the [Interface] section:

Ini, TOML

[Interface]
PrivateKey = <Server_Private_Key>
Address = 10.10.10.1/24
ListenPort = 51820

# AMNEZIAWG SPECIFIC SETTINGS
Jc = 4        # Junk packet count
Jmin = 50     # Min size of junk packets
Jmax = 1000   # Max size of junk packets
S1 = 15       # Scrambling parameter 1
S2 = 24       # Scrambling parameter 2
How it works: Standard WireGuard has a very recognizable "handshake" pattern. Russian DPI (Deep Packet Inspection) looks for this pattern. AmneziaWG throws "junk" data into the handshake, making it look like random noise or generic UDP traffic, which the ISP usually ignores.

3. Managing 5 Users

When you run the script, it will create a client file (e.g., client.conf). For 5 users, you have two options:

Run the script multiple times: Some scripts allow you to re-run them to "Add a new user."

Manual Addition: You can manually add [Peer] sections to your /etc/wireguard/awg0.conf.

Each user MUST have their own IP and Private Key:

User 1: 10.10.10.2
User 2: 10.10.10.3
...and so on.

4. Why the .msi file you have is important
Remember that amneziawg-amd64-1.0.2.msi you found? Only that specific app can read the Jc, Jmin, and Jmax settings. If you try to use the "Official WireGuard" app from the Microsoft Store, it will give you an error saying "Unknown attribute Jc".

5. Essential Post-Install Commands
After the script finishes, use these commands to manage your new stealth VPN:

Check if it's running: sudo awg show (Note the 'a' in awg)

Restart the service: sudo systemctl restart awg-quick@awg0

See the logs (if someone can't connect): sudo dmesg | grep awg

To manage 5 users effectively on an AmneziaWG server, you need to set up a "Peer" block for each person. Each user must have a unique IP address and a unique Private Key.

Since you are using a VPS, the best way to do this is to keep a master configuration file on your server and generate 5 separate .conf files to send to your users.

1. The Server Master Config (/etc/amnezia/amneziawg/awg0.conf)
You only need one [Interface] section, but five [Peer] sections.

Ini, TOML
[Interface]
Address = 10.10.10.1/24
ListenPort = 51820
PrivateKey = <SERVER_PRIVATE_KEY>

# AMNEZIAWG STEALTH SETTINGS (Must match on all clients)
Jc = 4
Jmin = 50
Jmax = 1000
S1 = 15
S2 = 24

# --- USER 1 ---
[Peer]
PublicKey = <CLIENT_1_PUBLIC_KEY>
AllowedIPs = 10.10.10.2/32

# --- USER 2 ---
[Peer]
PublicKey = <CLIENT_2_PUBLIC_KEY>
AllowedIPs = 10.10.10.3/32

# ... Repeat for Users 3, 4, and 5
2. How to Generate Keys for your 5 Users
Don't make them yourself! Use the server to generate the pairs for each user so you know they are secure. Run this 5 times (changing the name each time):

Bash
# Generate keys for User 1
awg genkey | tee user1_private.key | awg pubkey > user1_public.key

3. The Client Template (Send this to your users)
Each of your 5 users will receive a unique file. Here is what User 1's file should look like:

Ini, TOML
[Interface]
PrivateKey = <USER_1_PRIVATE_KEY>
Address = 10.10.10.2/24
DNS = 1.1.1.1

# Stealth Settings (Must match the server exactly)
Jc = 4
Jmin = 50
Jmax = 1000
S1 = 15
S2 = 24

[Peer]
PublicKey = <SERVER_PUBLIC_KEY>
Endpoint = <YOUR_VPS_PUBLIC_IP>:51820
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25

4. Pro Tip: Using the Amnezia GUI
If the manual config feels too "techy," the AmneziaVPN Desktop App (the one you download from their site) has a built-in "Share" feature:

Connect to your server via SSH in the app.

Click the "Share" icon (bottom center).

Click "Add User".

It will generate a QR Code or a vpn:// link that you can just send to your friends. They paste that into their app, and they are connected instantly.

Summary Checklist for 5 Users:
Unique Internal IPs: Give them .2, .3, .4, .5, and .6.

Matching "J" Values: If the server has Jc = 4, the client must have Jc = 4.

Port Forwarding: If you are using a cloud provider like AWS or Oracle, ensure you opened UDP 51820 in their web dashboard (Security Lists/Security Groups).
-------------------------------------------------------------------------------------------------------------------------------------------------------

How to install Amnezia-WG VPN on Ubuntu server with docker image from https://hub.docker.com/r/amneziavpn/amnezia-wg?

Gemini said
Using the raw amneziavpn/amnezia-wg image from Docker Hub is not recommended for manual installation. That specific image is a "bare" component designed to be controlled by the Amnezia Client App via SSH scripts, not run by humans directly. It lacks documentation and requires complex, dynamic configuration files.

Instead, the community standard for running AmneziaWG in Docker is to use Amnezia-WG-Easy. This wraps the protocol in a container with a Web UI (like standard WireGuard-Easy) so you can generate client configs easily.
+1

Here is how to set it up on your Ubuntu server.

1. Prerequisites
You must have Docker and Docker Compose installed.

sudo apt update
sudo apt install docker.io docker-compose-plugin -y

##################################################
# 1. Add the official Amnezia PPA
sudo add-apt-repository -y ppa:amnezia/ppa

# 2. Update your package list
sudo apt update

# 3. Install the AmneziaWG kernel module and tools
sudo apt install -y amneziawg
##################################################

2. Create the Docker Compose file
Create a new directory and the file:

mkdir amnezia-vpn
cd amnezia-vpn
nano docker-compose.yml

Paste the following configuration. Change the WG_HOST to your server's Public IP and set a PASSWORD for the Web UI.

YAML
services:
  amnezia-wg-easy:
    image: ghcr.io/spcfox/amnezia-wg-easy:latest
    privileged: true
    container_name: amnezia-wg-easy
    restart: unless-stopped
    cap_add:
      - NET_ADMIN
      - SYS_MODULE
    sysctls:
      - net.ipv4.ip_forward=1
      - net.ipv4.conf.all.src_valid_mark=1
    ports:
      - "51820:51820/udp"  # VPN Tunnel Port
      - "51821:51821/tcp"  # Web UI Port
    environment:
      - LANG=en
      - WG_HOST=YOUR_SERVER_PUBLIC_IP  # <--- REPLACE THIS! ON LOCAL MACHINE WRITE 192.168.X.X, BUT IN ADDRESS BAR TYPE localhost:51821
      - PASSWORD=secret_password       # <--- REPLACE THIS!
      - WG_PORT=51820
      - WG_DEFAULT_DNS=1.1.1.1
      
      # Amnezia Stealth Parameters (Obfuscation)
      # These default values mimic random junk traffic
      - Jc=4          # Junk packet count (3-10 is standard)
      - Jmin=50       # Min junk packet size
      - Jmax=1000     # Max junk packet size
      - S1=15         # Handshake header padding
      - S2=24         # Response header padding
      - H1=1          # Packet header type
      - H2=2
      
    volumes:
      - ./.amnezia-wg-config:/etc/wireguard

3. Start the Server

Run the container:
sudo docker compose up -d

TO CHECK RUNNING:
$ docker logs amnezia-wg-easy
$ lsmod | grep amnezia

$ nc -u -v 89.167.65.79 51820  # check UDP 51820 port connection
$ nc -v 89.167.65.79 51821     # check TCP 51821 port connection

4. Create Clients & Connect
Open your browser and go to: http://<YOUR_SERVER_IP>:51821

Login with the PASSWORD you set in the yaml file.

Click "New Client", give it a name, and click Create.

Download the .conf file.

5. Important: Client App Requirement
You cannot use the standard WireGuard app on your phone or PC with this server. The obfuscation (Jc, Jmin, etc.) is not supported by standard clients.

Download Client: Get the AmneziaWG app (not standard WireGuard) or the AmneziaVPN app from the Google Play Store or Apple App Store.

Import: Import the .conf file you downloaded into the AmneziaWG app.

Troubleshooting
"Protocol not supported" / Error starting container: AmneziaWG works best when it can load its kernel module. If you are on a very old VPS kernel or a containerized VPS (like OpenVZ/LXC), this might fail. It works best on KVM/DigitalOcean/Hetzner/AWS servers with standard Ubuntu kernels.

Connection works but no internet: Check if you opened UDP port 51820 in your cloud provider's firewall (AWS Security Groups, Oracle Security Lists, etc.).
----------------------------------------------------------

How to connect to Amnezia-WG VPN from Ubuntu:

Option 1: The Terminal (Recommended for you)
Since you are already comfortable with the terminal, this is the most stable method. It uses awg-quick, which is the Amnezia-specific version of the standard wg-quick tool.

Install the Tools (if not already done):
sudo apt update
sudo apt install -y amneziawg

Move your Config File:
Take the .conf file you downloaded from your Docker Web UI (e.g., client1.conf) and move it to the Amnezia folder:
sudo mkdir -p /etc/amnezia/amneziawg
sudo cp ~/Downloads/client1.conf /etc/amnezia/amneziawg/awg0.conf
sudo chmod 600 /etc/amnezia/amneziawg/awg0.conf

Start the VPN:
sudo awg-quick up awg0

Verify the Connection:
sudo awg show
# OR check your IP
curl ifconfig.me

Stop the VPN:
sudo awg-quick down awg0

IN CASE OF ERROR:
Failed to set DNS configuration: Unit dbus-org.freedesktop.resolve1.service not found.

Solution 3: The "I just want it to work" Way (Skip DNS)
If you don't care about the VPN managing your DNS (e.g., you are okay with using your default provider or you will set it manually), you can simply tell Amnezia to stop trying to configure it.

Open your config file:

nano /etc/amnezia/amneziawg/awg0.conf
Find the line that says DNS = ... and comment it out by adding a # at the start:

[Interface]
PrivateKey = <your_key>
Address = 10.8.0.2/24
# DNS = 1.1.1.1   <-- COMMENT THIS OUT

How to verify it's working
Once the command finishes without an error, check your status:

sudo awg show       #Shows your active tunnel, data sent/received, and "Latest handshake"
ip a                #You should see a new interface named awg0 with the IP 10.8.0.2
curl ifconfig.me    #This should now return your Server's IP, not your home IP