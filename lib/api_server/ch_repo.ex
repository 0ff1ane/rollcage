defmodule ApiServer.ChRepo do
  use Ecto.Repo,
    otp_app: :api_server,
    adapter: Ecto.Adapters.ClickHouse
end
