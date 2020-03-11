defmodule Xdoor.LockState do
  use GenServer
  require Logger

  @poll_frequency_ms 100
  @gpio_lock_sensor 8

  def locked?() do
    Application.get_env(:xdoor, :lock_state)
  end

  def start_link(_) do
    GenServer.start_link(__MODULE__, [])
  end

  def init(_) do
    {:ok, gpio} = Circuits.GPIO.open(@gpio_lock_sensor, :input)
    state = %{gpio: gpio}
    poll_gpio(state)
    {:ok, state}
  end

  def handle_info(:poll_gpio, state) do
    poll_gpio(state)
    {:noreply, state}
  end

  defp poll_gpio(%{gpio: gpio}) do
    Process.send_after(self(), :poll_gpio, @poll_frequency_ms)

    last_state = locked?()

    current_state =
      case Circuits.GPIO.read(gpio) do
        0 -> true
        1 -> false
      end

    if last_state != current_state do
      Logger.info("Locked? state changed from :#{last_state} to #{current_state}")
      log(current_state)

      Application.put_env(:xdoor, :lock_state, current_state)
    end
  end

  defp log(state) do
    file =
      Application.fetch_env!(:xdoor, :storage_dir)
      |> Path.join("lock_state_changes")
      |> File.open!([:append])

    IO.puts(file, "#{DateTime.utc_now() |> DateTime.to_iso8601()};#{state}")
    File.close(file)
  end
end
