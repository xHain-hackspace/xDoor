defmodule Xdoor.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Xdoor.Supervisor]

    children = [
      {Finch, name: Xdoor.Finch},
      Xdoor.Monitor,
      Xdoor.SSHServer,
      Xdoor.AuthorizedKeys
      # Xdoor.LockState
      # Xdoor.MotionDetection
    ]

    ensure_storage_dir()
    Supervisor.start_link(children, opts)
  end

  def ensure_storage_dir() do
    storage_dir = Application.fetch_env!(:xdoor, :storage_dir)

    if !File.exists?(storage_dir) do
      File.mkdir_p!(storage_dir)
    end
  end
end
