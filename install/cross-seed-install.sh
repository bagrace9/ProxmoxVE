#!/usr/bin/env bash

# Copyright (c) 2021-2026 community-scripts ORG
# Author: Jakub Matraszek (jmatraszek)
# License: MIT | https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE
# Source: https://www.cross-seed.org | Github: https://github.com/cross-seed/cross-seed

source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing Dependencies"
$STD apt install -y \
  build-essential \
  pkg-config \
  python3-dev \
  libsqlite3-dev
msg_ok "Installed Dependencies"

NODE_VERSION="24" setup_nodejs
ensure_dependencies build-essential pkg-config python3-dev libsqlite3-dev

msg_info "Setup Cross-Seed"
# Use --unsafe-perm so npm lifecycle scripts can run correctly inside the container.
$STD npm install -g --unsafe-perm cross-seed@latest
$STD cross-seed gen-config
msg_ok "Setup Cross-Seed"

msg_info "Creating Service"
cat <<EOF >/etc/systemd/system/cross-seed.service
[Unit]
Description=Cross-Seed daemon Service
After=network.target

[Service]
ExecStart=/usr/bin/cross-seed daemon
Restart=on-failure
RestartSec=30
User=root

[Install]
WantedBy=multi-user.target
EOF
systemctl enable -q --now cross-seed
msg_ok "Created Service"

motd_ssh
customize
cleanup_lxc
