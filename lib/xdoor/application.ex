defmodule Xdoor.Application do
  use Application

  @mqtt_config [
    mqtt_host: "homeassistant.lan.xhain.space",
    username: "homeassistant",
    password: File.read!("secrets/mqtt_pw") |> String.trim(),
    client_id: "xdoor"
  ]

  def start(_type, _args) do
    ensure_storage_dir()

    children = [
      Xdoor.Monitor,
      Xdoor.SSHServer,
      Xdoor.AuthorizedKeys,
      {ExHomeassistant, @mqtt_config},
      Xdoor.LockState
    ]

    opts = [strategy: :one_for_one, name: Xdoor.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def ensure_storage_dir() do
    storage_dir = Application.fetch_env!(:xdoor, :storage_dir)

    if !File.exists?(storage_dir) do
      File.mkdir_p!(storage_dir)
    end
  end
end
