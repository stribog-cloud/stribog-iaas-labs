# Option 1: the official installer script (Linux and macOS)
curl --proto '=https' --tlsv1.2 -fsSL https://get.opentofu.org/install-opentofu.sh -o install-opentofu.sh
chmod +x install-opentofu.sh
# Read the script first. Then choose a method:
# deb (Debian, Ubuntu), rpm (Fedora, RHEL), or standalone (any Linux)
./install-opentofu.sh --install-method deb
rm -f install-opentofu.sh

# Option 2: Homebrew (macOS or Linux)
brew install opentofu

# Option 3: Snap (works on most distributions)
sudo snap install --classic opentofu
