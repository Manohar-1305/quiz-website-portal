#!/bin/bash

# ==============================================
#  FLASK QUIZ APP AUTO SETUP (ERROR-FREE VERSION)
#  Works from anywhere, no nested clone issues
# ==============================================

LOG_FILE="/root/setup_log.txt"

# Log helper
log_message() {
    echo "$(date) - $1" | tee -a "$LOG_FILE"
}

# Fixed app install path (universal, avoids recursion)
APP_DIR="/root/quiz-website-portal"
SERVICE_PATH="/etc/systemd/system/flaskapp.service"
REPO_URL="https://github.com/Manohar-1305/quiz-website-portal.git"

log_message "Installation target: $APP_DIR"

# ----------------------------------------------
# STEP 1: Install system packages
# ----------------------------------------------
apt-get update -y
apt-get install -y git python3 python3-pip python3.12-venv pkg-config libmysqlclient-dev || {
    log_message "Package installation failed!"
    exit 1
}

# ----------------------------------------------
# STEP 2: Prepare directory and clone repo
# ----------------------------------------------
if [ -d "$APP_DIR/quiz-website-portal" ]; then
    log_message "Removing nested folder to prevent duplication..."
    rm -rf "$APP_DIR/quiz-website-portal"
fi

if [ ! -d "$APP_DIR/.git" ]; then
    log_message "Cloning repository..."
    rm -rf "$APP_DIR"
    git clone "$REPO_URL" "$APP_DIR" && log_message "Repository cloned successfully." || {
        log_message "Repository cloning failed."
        exit 1
    }
else
    log_message "Repository already exists. Pulling latest changes..."
    cd "$APP_DIR" && git pull && log_message "Repository updated successfully."
fi

cd "$APP_DIR"

# ----------------------------------------------
# STEP 3: Create virtual environment
# ----------------------------------------------
if [ ! -d "$APP_DIR/venv" ]; then
    log_message "Creating Python virtual environment..."
    python3 -m venv venv && log_message "Virtual environment created." || {
        log_message "Virtual environment creation failed!"
        exit 1
    }
fi

log_message "Activating virtual environment..."
source "$APP_DIR/venv/bin/activate"

# ----------------------------------------------
# STEP 4: Install Python dependencies
# ----------------------------------------------
log_message "Upgrading pip and installing dependencies..."
pip install --upgrade pip
if [ -f "$APP_DIR/requirements.txt" ]; then
    pip install -r "$APP_DIR/requirements.txt" && log_message "Dependencies installed from requirements.txt"
else
    pip install flask flask_sqlalchemy flask_login flask_migrate pymysql && log_message "Installed Flask essentials"
fi

# ----------------------------------------------
# STEP 5: Create log file
# ----------------------------------------------
touch "$APP_DIR/app.log"
chmod 666 "$APP_DIR/app.log"
log_message "Log file ready."

# ----------------------------------------------
# STEP 6: Create systemd service
# ----------------------------------------------
log_message "Creating systemd service..."
sudo bash -c "cat > $SERVICE_PATH" <<EOF
[Unit]
Description=Flask Quiz App
After=network.target

[Service]
User=root
Group=root
WorkingDirectory=$APP_DIR
Environment='PATH=$APP_DIR/venv/bin'
ExecStart=$APP_DIR/venv/bin/python3 $APP_DIR/app.py
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

log_message "Systemd service created at $SERVICE_PATH"

# ----------------------------------------------
# STEP 7: Enable and start service
# ----------------------------------------------
sudo systemctl daemon-reload
sudo systemctl enable flaskapp.service
sudo systemctl restart flaskapp.service

# ----------------------------------------------
# STEP 8: Verify
# ----------------------------------------------
sleep 2
log_message "Checking service status..."
systemctl status flaskapp.service --no-pager

log_message "✅ Flask Quiz App setup completed successfully."
