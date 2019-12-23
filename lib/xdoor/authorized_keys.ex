defmodule Xdoor.AuthorizedKeys do
  use GenServer
  require Logger

  @update_interval_ms Application.fetch_env!(:xdoor, :authorized_keys_update_interval_ms)
  @retry_interval_ms 10 * 1000
  @perist_to_filename Application.fetch_env!(:xdoor, :storage_dir) |> Path.join("authorized_keys")
  @log_dir Application.fetch_env!(:xdoor, :storage_dir) |> Path.join("logs")

  def list() do
    Application.get_env(:xdoor, :authorized_keys, [])
  end

  def list_admin() do
    Application.get_env(:xdoor, :authorized_keys_admin, [])
  end

  def start_link(_) do
    GenServer.start_link(__MODULE__, [])
  end

  def init(_) do
    if File.exists?(@perist_to_filename) do
      authorized_keys = File.read!(@perist_to_filename)
      Application.put_env(:xdoor, :authorized_keys, :public_key.ssh_decode(authorized_keys, :auth_keys))
    end

    admin_keys =
      Application.get_env(:nerves_firmware_ssh, :authorized_keys, [])
      |> Enum.flat_map(&:pubkey_ssh.decode(&1, :public_key))

    Application.put_env(:xdoor, :authorized_keys_admin, admin_keys)

    update()
    {:ok, %{}}
  end

  def handle_info(:update, state) do
    update()
    {:noreply, state}
  end

  defp update() do
    Process.send_after(self(), :update, @retry_interval_ms)
    since_last_update = System.os_time(:millisecond) - Application.get_env(:xdoor, :authorized_keys_last_update, 0)

    if since_last_update > @update_interval_ms do
      spawn(fn -> update_request() end)
    end
  end

  def update_request() do
    {:ok, %Mojito.Response{body: authorized_keys}} = Mojito.request(:get, "https://xdoor.x-hain.de/authorized_keys")

    {:ok, %Mojito.Response{body: signature}} = Mojito.request(:get, "https://xdoor.x-hain.de/authorized_keys.sig")

    public_key =
      :code.priv_dir(:xdoor)
      |> Path.join("authorized_keys_pub.pem")
      |> ExPublicKey.load!()

    ExPublicKey.verify(authorized_keys, Base.decode64!(signature), public_key)
    |> case do
      {:ok, true} ->
        Logger.info("Fetching authorized_keys: Valid signature")

        current_keys = Application.get_env(:xdoor, :authorized_keys, "")
        new_keys = :public_key.ssh_decode(authorized_keys, :auth_keys)

        Application.put_env(:xdoor, :authorized_keys_last_update, System.os_time(:millisecond))

        if new_keys != current_keys do
          Application.put_env(:xdoor, :authorized_keys, new_keys)
          File.write!(@perist_to_filename, authorized_keys)
          Logger.info("Updated authorized keys")
        else
          Logger.debug("No changes to authorized keys")
        end

      error ->
        Logger.error("Error validating signature of authorized_keys: #{inspect(error)}")
    end
  end

  def persist_logs() do
    File.mkdir(@log_dir)
    date_str = DateTime.utc_now() |> DateTime.to_iso8601()
    log_filename = Path.join(@log_dir, "#{date_str}.logs")
    RingLogger.save(log_filename)
  end
end
