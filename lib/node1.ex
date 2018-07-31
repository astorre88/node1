defmodule Node1 do
  @moduledoc """
  Application supervisor module. Starts consumer and poller processes.
  """

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(Node1.AmqpConsumer, []),
      worker(Node1.Poller, [])
    ]

    opts = [strategy: :one_for_one, name: Node1.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
