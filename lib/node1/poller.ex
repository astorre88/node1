defmodule Node1.Poller do
  use GenServer
  require Logger

  # API

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def update do
    GenServer.cast(__MODULE__, :update)
  end

  # Server

  def init(:ok) do
    update()
    {:ok, 0}
  end

  def handle_cast(:update, offset) do
    new_offset =
      Nadia.get_updates(offset: offset)
      |> process_messages

    {:noreply, new_offset + 1, 100}
  end

  def handle_info(:timeout, offset) do
    update()
    {:noreply, offset}
  end

  defp process_messages({:ok, []}), do: -1

  defp process_messages({:ok, results}) do
    results
    |> Enum.map(fn %{update_id: id} = message ->
      message
      |> send_to_mq_channel

      id
    end)
    |> List.last()
  end

  defp process_messages({:error, %Nadia.Model.Error{reason: reason}}) do
    Logger.log(:error, reason)

    -1
  end

  defp process_messages({:error, error}) do
    Logger.log(:error, error)

    -1
  end

  defp send_to_mq_channel(nil), do: IO.puts("nil")

  defp send_to_mq_channel(message) do
    Logger.log(:info, message.channel_post.text)
    # TODO: Send to RabbitMQ
  end
end
