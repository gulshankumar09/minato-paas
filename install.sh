#!/bin/bash
set -e

# ==============================================================================
# Minato PaaS Installation Script
# This script downloads the latest release from GitHub and installs it as a service.
# ==============================================================================

# REPLACE THIS WITH YOUR ACTUAL GITHUB REPO (e.g., username/minato)
GITHUB_REPO="gulshankumar09/minato-paas"

echo "🚀 Installing Minato PaaS..."

# 1. Detect OS and Architecture
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)

if [ "$ARCH" = "x86_64" ]; then
    ARCH="amd64"
elif [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then
    ARCH="arm64"
else
    echo "❌ Unsupported architecture: $ARCH"
    exit 1
fi

echo "📦 Detected System: $OS-$ARCH"

# 2. Fetch the latest release URL from GitHub API
echo "🔍 Fetching latest release..."
API_RESPONSE=$(curl -s "https://api.github.com/repos/$GITHUB_REPO/releases/latest")

if echo "$API_RESPONSE" | grep -q '"message": "Not Found"'; then
    echo "❌ GitHub API Error: No releases found for $GITHUB_REPO."
    echo "Make sure you have published a release on GitHub."
    exit 1
elif echo "$API_RESPONSE" | grep -q '"message":'; then
    ERROR_MSG=$(echo "$API_RESPONSE" | grep '"message":' | cut -d '"' -f 4)
    echo "❌ GitHub API Error: $ERROR_MSG"
    exit 1
fi

LATEST_URL=$(echo "$API_RESPONSE" | grep "browser_download_url" | grep "minato_${OS}_${ARCH}.tar.gz" | cut -d '"' -f 4)

if [ -z "$LATEST_URL" ]; then
    echo "❌ Could not find a matching release for $OS $ARCH."
    echo "Please check your GitHub repository releases page."
    exit 1
fi

# 3. Download and Extract
echo "⬇️ Downloading from $LATEST_URL..."
curl -fsSL -o /tmp/minato.tar.gz "$LATEST_URL"

echo "📂 Extracting binaries..."
mkdir -p /tmp/minato-release
tar -xzf /tmp/minato.tar.gz -C /tmp/minato-release/

# 4. Install Binaries
echo "⚙️ Installing binaries to /usr/local/bin..."
sudo mv /tmp/minato-release/minato-backend /usr/local/bin/
sudo mv /tmp/minato-release/minato-agent /usr/local/bin/
sudo chmod +x /usr/local/bin/minato-backend
sudo chmod +x /usr/local/bin/minato-agent

# Clean up temporary files
rm -rf /tmp/minato.tar.gz /tmp/minato-release

# 5. Create Systemd Service for the Master Node
echo "📝 Configuring Systemd Service..."
cat << 'EOF' | sudo tee /etc/systemd/system/minato.service
[Unit]
Description=Minato PaaS Master Node
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/minato-backend
Restart=always
RestartSec=5
User=root
# Optional: Set environment variables here
# Environment="MINATO_ENV=production"

[Install]
WantedBy=multi-user.target
EOF

# 6. Start the Service
echo "🟢 Starting Minato Service..."
sudo systemctl daemon-reload
sudo systemctl enable minato
sudo systemctl restart minato

# 7. Provide Access Information
PUBLIC_IP=$(curl -s ifconfig.me || echo "YOUR_SERVER_IP")

echo ""
echo "✅ Minato installed successfully!"
echo "🌐 Access your dashboard at: http://$PUBLIC_IP:8081"
echo ""
echo "To view logs, run: sudo journalctl -fu minato"
