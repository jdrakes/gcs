defmodule GCS.Client.HTTPoison do
  @behaviour GCS.Client
  alias HTTPoison.{Response, Error}

  @doc false
  def request(method, url, body, headers, opts) do
    HTTPoison.request(method, url, body, headers, opts)
    |> handle_response()
  end

  defp handle_response({:ok, %Response{status_code: status, body: body, headers: headers}})
       when status in [200, 204],
       do: {:ok, decode_body(headers, body)}

  defp handle_response({:ok, %Response{status_code: _code}}),
    do: {:error, :unexpected_gcs_response}

  defp handle_response({:ok, %Error{reason: :timeout}}), do: {:error, :gateway_timeout}
  defp handle_response({:ok, %Error{reason: reason}}), do: {:error, reason}

  defp decode_body(headers, body) do
    case List.keyfind(headers, "Content-Type", 0) do
      "application/json" -> Jason.decode(body)
      _ -> body
    end
  end
end
