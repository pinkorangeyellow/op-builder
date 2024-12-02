#!/bin/bash
set -euo pipefail

# 安装 ttyd
if ! command -v ttyd &>/dev/null; then
    sudo snap install ttyd --classic
fi

# 安装 starship
if ! command -v starship &>/dev/null; then
    curl -fsSLO https://starship.rs/install.sh
    sh ./install.sh --yes
    rm ./install.sh
fi

# 配置 starship
STARSHIP_INIT='eval "$(starship init bash)"'
if ! grep -q "$STARSHIP_INIT" /home/runner/.bashrc; then
    echo "$STARSHIP_INIT" >> /home/runner/.bashrc
fi
if ! grep -q "$STARSHIP_INIT" /root/.bashrc; then
    echo "$STARSHIP_INIT" | sudo tee -a /root/.bashrc >/dev/null
fi

# 配置 SSH 密钥
add_ssh_key() {
    local user_home=$1
    local ssh_dir="$user_home/.ssh"
    local key_content=$2
    
    mkdir -p "$ssh_dir"
    echo "$key_content" >> "$ssh_dir/authorized_keys"
    chmod 600 "$ssh_dir/authorized_keys"
}

SSH_KEY_1="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC7a9wzWBmnjDtO39GZ0Z1wEGMkR1YRxeZkVNvPQ8GkZKHYdtCrqX+SdRBczo2xdJbHM9cDJNtOJKZp1/n4MCuMVMD8ea93npMjIXpt+lP7cGvyEYAhRrzKEiy3+jAVxnK9wDRpAGAI6uL5mLk9TAO3bt42Tzf02GGjgHqPshiVsBee2Y+rNqPWOb1a0gp302DlORo5stW4zLmRgvwEaxbcEr02lct4ly1s0fjjTJIxXHfOcs+tviW77IcXh1BeE+OvKLAHvfCalMnmm8q1WxDHk4feqCt/pq5pMWnvqg+PQlOLFT1Ff7T4Hi22shmy0Jbuor3HksxrdIcpl6hNAzeH"
SSH_KEY_2="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCpN4ZLZCLDnINMNIwRRkHgy90LtGTRbk/EEGk5q7skStUkTFAtm1IarT12qicZJozfDVciM9BpuYchH+bSVAdKCAo+kv1Z7xVqxpjmPwGRGXju3p5vucOIF2F8B58h6ddsyEzvcqiN4du+VBZsWJR+ZO6XCrZO0ejO+5aBloUfqCOSd/f3pp6PQ1Hw55pXvwMIDkj8kiDJcDa9NvbLrjgwJ2DEqihOC4MkCyr+CfZd5Tz5URmNf0aXUKWQJcQPDltngXa94MihE6PJCA/ftBkBVXtQBIa1fcO+Tx56Nsvlpu7GS7RgQ5EkkeVNmQ2VR50ZPme0G+SFrfsqElez2KyCuXCD/AcQl7rBmP5d6K9Z8aGnom8hVrJY7Mk3NYuPgkVRWfDm2uEEy5DpowfMwsdrrL4D6ml1nDvrIjXdcWqd21E4/aJGRmPcDWXb9cQy2J4LdYuaupjzLzPAv1x/wL7lUXtzjeoMNeIY9pZhAYMULZ0G58l4DqlC0fN3zqzAQA8="

add_ssh_key /home/runner "$SSH_KEY_1"
add_ssh_key /home/runner "$SSH_KEY_2"
sudo bash -c "add_ssh_key /root \"$SSH_KEY_1\""
sudo bash -c "add_ssh_key /root \"$SSH_KEY_2\""

# 启动 Cloudflare Tunnel
if [ -n "${CLOUDFLARED_TOKEN:-}" ]; then
    docker run --net=host cloudflare/cloudflared:latest tunnel --no-autoupdate run --token "$CLOUDFLARED_TOKEN"
else
    echo "Error: CLOUDFLARED_TOKEN 环境变量未设置。" >&2
    exit 1
fi

# 运行后续任务
echo "[SSH] 继续运行后续任务..."
