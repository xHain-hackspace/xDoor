defmodule Xdoor.SSHServer do
  use GenServer
  require Logger
  alias Xdoor.SSHKeys

  def start_link(_) do
    GenServer.start_link(__MODULE__, [])
  end

  def init(_) do
    system_dir = :code.priv_dir(:xdoor) |> Path.join("host_key") |> to_charlist()
    port = Application.fetch_env!(:xdoor, :ssh_port)

    {:ok, server_pid} =
      :ssh.daemon(port, [
        {:id_string, :random},
        {:system_dir, system_dir},
        {:user_dir, system_dir},
        {:key_cb, {SSHKeys, []}},
        {:shell, &start_shell/2},
        {:exec, &start_exec/3}
      ])

    Process.link(server_pid)

    {:ok, %{server_pid: server_pid}}
  end

  def start_shell(_user, _peer) do
    spawn(fn ->
      IO.puts("Hello @ xdoor")
    end)
  end

  def start_exec(_cmd, _user, _peer) do
    spawn(fn ->
      IO.puts("Command execution not alllowed.")
    end)
  end
end
