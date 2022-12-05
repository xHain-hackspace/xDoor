defmodule Xdoor.LockControl do
  require Logger

  @greeting :code.priv_dir(:xdoor) |> Path.join("greeting") |> File.read!()

  def open() do
    # IO.write(@greeting)
    IO.write("OPENING DOOR\n")
    toggle_gpio(23)
    Logger.info("Door is opening")
  end

  def close() do
    # IO.write(@greeting)
    IO.write("CLOSING DOOR\n")
    toggle_gpio(24)
    Logger.info("Door is closing")
  end

  defp toggle_gpio(pin_number) do
    if Application.get_env(:xdoor, :gpio_enabled, false) do
      {:ok, gpio} = Circuits.GPIO.open(pin_number, :output)
      Circuits.GPIO.write(gpio, 1)
      :timer.sleep(1000)
      Circuits.GPIO.write(gpio, 0)
      Circuits.GPIO.close(gpio)
    end
  end
end
