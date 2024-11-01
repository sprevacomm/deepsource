#!/bin/bash
# Nexus Repository Manager Installation Script with RubyGems Repository Provisioning and Onboarding Automation
# For Rocky Linux 9
# Run this script as root or with sudo privileges.
# Exit immediately if a command exits with a non-zero status
set -ue
# Variables
NEXUS_USER="nexus"
NEXUS_HOME="/opt/nexus"
NEXUS_DATA="/opt/sonatype-work"
NEXUS_SERVICE="/etc/systemd/system/nexus.service"
NEXUS_PORT="8081"
DOWNLOAD_URL="https://download.sonatype.com/nexus/3/latest-unix.tar.gz"
FIREWALLD_STATE=$(systemctl is-active firewalld || true)
ADMIN_PASSWORD_FILE="$NEXUS_DATA/nexus3/admin.password"
RUBYGEMS_REPO_NAME="rubygems-hosted"
NEXUS_API_URL="http://localhost:$NEXUS_PORT/service/rest"
LOG_FILE="/tmp/nexus_installation.log"
echo "Starting Nexus Repository Manager installation..."
# Function to log messages
log() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}
# Step 1: Update the System
log "Updating system packages..."
dnf update -y
# Step 2: Install Java OpenJDK 11
log "Installing Java OpenJDK 11..."
dnf install -y java-11-amazon-corretto
# dnf install -y java-11-openjdk
# Verify Java installation
java -version
# Step 3: Install jq and wget
log "Installing jq..."
dnf install -y jq wget
# Step 4: Create a Dedicated Nexus User
log "Creating Nexus user..."
useradd -M -d "$NEXUS_HOME" -s /bin/bash "$NEXUS_USER" || true
# Step 5: Download Nexus Repository Manager
log "Downloading Nexus Repository Manager..."
cd /opt
wget -O nexus.tar.gz "$DOWNLOAD_URL"
# Step 6: Extract Nexus Archive
log "Extracting Nexus..."
tar -zxvf nexus.tar.gz
rm -f nexus.tar.gz
# Dynamically find the extracted directory name
EXTRACTED_DIR=$(ls -d nexus-3* | head -1)
if [ -d "$EXTRACTED_DIR" ]; then
    mv "$EXTRACTED_DIR" nexus
    log "Extracted directory '$EXTRACTED_DIR' moved to 'nexus'."
else
    log "Error: Extracted Nexus directory not found."
    exit 1
fi
chown -R "$NEXUS_USER":"$NEXUS_USER" "$NEXUS_HOME"
# Step 7: Configure Nexus
log "Configuring Nexus..."
echo "run_as_user=\"$NEXUS_USER\"" > "$NEXUS_HOME/bin/nexus.rc"
# Ensure the data directory exists and set permissions
if [ ! -d "$NEXUS_DATA" ]; then
    mkdir -p "$NEXUS_DATA"
    log "Created Nexus data directory at '$NEXUS_DATA'."
fi
chown -R "$NEXUS_USER":"$NEXUS_USER" "$NEXUS_DATA"
# Step 8: Accept the EULA
log "Accepting EULA..."
sudo -u "$NEXUS_USER" mkdir -p "$NEXUS_DATA/nexus3/eula"
sudo -u "$NEXUS_USER" touch "$NEXUS_DATA/nexus3/eula/accepted"
log "EULA accepted."
# Step 9: Configure Firewall
if [ "$FIREWALLD_STATE" == "active" ]; then
    log "Configuring firewall..."
    firewall-cmd --permanent --add-port="$NEXUS_PORT"/tcp
    firewall-cmd --reload
    log "Firewall configured to allow port $NEXUS_PORT/tcp."
else
    log "Firewall is not active or not installed. Skipping firewall configuration."
fi
# Step 10: Create a Systemd Service File
log "Creating systemd service file..."
cat > "$NEXUS_SERVICE" << EOF
[Unit]
Description=Nexus Repository Manager
After=network.target
[Service]
Type=forking
LimitNOFILE=65536
User=$NEXUS_USER
Group=$NEXUS_USER
ExecStart=$NEXUS_HOME/bin/nexus start
ExecStop=$NEXUS_HOME/bin/nexus stop
ExecReload=$NEXUS_HOME/bin/nexus restart
TimeoutSec=300
Restart=on-failure
[Install]
WantedBy=multi-user.target
EOF
log "Systemd service file created at '$NEXUS_SERVICE'."
# Step 11: Enable and Start Nexus Service
log "Enabling and starting Nexus service..."
systemctl daemon-reload
systemctl enable nexus
systemctl start nexus
log "Nexus service enabled and started."
# Step 12: Wait for Nexus to Start
log "Waiting for Nexus to start (this may take a few minutes)..."
# Wait until Nexus REST API is available and returns status 200
until curl -s -o /dev/null -w "%%{http_code}" http://localhost:$NEXUS_PORT/service/rest/v1/status | grep -q "200"; do
    log "Waiting for Nexus REST API..."
    sleep 10
