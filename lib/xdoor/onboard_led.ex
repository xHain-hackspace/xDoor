defmodule Xdoor.OnboardLed do
  require Logger

  # Trigger file for LED0
  @led_trigger "/sys/class/leds/led1/trigger"

  # Brightness file for LED0
  @led_brightntess "/sys/class/leds/led1/brightness"

  def init() do
    # Setting the trigger to 'none' by default its 'mmc0'
    File.write(@led_trigger, "none")
  end

  def set(1), do: set_brightness("1")
  def set(0), do: set_brightness("0")

  def set_brightness(val) do
    File.write(@led_brightntess, val)
  end
end
