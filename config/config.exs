import Config

config :goth, disabled: true

if :test == Mix.env() do
  config :gcs, :http_client, GCS.TestClient
end
