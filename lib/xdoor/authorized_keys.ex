defmodule Xdoor.AuthorizedKeys do
  use GenServer
  require Logger

  def list() do
    Application.get_env(:xdoor, :authorized_keys, [])
  end

  def start_link(_) do
    GenServer.start_link(__MODULE__, [])
  end

  def init(_) do
    fetch()
    {:ok, %{}}
  end

  def handle_info(:update, state) do
    {:noreply, state}
  end

  defp fetch() do
    keys =
      :code.priv_dir(:xdoor)
      |> Path.join("authorized_keys")
      |> Path.join("authorized_keys")
      |> File.read!()
      |> :public_key.ssh_decode(:auth_keys)

    Application.put_env(:xdoor, :authorized_keys, keys)
  end
end
