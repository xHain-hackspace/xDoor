defmodule Xdoor.AuthorizedKeys do
  use GenServer
  require Logger

  @update_interval_ms Application.compile_env!(:xdoor, :authorized_keys_update_interval_ms)
  @perist_to_filename Application.compile_env!(:xdoor, :storage_dir) |> Path.join("authorized_keys")
  @log_dir Application.compile_env!(:xdoor, :storage_dir) |> Path.join("logs")

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
      Application.put_env(:xdoor, :authorized_keys, :ssh_file.decode(authorized_keys, :auth_keys))
    end

    admin_keys =
      Application.get_env(:nerves_ssh, :authorized_keys, [])
      |> Enum.flat_map(&:ssh_file.decode(&1, :auth_keys))

    Application.put_env(:xdoor, :authorized_keys_admin, admin_keys)

    schedule_update()
    {:ok, %{}}
  end

  def handle_info(:update, state) do
    schedule_update()
    {:noreply, state}
  end

  defp schedule_update() do
    Process.send_after(self(), :update, @update_interval_ms)
    spawn(fn -> update() end)
  end

  @authorized_keys_base_url "https://valkyrie.x-hain.de"

  def update() do
    Logger.info("Updating authorized keys")
    host = Application.get_env(:xdoor, :host)

    %Req.Response{status: 200, body: authorized_keys} =
      Req.get!("#{@authorized_keys_base_url}/authorized_keys", headers: [{"X-door-hostname", host}])

    %Req.Response{status: 200, body: signature} = Req.get!("#{@authorized_keys_base_url}/authorized_keys.sig")

    public_key =
      :code.priv_dir(:xdoor)
      |> Path.join("authorized_keys_pub.pem")
      |> ExPublicKey.load!()

    ExPublicKey.verify(authorized_keys, Base.decode64!(signature), public_key)
    |> case do
      {:ok, true} ->
        Logger.debug("Fetching authorized_keys: Valid signature")

        current_keys = Application.get_env(:xdoor, :authorized_keys, "")
        new_keys = :ssh_file.decode(authorized_keys, :auth_keys)

        Application.put_env(:xdoor, :authorized_keys_last_update, System.os_time(:millisecond))

        if :erlang.phash2(new_keys) != :erlang.phash2(current_keys) do
          Application.put_env(:xdoor, :authorized_keys, new_keys)
          File.write!(@perist_to_filename, authorized_keys)
          Logger.info("Authorized keys changed")
        else
          Logger.info("No changes to authorized keys")
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
