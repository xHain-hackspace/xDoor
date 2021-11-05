defmodule Xdoor.AuthorizedKeysApi do
  use Tesla

  plug(Tesla.Middleware.BaseUrl, "https://xdoor.x-hain.de/")

  plug(Tesla.Middleware.Retry,
    delay: 2000,
    max_retries: 20,
    should_retry: fn
      {:ok, %{status: status}} when status > 200 -> true
      {:ok, _} -> false
      {:error, _} -> true
    end
  )

  def authorized_keys() do
    get("/authorized_keys")
  end

  def signature() do
    get("/authorized_keys.sig")
  end
end
