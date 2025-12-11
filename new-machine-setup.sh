#!/bin/bash

# Ubuntu Setup Script - Neovim, LazyVim, NVM, Java, SSH Keys
# Run with: bash setup.sh

set -e # Exit on any error

echo "=== Ubuntu Machine Setup ==="
echo ""

# Update system
echo "1. Updating system packages..."
sudo apt update
sudo apt upgrade -y

# Install build dependencies for Neovim
echo "2. Installing Neovim build dependencies..."
sudo apt install -y \
  build-essential \
  cmake \
  curl \
  git \
  ninja-build \
  gettext \
  libtool \
  libtool-bin \
  pkg-config \
  unzip

# Clone and build Neovim from source
echo "3. Building Neovim from source (stable branch)..."
cd /tmp
if [ -d "neovim" ]; then
  rm -rf neovim
fi
git clone https://github.com/neovim/neovim.git
cd neovim
git checkout stable
make CMAKE_BUILD_TYPE=Release
sudo make install

# Verify Neovim installation
echo "4. Verifying Neovim installation..."
nvim --version

# Install LazyVim distro
echo "5. Installing LazyVim..."
if [ -d "$HOME/.config/nvim" ]; then
  echo "Backing up existing nvim config..."
  mv "$HOME/.config/nvim" "$HOME/.config/nvim.backup"
fi

git clone https://github.com/LazyVim/starter "$HOME/.config/nvim"
cd "$HOME/.config/nvim"
rm -rf .git
echo "LazyVim installed successfully!"

# Install NVM (Node Version Manager)
echo "6. Installing NVM..."
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash

# Source NVM in current shell
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Install Node.js LTS
echo "7. Installing Node.js LTS..."
nvm install --lts
nvm use --lts

# Install Java
echo "8. Installing Java 17..."
sudo apt install -y openjdk-17-jdk

# Set JAVA_HOME in bashrc
echo "9. Setting JAVA_HOME..."
JAVA_PATH=$(readlink -f $(which java) | sed 's|/bin/java||')
echo "export JAVA_HOME=$JAVA_PATH" >>~/.bashrc
echo "export PATH=\$PATH:\$JAVA_HOME/bin" >>~/.bashrc

# Install additional useful development tools
echo "10. Installing additional development tools..."
sudo apt install -y \
  tmux \
  htop \
  wget \
  vim \
  zsh \
  ripgrep \
  fzf \
  bat \
  exa

# SSH Key Generation
echo ""
echo "11. SSH Key Setup"
echo "================================"
read -p "Enter your email for SSH key (used with GitHub): " ssh_email

# Create .ssh directory if it doesn't exist
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# Generate SSH key for GitHub
echo "Generating SSH key for GitHub..."
ssh-keygen -t ed25519 -C "$ssh_email" -f ~/.ssh/github_key -N ""

# Generate SSH key for server access (optional second key)
read -p "Generate a separate SSH key for server access? (y/n): " generate_server_key
if [ "$generate_server_key" = "y" ]; then
  read -p "Enter name for server key (default: server_key): " server_key_name
  server_key_name=${server_key_name:-server_key}
  ssh-keygen -t ed25519 -C "$ssh_email" -f ~/.ssh/"$server_key_name" -N ""
  echo "Server key generated: ~/.ssh/$server_key_name"
fi

# Configure SSH config for GitHub
echo "12. Configuring SSH config..."
cat >>~/.ssh/config <<'EOF'

# GitHub SSH Configuration
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/github_key
    AddKeysToAgent yes
    IdentitiesOnly yes
EOF

# Add server key to SSH config if generated
if [ "$generate_server_key" = "y" ]; then
  cat >>~/.ssh/config <<EOF

# Server SSH Configuration
Host *
    IdentityFile ~/.ssh/$server_key_name
    AddKeysToAgent yes
EOF
fi

chmod 600 ~/.ssh/config

# Display GitHub public key
echo ""
echo "================================"
echo "SSH Key Setup Complete!"
echo "================================"
echo ""
echo "Your GitHub public key:"
echo "---"
cat ~/.ssh/github_key.pub
echo "---"
echo ""
echo "Add this key to GitHub:"
echo "1. Go to https://github.com/settings/keys"
echo "2. Click 'New SSH key'"
echo "3. Paste the key above"
echo ""

if [ "$generate_server_key" = "y" ]; then
  echo "Server key location: ~/.ssh/$server_key_name.pub"
  echo "Copy this to your servers' ~/.ssh/authorized_keys"
  echo ""
fi

# Reload bashrc
source ~/.bashrc

echo "=== Setup Complete! ==="
echo ""
echo "Next steps:"
echo "1. Source your shell: source ~/.bashrc"
echo "2. Test SSH connection to GitHub: ssh -T git@github.com"
echo "3. Verify installations:"
echo "   - nvim --version"
echo "   - node --version"
echo "   - nvm --version"
echo "   - java -version"
echo "4. LazyVim is ready at ~/.config/nvim"
echo ""
