defmodule Komplen.Repo do
  use Ecto.Repo,
    otp_app: :komplen,
    adapter: Ecto.Adapters.Postgres
end
