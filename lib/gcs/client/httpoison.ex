defmodule GCS.Client.HTTPoison do
  @behaviour GCS.Client
  alias HTTPoison.{Response, Error}

  @doc false
  def request(method, url, body, headers, opts) do
    HTTPoison.request(method, url, body, headers, opts)
    |> handle_response()
  end

  defp handle_response({:ok, %Response{status_code: status, body: body}})
       when status in [200, 204],
       do: {:ok, Jason.decode(body)}

  defp handle_response({:ok, %Response{status_code: _code}}),
    do: {:error, :unexpected_gcs_response}

  defp handle_response({:ok, %Error{reason: :timeout}}), do: {:error, :gateway_timeout}
  defp handle_response({:ok, %Error{reason: reason}}), do: {:error, reason}
end
