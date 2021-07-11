defmodule KVServer.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    port = String.to_integer(System.get_env("PORT") || "4040")

    children = [
      # Starts a worker by calling: KVServer.Worker.start_link(arg)
      # {KVServer.Worker, arg}

      # the children started by this supervisor is temporary
      # it should have restart: :temporary
      {Task.Supervisor, name: KVServer.TaskSupervisor},

      # by default, a Task restart: is set to :temporary, i.e. the children of this supervisor are not restarted
      # but we want our Task's children KVServer.accept here to be restarted when it crashed
      Supervisor.child_spec({Task, fn -> KVServer.accept(port) end}, restart: :permanent)
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: KVServer.Supervisor]

    # start 2 supervisors
    Supervisor.start_link(children, opts)
  end
end
