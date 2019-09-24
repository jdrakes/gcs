defmodule GCS do
  @moduledoc """
  A simple library to interact with Google Cloud Storage
  """
  alias GCS.{Client, Auth}
  require Logger
  @make_public_body ~s({"role":"READER"})
  @type headers :: [{String.t(), String.t()}]

  @doc """
  Uploads a file to GCS
  Requires the bucket name, the desired gcs file location *with desired filename*, the path to the file to be uploaded, and the content type of the file.
  """
  @spec upload_object(any, binary, any, any, headers, any) :: {:ok, any}
  def upload_object(
        bucket,
        gcs_file_path,
        file_path,
        content_type,
        headers \\ [],
        http_opts \\ []
      ) do
    url = upload_url(bucket, gcs_file_path)

    headers =
      headers
      |> add_auth_header(:read_write)
      |> add_content_type_header(content_type)

    Client.request(:post, url, {:file, file_path}, headers, http_opts)
    |> decode_json_response()
  end

  @doc """
  Downloads a file from GCS
  Requires the bucket name and the gcs file location *with filename*.

  *for example* if the `bucket` is `my-bucket` and the gcs file path is `myfile.png`,\
  the file would be retrieved from `my-bucket` at the location `myfile.png`

  *more examples*

  ```
  iex> File.write!("file.txt", "hello")
  :ok
  iex> GCS.upload_object("my-bucket", "myfile.txt", "file.txt", "Application/txt")
  {:ok, %{}} # GCS Response
  iex> GCS.download_object("my-bucket", "myfile.txt")
  "hello"
  ```
  """
  @spec download_object(any, binary, headers, any) :: {:ok, any}
  def download_object(bucket, gcs_file_path, headers \\ [], http_opts \\ []) do
    url = download_url(bucket, gcs_file_path)
    headers = add_auth_header(headers, :read_only)
    Client.request(:get, url, "", headers, http_opts)
  end

  @doc """
  Makes a file in GCS publicly accessible
  Requires the bucket name and the gcs file location *with filename*.

  The file will be available at `https://storage.googleapis.com/<bucket>/<file_path>`
  *for example* if the `bucket` is `my-bucket` and the gcs file path is `myfile.png`, the url would be
  `https://storage.googleapis.com/my-bucket/myfile.png`

  ```
  iex> File.write!("file.txt", "hello")
  :ok
  iex> GCS.upload_object("my-bucket", "myfile.txt", "file.txt", "Application/txt")
  {:ok, %{}} # GCS Response
  iex> GCS.make_public("my-bucket", "myfile.txt")
  {:ok, %{}} # GCS Response
  iex> SomeHTTPClient.get("https://storage.googleapis.com/my-bucket/myfile.txt")
  {:ok, %{body: "hello"}"}
  ```
  """
  @spec make_public(any, binary, headers, any) :: {:ok, any}
  def make_public(bucket, gcs_file_path, headers \\ [], http_opts \\ []) do
    url = make_public_url(bucket, gcs_file_path)

    headers =
      headers
      |> add_auth_header(:full_control)
      |> add_content_type_header("application/json")

    Client.request(:put, url, @make_public_body, headers, http_opts)
    |> decode_json_response()
  end

  @doc """
  Deletes a file from GCS
  Requires the bucket name and the gcs file location *with filename*.

  ```
  iex> File.write!("file.txt", "hello")
  :ok
  iex> GCS.upload_object("my-bucket", "myfile.txt", "file.txt", "Application/txt")
  {:ok, %{}} # GCS Response
  iex> GCS.make_public("my-bucket", "myfile.txt")
  {:ok, %{}} # GCS Response
  iex> SomeHTTPClient.get("https://storage.googleapis.com/my-bucket/myfile.txt")
  {:ok, %{body: "hello"}"}
  ```
  """
  @spec delete_object(any, binary, headers, any) :: {:ok, :deleted} | {:error, any}
  def delete_object(bucket, gcs_file_path, headers \\ [], http_opts \\ []) do
    url = delete_url(bucket, gcs_file_path)
    headers = add_auth_header(headers, :read_write)

    case Client.request(:delete, url, "", headers, http_opts) do
      {:ok, _} ->
        {:ok, :deleted}

      {:error, reason} ->
        format_errors(reason)
    end
  end

  defp delete_url(bucket, path) do
    "https://www.googleapis.com/storage/v1/b/#{bucket}/o/#{URI.encode_www_form(path)}"
  end

  defp download_url(bucket, path) do
    "https://www.googleapis.com/storage/v1/b/#{bucket}/o/#{URI.encode_www_form(path)}?alt=media"
  end

  defp upload_url(bucket, path) do
    "https://www.googleapis.com/upload/storage/v1/b/#{bucket}/o?uploadType=media&name=#{
      URI.encode_www_form(path)
    }"
  end

  defp make_public_url(bucket, path) do
    "https://www.googleapis.com/storage/v1/b/#{bucket}/o/#{URI.encode_www_form(path)}/acl/allUsers"
  end

  defp add_auth_header(headers, token_type) when is_list(headers) do
    [{"Authorization", "Bearer #{Auth.get_token(token_type)}"} | headers]
  end

  defp add_content_type_header(headers, content_type) when is_list(headers) do
    [{"Content-Type", content_type} | headers]
  end

  defp decode_json_response({:ok, body}) do
    case Jason.decode(body) do
      {:ok, decoded_body} -> {:ok, decoded_body}
      {:error, reason} -> {:error, reason}
    end
  end

  defp decode_json_response({:error, reason}), do: format_errors(reason)

  defp format_errors({:gcs_error, status, body}) do
    case Jason.decode(body) do
      {:ok, decoded_body} ->
        {:error,
         {:gcs_error, status,
          decoded_body["error"]["message"] || "Malformed json error response body"}}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp format_errors(error), do: {:error, error}
end
