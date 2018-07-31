defmodule Node1.Poller do
  @moduledoc """
  Long-polling process. Consumes Telegram channel messages
  and send them to rabbit queue.
  """

  require Logger

  use GenServer
  use AMQP

  @mq_url Application.get_env(:amqp, :mq_url)
  @exchange "node2_exchange"

  defstruct chan: %{}, offset: 0

  @type t :: %Node1.Poller{}

  # API

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def update do
    GenServer.cast(__MODULE__, :update)
  end

  # Server

  def init(:ok) do
    conn = try_connect()
    {:ok, chan} = Channel.open(conn)
    update()
    {:ok, %__MODULE__{chan: chan, offset: 0}}
  end

  @spec handle_cast(atom(), Node1.Poller.t()) :: {:noreply, Node1.Poller.t()}
  def handle_cast(:update, poller) do
    new_offset =
      Nadia.get_updates(offset: poller.offset)
      |> process_messages(poller.chan)

    {:noreply, %{poller | offset: new_offset + 1}, 100}
  end

  def handle_info(:timeout, offset) do
    update()
    {:noreply, offset}
  end

  defp try_connect do
    case Connection.open(@mq_url) do
      {:ok, conn} ->
        conn

      {:error, reason} ->
        Logger.log(:error, "failed for #{inspect(reason)}")
        :timer.sleep(5000)
        try_connect()
    end
  end

  defp process_messages({:ok, []}, _chan), do: -1

  @spec process_messages({:ok, list()}, Node1.Poller.t()) :: integer()
  defp process_messages({:ok, results}, chan) do
    telegram_channel_id = Application.get_env(:nadia, :telegram_channel_id)

    last_id =
      results
      |> Enum.filter(fn message ->
        Integer.to_string(message_struct(message).chat.id) == telegram_channel_id
      end)
      |> Enum.map(fn %{update_id: id} = message ->
        message
        |> send_to_mq_channel(chan)

        id
      end)
      |> List.last()

    case last_id do
      nil ->
        -1

      _ ->
        last_id
    end
  end

  defp process_messages({:error, %Nadia.Model.Error{reason: reason}}, _chan) do
    Logger.log(:error, reason)
    -1
  end

  defp process_messages({:error, error}, _chan) do
    Logger.log(:error, error)
    -1
  end

  defp send_to_mq_channel(nil, _chan), do: Logger.log(:info, "nil")

  defp send_to_mq_channel(message, chan) do
    text = message_struct(message).text
    Logger.log(:info, text)
    Basic.publish(chan, @exchange, "", text)
  end

  defp message_struct(message) do
    case message.channel_post do
      nil ->
        message.message

      post ->
        post
    end
  end
end
