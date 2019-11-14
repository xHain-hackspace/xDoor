defmodule Xdoor.SSHServer do
  use GenServer
  require Logger
  alias Xdoor.{SSHKeys, LockControl}

  @greeting :code.priv_dir(:xdoor) |> Path.join("greeting") |> File.read!()
  def start_link(_) do
    GenServer.start_link(__MODULE__, [])
  end

  def init(_) do
    system_dir = :code.priv_dir(:xdoor) |> Path.join("host_key") |> to_charlist()
    port = Application.fetch_env!(:xdoor, :ssh_port)

    Logger.info("Starting xdoor ssh server on port #{port}")

    {:ok, server_pid} =
      :ssh.daemon(port, [
        {:id_string, :random},
        {:system_dir, system_dir},
        {:user_dir, system_dir},
        {:key_cb, {SSHKeys, []}},
        {:shell, &start_shell/2},
        {:exec, &start_exec/3},
        {:auth_methods, 'publickey'}
      ])

    Process.link(server_pid)

    {:ok, %{server_pid: server_pid}}
  end

  def start_shell('open' = user, _peer) do
    Logger.info("Starting shell for user #{user}")
    spawn(fn -> LockControl.open() end)
  end

  def start_shell('close' = user, _peer) do
    Logger.info("Starting shell for user #{user}")
    spawn(fn -> LockControl.close() end)
  end

  def start_exec(_cmd, _user, _peer) do
    spawn(fn ->
      IO.puts("Command execution not alllowed.")
    end)
  end
end
