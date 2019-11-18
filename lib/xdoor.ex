defmodule Xdoor do
  def logins() do
    Application.get_env(:xdoor, :storage_dir)
    |> Path.join("logins")
    |> File.read!()
    |> IO.puts()
  end

  def lock_state_changes() do
    Application.get_env(:xdoor, :storage_dir)
    |> Path.join("lock_state_changes")
    |> File.read!()
    |> IO.puts()
  end
end
