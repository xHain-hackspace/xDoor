import Config

# Add configuration that is only needed when running on the host here.

config :xdoor,
  storage_dir: "./storage",
  ssh_port: 8022,
  authorized_keys_update_interval_ms: 20 * 1000,
  gpio_enabled: false
