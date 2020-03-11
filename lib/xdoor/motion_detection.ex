defmodule Xdoor.MotionDetection do
  use GenServer
  require Logger
  alias Xdoor.{LockState, LockControl, OnboardLed}

  @poll_frequency_ms 200
  @gpio_motion_sensor 7
  @no_motion_threshold_ms 5 * 60 * 1000

  def last_motion() do
    Application.get_env(:xdoor, :last_motion, 0)
  end

  def reset_last_motion() do
    Logger.info("Resetting last motion")
    Application.put_env(:xdoor, :last_motion, System.os_time(:millisecond))
  end

  def start_link(_) do
    GenServer.start_link(__MODULE__, [])
  end

  def init(_) do
    {:ok, gpio} = Circuits.GPIO.open(@gpio_motion_sensor, :input)
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

    last_motion = last_motion()
    current_time = System.os_time(:millisecond)

    case Circuits.GPIO.read(gpio) do
      0 ->
        OnboardLed.set(0)

        if current_time > last_motion + @no_motion_threshold_ms do
          Logger.debug("No Motion Detected, above threshold. #{current_time} #{last_motion} #{@no_motion_threshold_ms}")

          if LockState.locked?() do
            # Logger.debug("Lock already closed")
            reset_last_motion()
            :timer.sleep(5000)
          else
            Logger.info("No motion deteced for #{inspect(@no_motion_threshold_ms)} ms and lock is open, closing")
            LockControl.close()
            :timer.sleep(5000)
          end
        else
          Logger.debug("No Motion Detected, below threshold")
        end

      1 ->
        OnboardLed.set(1)
        Application.put_env(:xdoor, :last_motion, current_time)
        Logger.debug("Motion Detected")
    end
  end
end
