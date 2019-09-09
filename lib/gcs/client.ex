defmodule GCS.Client do
  @moduledoc """
  A behavior for defining your own http_client callback module, allowing you
  to use your favorite HTTP client in place of HTTPoison
  """
  @type method :: :get | :put | :post | :delete
  @type path :: String.t()
  @type headers :: [{String.t(), String.t()}]
  @type body :: iodata
  @type opts :: Keyword.t()
  @type reason :: any

  @doc """
  Called by GCS when making HTTP requests.
  """
  @callback request(method, path, body, headers, opts) :: {:ok, body} | {:error, reason}

  @http_client Application.get_env(:gcs, :http_client, GCS.Client.HTTPoison)
  @doc false
  def request(method, path, body, headers, opts) do
    @http_client.request(method, path, body, headers, opts)
  end
end
