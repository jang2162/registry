terraform {
  required_version = ">= 1.0"

  required_providers {
    coder = {
      source  = "coder/coder"
      version = ">= 2.5"
    }
  }
}

variable "agent_id" {
  type        = string
  description = "The ID of a Coder agent."
}

variable "zellij_version" {
  type        = string
  description = "The version of zellij to install."
  default     = "0.43.1"
}

variable "zellij_config" {
  type        = string
  description = "Custom zellij configuration to apply."
  default     = ""
}

variable "order" {
  type        = number
  description = "The order determines the position of app in the UI presentation. The lowest order is shown first and apps with equal order are sorted by name (ascending order)."
  default     = null
}

variable "group" {
  type        = string
  description = "The name of a group that this app belongs to."
  default     = null
}

variable "icon" {
  type        = string
  description = "The icon to use for the app."
  default     = "/icon/zellij.svg"
}

variable "sessions" {
  type        = list(string)
  description = "List of zellij sessions to create or start."
  default     = ["default"]
}

resource "coder_script" "zellij" {
  agent_id     = var.agent_id
  display_name = "Zellij"
  icon         = "/icon/zellij.svg"
  script = templatefile("${path.module}/scripts/run.sh", {
    ZELLIJ_VERSION = var.zellij_version
    ZELLIJ_CONFIG  = var.zellij_config
  })
  run_on_start = true
  run_on_stop  = false
}

resource "coder_app" "zellij_sessions" {
  for_each = toset(var.sessions)

  agent_id     = var.agent_id
  slug         = "zellij-${each.value}"
  display_name = "Zellij - ${each.value}"
  icon         = var.icon
  order        = var.order
  group        = var.group

  command = templatefile("${path.module}/scripts/start.sh", {
    SESSION_NAME = each.value
  })
}