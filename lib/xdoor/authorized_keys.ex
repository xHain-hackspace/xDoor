defmodule Xdoor.AuthorizedKeys do
  use GenServer
  require Logger

  @update_interval_ms 60 * 60 * 1000
  @try_interval_ms 5 * 1000
  @perist_to_filename Application.fetch_env!(:xdoor, :storage_dir) |> Path.join("authorized_keys")

  def list() do
    Application.get_env(:xdoor, :authorized_keys, [])
  end

  def start_link(_) do
    GenServer.start_link(__MODULE__, [])
  end

  def init(_) do
    if File.exists?(@perist_to_filename) do
      authorized_keys = File.read!(@perist_to_filename)
      Application.put_env(:xdoor, :authorized_keys, :public_key.ssh_decode(authorized_keys, :auth_keys))
    end

    update()
    {:ok, %{}}
  end

  def handle_info(:update, state) do
    update()
    {:noreply, state}
  end

  defp update() do
    Process.send_after(self(), :update, @try_interval_ms)
    since_last_update = System.os_time(:millisecond) - Application.get_env(:xdoor, :authorized_keys_last_update, 0)

    if since_last_update > @update_interval_ms do
      spawn(fn -> update_request() end)
    end
  end

  defp update_request() do
    {:ok, %Mojito.Response{body: authorized_keys}} = Mojito.request(:get, "https://xdoor.x-hain.de/authorized_keys")
    {:ok, %Mojito.Response{body: signature}} = Mojito.request(:get, "https://xdoor.x-hain.de/authorized_keys.sig")

    public_key =
      :code.priv_dir(:xdoor)
      |> Path.join("authorized_keys_pub.pem")
      |> ExPublicKey.load!()

    ExPublicKey.verify(authorized_keys, Base.decode64!(signature), public_key)
    |> case do
      {:ok, true} ->
        Logger.info("Updated authorized_keys: Valid signature")
        Application.put_env(:xdoor, :authorized_keys, :public_key.ssh_decode(authorized_keys, :auth_keys))
        Application.put_env(:xdoor, :authorized_keys_last_update, System.os_time(:millisecond))
        File.write!(@perist_to_filename, authorized_keys)

      error ->
        Logger.error("Error validating signature of authorized_keys: #{inspect(error)}")
    end
  end
end
