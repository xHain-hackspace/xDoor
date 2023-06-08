# Add Toolshed helpers to the IEx session
use Toolshed

NervesMOTD.print()

Logger.configure(level: :debug)

if RingLogger in Application.get_env(:logger, :backends, []) do
  RingLogger.tail(250)
  RingLogger.attach()
end
