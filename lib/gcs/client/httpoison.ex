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
       do: {:ok, body}

  defp handle_response({:ok, %Response{status_code: _code}}),
    do: {:error, :unexpected_gcs_response}

  defp handle_response({:error, %Error{reason: reason}}), do: {:error, reason}
end
