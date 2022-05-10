defmodule Cluster.Strategy.Postgres do
  @moduledoc """
  Custom stategy where each node writes its cluster info to the `cluster_node` table
  Inspired/Forked from https://github.com/kevbuchanan/libcluster_postgres
  """

  use Supervisor

  alias Postgrex.Notifications
  alias Cluster.Strategy.State
  alias Cluster.Strategy.Postgres.Worker
  alias Cluster.Strategy.Postgres.Backoff

  alias Cluster.Logger

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts)
  end

  @impl true
  def init([%State{meta: nil} = state]) do
    Logger.debug(state.topology, "starting postgrex libcluster strategy")

    meta = %{
      connection: __MODULE__.Connection,
      notifications: __MODULE__.Notifications,
    }

    init([%State{state | :meta => meta}])
  end

  def init([%State{meta: meta, config: config} = state] = opts) do
    IO.inspect("initializing Postgres strategy")

    IO.inspect(meta, label: "PostgresStrategy meta")

    postgrex_opts = Keyword.put(config, :name, meta.connection)

    notifications_opts = {Notifications, Keyword.put(config, :name, meta.notifications)}
    worker_opts = {Worker, opts}

    IO.inspect(postgrex_opts, label: "postgres_opts")
    IO.inspect(notifications_opts, label: "notification_opts")

    {:ok, _} = Application.ensure_all_started(:postgrex)

    children = [
      Supervisor.child_spec({Postgrex, postgrex_opts}, id: :postgres_libcluster),
      Supervisor.child_spec({Backoff, notifications_opts}, id: :notifications),
      Supervisor.child_spec({Backoff, worker_opts}, id: :worker)
    ]

    Supervisor.start_link(children, strategy: :one_for_all)
  end

end
