import Config

# Add configuration that is only needed when running on the host here.

config :xdoor,
  storage_dir: "./storage",
  ssh_port: 8022,
  authorized_keys_update_interval_ms: 20 * 1000,
  gpio_enabled: false

config :nerves_ssh,
  authorized_keys: [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFk68ujMEgPVglDNnxqrht/0piGwofQy4GmPjgq4CvUV"
  ]
