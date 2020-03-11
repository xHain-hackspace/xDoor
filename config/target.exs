use Mix.Config

config :xdoor,
  storage_dir: "/root/xdoor",
  ssh_port: 22,
  authorized_keys_update_interval_ms: 60 * 60 * 1000,
  gpio_enabled: true

keys = [
  "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMBSfSmc2s5m8HpuSxyD2LP0FgpyYDs7oan/lfdwN9sZ",
  "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFk68ujMEgPVglDNnxqrht/0piGwofQy4GmPjgq4CvUV"
]

config :nerves_firmware_ssh,
  authorized_keys: keys

# config :nerves_network, :default,
# wlan0: [
#   ssid: System.get_env("NERVES_NETWORK_SSID"),
#   psk: System.get_env("NERVES_NETWORK_PSK"),
#   key_mgmt: String.to_atom("WPA-PSK")
# ],
# eth0: [
#   ipv4_address_method: :dhcp
# ]

# regulatory_domain: "DE"

config :nerves_init_gadget,
  ifname: "eth0",
  address_method: :dhcp,
  mdns_domain: nil,
  node_name: "xdoor",
  node_host: :mdns_domain,
  ssh_console_port: 8022

config :logger,
  level: :info,
  backends: [RingLogger]

config :ring_logger,
  format: "$time $metadata[$level]$levelpad$message\n"
