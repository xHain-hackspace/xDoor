defmodule Xdoor.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Xdoor.Supervisor]

    children =
      [
        Xdoor.SSHServer,
        Xdoor.AuthorizedKeys
      ] ++ children(target())

    ensure_logdir()
    Supervisor.start_link(children, opts)
  end

  # List all child processes to be supervised
  def children(:host) do
    [
      # Children that only run on the host
      # Starts a worker by calling: Xdoor.Worker.start_link(arg)
      # {Xdoor.Worker, arg},
    ]
  end

  def children(_target) do
    [
      # Children for all targets except host
      # Starts a worker by calling: Xdoor.Worker.start_link(arg)
      # {Xdoor.Worker, arg},
    ]
  end

  def target() do
    Application.get_env(:xdoor, :target)
  end

  def ensure_logdir() do
    log_dir = Application.fetch_env!(:xdoor, :logfile) |> Path.dirname()

    if !File.exists?(log_dir) do
      File.mkdir_p!(log_dir)
    end
  end
end
