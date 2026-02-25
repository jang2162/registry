#!/usr/bin/env bash

BOLD='\033[0;1m'

# Convert templated variables to shell variables
ZELLIJ_VERSION="${ZELLIJ_VERSION}"
ZELLIJ_CONFIG="${ZELLIJ_CONFIG}"

# Function to check if zellij is already installed
is_installed() {
  command -v zellij >/dev/null 2>&1
}

# Function to get installed version
get_installed_version() {
  if is_installed; then
    zellij --version | grep -oP 'zellij \K[0-9]+\.[0-9]+\.[0-9]+'
  else
    echo ""
  fi
}

# Function to install zellij
install_zellij() {
  printf "Checking for zellij installation\n"

  INSTALLED_VERSION=$(get_installed_version)

  if [ -n "$INSTALLED_VERSION" ]; then
    if [ "$INSTALLED_VERSION" = "$ZELLIJ_VERSION" ]; then
      printf "zellij version $ZELLIJ_VERSION is already installed \n\n"
      return 0
    else
      printf "zellij version $INSTALLED_VERSION is installed, but version $ZELLIJ_VERSION is required\n"
    fi
  fi

  printf "Installing zellij version $ZELLIJ_VERSION \n\n"

  # Detect architecture
  ARCH=$(uname -m)
  case "$ARCH" in
    x86_64)
      ARCH="x86_64"
      ;;
    aarch64 | arm64)
      ARCH="aarch64"
      ;;
    *)
      printf "ERROR: Unsupported architecture: $ARCH\n"
      exit 1
      ;;
  esac

  # Download and install zellij
  DOWNLOAD_URL="https://github.com/zellij-org/zellij/releases/download/v$${ZELLIJ_VERSION}/zellij-$${ARCH}-unknown-linux-musl.tar.gz"
  TEMP_DIR=$(mktemp -d)

  printf "Downloading zellij version $ZELLIJ_VERSION for $ARCH...\n"
  printf "URL: $DOWNLOAD_URL\n"

  if ! curl -fsSL "$DOWNLOAD_URL" -o "$TEMP_DIR/zellij.tar.gz"; then
    printf "ERROR: Failed to download zellij\n"
    rm -rf "$TEMP_DIR"
    exit 1
  fi

  printf "Extracting zellij...\n"
  tar -xzf "$TEMP_DIR/zellij.tar.gz" -C "$TEMP_DIR"

  printf "Installing zellij to /usr/local/bin...\n"
  sudo mv "$TEMP_DIR/zellij" /usr/local/bin/zellij
  sudo chmod +x /usr/local/bin/zellij

  # Cleanup
  rm -rf "$TEMP_DIR"

  # Verify installation
  if is_installed; then
    FINAL_VERSION=$(get_installed_version)
    printf "✓ zellij version $FINAL_VERSION installed successfully\n"
  else
    printf "ERROR: zellij installation failed\n"
    exit 1
  fi
}

# Function to setup zellij configuration
setup_zellij_config() {
  printf "Setting up zellij configuration \n"

  local config_dir="$HOME/.config/zellij"
  local config_file="$config_dir/config.kdl"

  mkdir -p "$config_dir"

  if [ -n "$ZELLIJ_CONFIG" ]; then
    printf "$ZELLIJ_CONFIG" > "$config_file"
    printf "$${BOLD}Custom zellij configuration applied at $config_file \n\n"
  else
    cat > "$config_file" << 'EOF'
// Zellij Configuration File

keybinds {
    normal {
        // Session management
        bind "Ctrl s" { NewPane; }
        bind "Ctrl q" { Quit; }
    }
}

// UI configuration
ui {
    pane_frames {
        rounded_corners true
    }
}

// Session configuration
session_serialization true
pane_frames true
simplified_ui false

// Scroll settings
scroll_buffer_size 10000
copy_on_select true

// Theme
theme "default"
EOF
    printf "zellij configuration created at $config_file \n\n"
  fi
}

# Main execution
main() {
  printf "$${BOLD}🛠️ Setting up zellij! \n\n"
  printf ""

  # Install zellij
  install_zellij

  # Setup zellij configuration
  setup_zellij_config

  printf "$${BOLD}✅ zellij setup complete! \n\n"
  printf "$${BOLD}Start a session with: zellij\n"
}

# Run main function
main