defmodule GCS do
  @moduledoc """
  A simple library to interact with Google Cloud Storage
  """
  alias GCS.{Client, Auth}
  require Logger
  @make_public_body ~s({"role":"READER"})
  @type headers :: [{String.t(), String.t()}]

  @doc """
  TODO
  """
  @spec delete_object(any, binary, headers, any) :: {:ok, any}
  def delete_object(bucket, delete_path, headers \\ [], http_opts \\ []) do
    url = delete_url(bucket, delete_path)
    headers = prepare_auth_header(headers, :read_write)
    Client.request(:delete, url, nil, headers, http_opts)
  end

  @doc """
  TODO
  """
  @spec download_object(any, binary, headers, any) :: {:ok, any}
  def download_object(bucket, download_path, headers \\ [], http_opts \\ []) do
    url = download_url(bucket, download_path)
    headers = prepare_auth_header(headers, :read_only)
    Client.request(:get, url, nil, headers, http_opts)
  end

  @doc """
  TODO
  """
  @spec upload_object(any, binary, any, any, headers, any) :: {:ok, any}
  def upload_object(bucket, upload_path, file_path, content_type, headers \\ [], http_opts \\ []) do
    url = upload_url(bucket, upload_path)

    headers =
      headers
      |> prepare_auth_header(:read_only)
      |> add_content_type_header(content_type)

    Client.request(:get, url, {:file, file_path}, headers, http_opts)
  end

  @doc """
  TODO
  """
  @spec make_public(any, binary, headers, any) :: {:ok, any}
  def make_public(bucket, upload_path, headers \\ [], http_opts \\ []) do
    url = make_public_url(bucket, upload_path)
    Client.request(:put, url, @make_public_body, headers, http_opts)
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

  defp prepare_auth_header(headers, token_type) when is_list(headers) do
    [{"Authorization", "Bearer #{Auth.get_token(token_type)}"} | headers]
  end

  defp add_content_type_header(headers, content_type) when is_list(headers) do
    [{"Content-Type", content_type} | headers]
  end
end
