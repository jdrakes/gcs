defmodule GCS.TestClient do
  @behaviour GCS.Client
  def request(_method, url, _body, _headers, return: :url) do
    {:ok, url}
  end

  def request(_method, _url, _body, _headers, _opts) do
    {:ok, "a body"}
  end
end
