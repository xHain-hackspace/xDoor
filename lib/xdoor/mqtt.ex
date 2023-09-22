defmodule Xdoor.Mqtt do
  use GenServer
  require Logger

  @mqtt_host ~c"automation.lan.xhain.space"
  @username "homeassistant"
  @password File.read!("secrets/mqtt_pw") |> String.trim()
  @config_topic "homeassistant/binary_sensor/xdoor/config"
  @state_topic "homeassistant/binary_sensor/xdoor/state"
  @device_config %{
    name: nil,
    device_class: "lock",
    state_topic: @state_topic,
    unique_id: "xdoor_93ns",
    device: %{identifiers: ["xdoor_93ns"], name: "xDoor"}
  }

  defmodule State do
    defstruct [:emqtt_pid, connected: false]
  end

  def start_link([]) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def send_lockstate(lockstate) when is_boolean(lockstate) do
    lockstate_str =
      case lockstate do
        false -> "ON"
        true -> "OFF"
      end

    GenServer.cast(__MODULE__, {:send_lockstate, lockstate_str})
  end

  def init(:ok) do
    Process.flag(:trap_exit, true)

    :timer.send_interval(1000, self(), :connect)

    send(self(), :connect)

    {:ok, %State{}}
  end

  # all ok, do nothing
  def handle_info(:connect, %State{connected: true, emqtt_pid: emqtt_pid} = state) when is_pid(emqtt_pid) do
    {:noreply, state}
  end

  # no mqtt pid, start client
  def handle_info(:connect, %State{emqtt_pid: nil} = state) do
    emqtt_opts = [
      clientid: "xdoor",
      host: @mqtt_host,
      port: 1883,
      proto_ver: :v5,
      username: @username,
      password: @password,
      name: :emqtt
    ]

    Logger.info("MQTT: Starting client")
    {:ok, emqtt_pid} = :emqtt.start_link(emqtt_opts)

    send(self(), :connect)

    {:noreply, %State{state | emqtt_pid: emqtt_pid, connected: false}}
  end

  # client not connected, try to connect
  def handle_info(:connect, %State{emqtt_pid: emqtt_pid} = state) do
    Logger.info("MQTT: Connecting to broker")

    case :emqtt.connect(emqtt_pid) do
      {:ok, props} ->
        Logger.info("MQTT: Connected. Response #{inspect(props)}")
        Logger.info("MQTT: Sending device config.")
        :ok = :emqtt.publish(emqtt_pid, @config_topic, Jason.encode!(@device_config))

        Xdoor.LockState.locked?() |> send_lockstate()

        {:noreply, %State{state | connected: true}}

      {:error, reason} ->
        Logger.warning("MQTT: Connection failed: #{inspect(reason)}.")
        {:noreply, %State{state | connected: false}}
    end
  end

  def handle_info({:EXIT, _pid, reason}, state) do
    Logger.warning("MQTT client died: #{inspect(reason)}.")
    {:noreply, %State{state | connected: false, emqtt_pid: nil}}
  end

  def handle_cast({:send_lockstate, lockstate_str}, %State{emqtt_pid: nil} = state) do
    Logger.warning("MQTT not connected: cannot publish #{lockstate_str}")
    {:noreply, state}
  end

  def handle_cast({:send_lockstate, lockstate_str}, %State{} = state) do
    :emqtt.publish(state.emqtt_pid, @state_topic, lockstate_str)
    {:noreply, state}
  end
end
