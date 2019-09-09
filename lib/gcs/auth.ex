defmodule GCS.Auth do
  @doc false
  alias Goth.Token
  base_url = "https://www.googleapis.com/auth/"

  type_enum = [
    read_only: "devstorage.read_only",
    read_write: "devstorage.read_write",
    full_control: "devstorage.full_control",
    sql_admin: "sqlservice.admin",
    cs_read_only: "cloud-platform.read-only",
    cs: "cloud-platform",
    compute_read_only: "compute.readonly",
    compute: "compute"
  ]

  def get_token(type)

  for {type, resource} <- type_enum do
    def get_token(unquote(type)) do
      {:ok, token_response} = Token.for_scope(unquote(base_url <> resource))

      token_response |> Map.get(:token)
    rescue
      MatchError -> nil
    end
  end
end
