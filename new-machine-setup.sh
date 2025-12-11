#!/bin/bash

# Ubuntu Setup Script - Neovim, NVM, Java, and Dependencies
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

# Install NVM (Node Version Manager)
echo "5. Installing NVM..."
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash

# Source NVM in current shell
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Install Node.js LTS
echo "6. Installing Node.js LTS..."
nvm install --lts
nvm use --lts

# Install Java
echo "7. Installing Java 17..."
sudo apt install -y openjdk-17-jdk

# Set JAVA_HOME in bashrc
echo "8. Setting JAVA_HOME..."
JAVA_PATH=$(readlink -f $(which java) | sed 's|/bin/java||')
echo "export JAVA_HOME=$JAVA_PATH" >>~/.bashrc
echo "export PATH=\$PATH:\$JAVA_HOME/bin" >>~/.bashrc

# Install additional useful development tools
echo "9. Installing additional development tools..."
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

# Install Android Studio dependencies (optional, uncomment if needed)
# echo "10. Installing Android Studio dependencies..."
# sudo apt install -y \
#     lib32z1 \
#     lib32ncurses6

# Reload bashrc
source ~/.bashrc

echo ""
echo "=== Setup Complete! ==="
echo ""
echo "Next steps:"
echo "1. Source your shell: source ~/.bashrc"
echo "2. Verify installations:"
echo "   - nvim --version"
echo "   - node --version"
echo "   - nvm --version"
echo "   - java -version"
echo "3. Configure Neovim: mkdir -p ~/.config/nvim"
echo ""