done
log "Nexus is up and running."
# Step 13: Change Default Admin Password
log "Changing default admin password..."
INITIAL_ADMIN_PASSWORD=$(cat "$ADMIN_PASSWORD_FILE")
# Check if INITIAL_ADMIN_PASSWORD is empty
if [ -z "$INITIAL_ADMIN_PASSWORD" ]; then
    log "Error: Initial admin password not found."
    exit 1
fi
CHANGE_PASSWORD_RESPONSE=$(curl -s -o /dev/null -w "%%{http_code}" -X PUT -u admin:"$INITIAL_ADMIN_PASSWORD" \
    --header "Content-Type: text/plain" \
    "http://localhost:$NEXUS_PORT/service/rest/v1/security/users/admin/change-password" \
    -d "${NEW_ADMIN_PASSWORD}")
if [ "$CHANGE_PASSWORD_RESPONSE" -eq 204 ]; then
    log "Admin password changed successfully."
else
    log "Error: Failed to change admin password. HTTP status code: $CHANGE_PASSWORD_RESPONSE"
    exit 1
fi
# Step 14: Disable Onboarding Wizard via Capabilities API
log "Disabling onboarding wizard via Capabilities API..."
# Step 14a: Retrieve the list of capabilities
CAPABILITIES_JSON=$(curl -s -u admin:"${NEW_ADMIN_PASSWORD}" "$NEXUS_API_URL/v1/capabilities")
# Extract the ID of the Onboarding capability
ONBOARDING_CAPABILITY_ID=$(echo "$CAPABILITIES_JSON" | jq -r '.items[] | select(.type == "Onboarding") | .id')
if [ "$ONBOARDING_CAPABILITY_ID" != "null" ] && [ -n "$ONBOARDING_CAPABILITY_ID" ]; then
    log "Found Onboarding capability with ID: $ONBOARDING_CAPABILITY_ID. Disabling it..."

    # Disable the Onboarding capability
    DELETE_CAPABILITY_RESPONSE=$(curl -s -o /dev/null -w "%%{http_code}" -X DELETE -u admin:"${NEW_ADMIN_PASSWORD}" \
        "$NEXUS_API_URL/v1/capabilities/$ONBOARDING_CAPABILITY_ID")

    if [ "$DELETE_CAPABILITY_RESPONSE" -eq 204 ]; then
        log "Onboarding capability disabled successfully."
    else
        log "Error: Failed to disable Onboarding capability. HTTP status code: $DELETE_CAPABILITY_RESPONSE"
        exit 1
    fi
else
    log "Onboarding capability not found or already disabled."
fi
# Step 15: Provision RubyGems-Hosted Repository
log "Provisioning RubyGems-hosted repository..."
# Prepare JSON payload using jq
CREATE_REPO_JSON=$(jq -n \
    --arg name "$RUBYGEMS_REPO_NAME" \
    '{
      name: $name,
      online: true,
      storage: {
        blobStoreName: "default",
        strictContentTypeValidation: true,
        writePolicy: "ALLOW"
      }
    }')
CREATE_REPO_RESPONSE=$(curl -s -o /dev/null -w "%%{http_code}" -X POST -u admin:"${NEW_ADMIN_PASSWORD}" \
    --header "Content-Type: application/json" \
    "$NEXUS_API_URL/v1/repositories/rubygems/hosted" \
    -d "$CREATE_REPO_JSON")
if [ "$CREATE_REPO_RESPONSE" -eq 201 ]; then
    log "RubyGems-hosted repository '$RUBYGEMS_REPO_NAME' created successfully."
else
    log "Error: Failed to create RubyGems-hosted repository. HTTP status code: $CREATE_REPO_RESPONSE"
    exit 1
fi
log "Nexus Repository Manager installation and repository provisioning completed."
log "Access Nexus at: http://<your_server_ip>:$NEXUS_PORT"
