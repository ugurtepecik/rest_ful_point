defmodule RestFulPoint.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  alias Phoenix.PubSub
  alias RestFulPointWeb.Endpoint
  alias RestFulPointWeb.Repo
  alias RestFulPointWeb.Telemetry

  @impl true
  def start(_type, _args) do
    children = [
      Telemetry,
      Repo,
      {DNSCluster, query: Application.get_env(:rest_ful_point, :dns_cluster_query) || :ignore},
      {PubSub, name: RestFulPoint.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: RestFulPoint.Finch},
      # Start a worker by calling: RestFulPoint.Worker.start_link(arg)
      # {RestFulPoint.Worker, arg},
      # Start to serve requests, typically the last entry
      Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: RestFulPoint.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    Endpoint.config_change(changed, removed)
    :ok
  end
end
