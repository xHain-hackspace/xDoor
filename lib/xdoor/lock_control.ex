defmodule Xdoor.LockControl do
  require Logger

  def open() do
    IO.puts(@greeting)
    IO.puts("OPENING DOOR")
    toggle_gpio(23)
    Logger.info("Door opened")
  end

  def close() do
    IO.puts(@greeting)
    IO.puts("CLOSING DOOR")
    toggle_gpio(24)
    Logger.info("Door closed")
  end

  defp toggle_gpio(pin_number) do
    if Application.get_env(:xdoor, :gpio_enabled, false) do
      {:ok, gpio} = Circuits.GPIO.open(pin_number, :output)
      Circuits.GPIO.write(gpio, 1)
      :timer.sleep(100)
      Circuits.GPIO.write(gpio, 0)
      Circuits.GPIO.close(gpio)
    end
  end
end
