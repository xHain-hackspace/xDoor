import Config

config :xdoor,
  storage_dir: "/data/xdoor",
  ssh_port: 22,
  authorized_keys_update_interval_ms: 60 * 60 * 1000,
  gpio_enabled: true,
  enable_monitor: true

config :shoehorn,
  init: [:nerves_runtime, :nerves_pack],
  app: Mix.Project.config()[:app]

config :nerves_runtime, :kernel, use_system_registry: false

config :nerves,
  erlinit: [
    hostname_pattern: "xdoor"
  ]

keys = [
  "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFk68ujMEgPVglDNnxqrht/0piGwofQy4GmPjgq4CvUV"
]

if keys == [],
  do:
    Mix.raise("""
    No SSH public keys found in ~/.ssh. An ssh authorized key is needed to
    log into the Nerves device and update firmware on it using ssh.
    See your project's config.exs for this error message.
    """)

config :nerves_ssh,
  port: 23,
  authorized_keys: keys

config :vintage_net,
  regulatory_domain: "DE",
  config: [
    {"eth0",
     %{
       type: VintageNetEthernet,
       ipv4: %{method: :dhcp}
     }}
  ]

config :nerves, :firmware, fwup_conf: "custom_boot/fwup.conf"

config :mdns_lite,
  # The `host` key specifies what hostnames mdns_lite advertises.  `:hostname`
  # advertises the device's hostname.local. For the official Nerves systems, this
  # is "nerves-<4 digit serial#>.local".  mdns_lite also advertises
  # "nerves.local" for convenience. If more than one Nerves device is on the
  # network, delete "nerves" from the list.
  hosts: ["xdoor"],
  ttl: 120

config :logger, level: :info
