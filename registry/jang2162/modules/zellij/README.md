---
display_name: Zellij
description: Modern terminal workspace with session management
icon: ../../../../.icons/zellij.svg
verified: false
tags: [zellij, terminal, multiplexer]
---

# Zellij

Automatically install and configure [zellij](https://github.com/zellij-org/zellij), a modern terminal workspace with session management. Supports multiple named sessions, custom configuration, and session persistence.

```tf
module "zellij" {
  count          = data.coder_workspace.me.start_count
  source         = "registry.coder.com/jang2162/zellij/coder"
  version        = "1.0.0"
  agent_id       = coder_agent.example.id
}
```

## Features

- Installs zellij if not already present
- Configures zellij with sensible defaults
- Supports custom configuration (KDL format)
- Session serialization enabled by default
- **Multiple named sessions, each as a separate app in the Coder UI**
- Cross-platform architecture support (x86_64, aarch64)

## Examples

### Basic Usage

```tf
module "zellij" {
  count          = data.coder_workspace.me.start_count
  source         = "registry.coder.com/jang2162/zellij/coder"
  version        = "1.0.0"
  agent_id       = coder_agent.example.id
}
```

### Multiple Sessions

```tf
module "zellij" {
  count          = data.coder_workspace.me.start_count
  source         = "registry.coder.com/jang2162/zellij/coder"
  version        = "1.0.0"
  agent_id       = coder_agent.example.id
  sessions       = ["default", "dev", "ops"]
  group          = "Terminal"
  order          = 1
}
```

### Custom Configuration

```tf
module "zellij" {
  count          = data.coder_workspace.me.start_count
  source         = "registry.coder.com/jang2162/zellij/coder"
  version        = "1.0.0"
  agent_id       = coder_agent.example.id
  zellij_config  = <<-EOT
    keybinds {
        normal {
            bind "Ctrl t" { NewTab; }
        }
    }
    theme "dracula"
  EOT
}
```

## How It Works

### Installation Process (scripts/run.sh)

1. **Version Check**: Checks if zellij is already installed with the correct version
2. **Architecture Detection**: Detects system architecture (x86_64 or aarch64)
3. **Download**: Downloads the appropriate zellij binary from GitHub releases
4. **Installation**: Installs zellij to `/usr/local/bin/zellij`
5. **Configuration**: Creates default or custom configuration at `~/.config/zellij/config.kdl`

### Session Management (scripts/start.sh)

1. **Installation Check**: Verifies zellij is installed
2. **Session Check**: Checks if the requested session exists
3. **Attach or Create**:
   - If session exists: attaches to it
   - If session doesn't exist: creates a new session

## Default Configuration

The default configuration includes:

- Session serialization enabled for persistence
- 10,000 line scroll buffer
- Copy on select enabled
- Rounded pane frames
- Key bindings: `Ctrl+s` (new pane), `Ctrl+q` (quit)

> [!IMPORTANT]
> - Custom `zellij_config` replaces the default configuration entirely
> - Requires `curl` and `tar` for installation
> - Uses `sudo` to install to `/usr/local/bin/`
> - Supported architectures: x86_64, aarch64