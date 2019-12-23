# Pull in Nerves-specific helpers to the IEx session
use Toolshed
alias Tr33Control.Commands

# Logger.configure(level: :debug)

if RingLogger in Application.get_env(:logger, :backends, []) do
  RingLogger.tail(300)
  RingLogger.attach()
end
