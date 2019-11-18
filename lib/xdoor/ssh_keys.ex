defmodule Xdoor.SSHKeys do
  require Logger

  def host_key(algorithm, options) do
    :ssh_file.host_key(algorithm, options)
  end

  def is_auth_key(key, user, _options) when user in ['open', 'close'] do
    Xdoor.AuthorizedKeys.list()
    |> Enum.find(fn {k, _info} -> k == key end)
    |> case do
      {_key, info} ->
        log(user, info)
        true

      _ ->
        false
    end
  end

  def is_auth_key(key, 'admin' = user, _options) do
    Logger.debug("Admin login attempt")

    Xdoor.AuthorizedKeys.list_admin()
    |> Enum.find(fn {k, _info} -> k == key end)
    |> case do
      {_key, info} ->
        log(user, info)
        true

      _ ->
        false
    end
  end

  defp log(user, info) do
    file =
      Application.fetch_env!(:xdoor, :storage_dir)
      |> Path.join("logins")
      |> File.open!([:append])

    IO.puts(file, "#{DateTime.utc_now() |> DateTime.to_iso8601()};#{Keyword.get(info, :comment)};#{user}")
    File.close(file)
  end
end
