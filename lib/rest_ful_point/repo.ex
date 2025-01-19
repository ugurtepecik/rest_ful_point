defmodule RestFulPoint.Repo do
  use Ecto.Repo,
    otp_app: :rest_ful_point,
    adapter: Ecto.Adapters.Postgres
end
