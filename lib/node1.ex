defmodule Node1 do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(Node1.Poller, [])
    ]

    opts = [strategy: :one_for_one, name: Node1.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def send_message(chat_id, text) do
    case Nadia.send_message(chat_id, text) do
      {:ok, _result} ->
        :ok

      {:error, %Nadia.Model.Error{reason: "Please wait a little"}} ->
        :wait
    end
  end
end
