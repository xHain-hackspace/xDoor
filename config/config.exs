import Config

config :xdoor, target: Mix.target()

# Customize non-Elixir parts of the firmware. See
# https://hexdocs.pm/nerves/advanced-configuration.html for details.

config :nerves, :firmware, rootfs_overlay: "rootfs_overlay"

# Set the SOURCE_DATE_EPOCH date for reproducible builds.
# See https://reproducible-builds.org/docs/source-date-epoch/ for more information

config :nerves, source_date_epoch: "1602059153"

config :logger,
  backends: [:console, RingLogger],
  level: :debug

config :ring_logger, format: "$time $metadata[$level]$levelpad $message\n"

config :nerves_leds, names: [green: "led0", red: "led1"]

if Mix.target() == :host or Mix.target() == :"" do
  import_config "host.exs"
else
  import_config "target.exs"
end
