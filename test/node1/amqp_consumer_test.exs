defmodule Node1.AmqpConsumerTest do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  alias AMQP.Connection
  alias AMQP.Channel
  alias AMQP.Basic
  alias AMQP.Queue


  setup_all do
    unless Application.get_env(:nadia, :token) do
      Application.put_env(:nadia, :token, {:system, "ENV_TOKEN", "TEST_TOKEN"})
    end

    :ok
  end

  setup do
    ExVCR.Config.filter_sensitive_data("bot[^/]+/", "bot<TOKEN>/")
    ExVCR.Config.filter_sensitive_data("id\":\\d+", "id\":666")
    ExVCR.Config.filter_sensitive_data("id=\\d+", "id=666")
    ExVCR.Config.filter_sensitive_data("_id=@w+", "_id=@group")

    {:ok, conn} = Connection.open
    {:ok, chan} = Channel.open(conn)
    on_exit fn -> :ok = Connection.close(conn) end
    {:ok, conn: conn, chan: chan}
  end

  test "send_message" do
    use_cassette "send_message" do
      {:ok, message} = Nadia.send_message(666, "aloha")
      assert message.text == "aloha"
    end
  end

  describe "basic consume" do
    setup meta do
      {:ok, %{queue: queue}} = Queue.declare(meta[:chan])
      on_exit fn -> Queue.delete(meta[:chan], queue) end

      {:ok, Map.put(meta, :queue, queue)}
    end

    test "consumer receives :basic_deliver message", meta do
      {:ok, consumer_tag} = Basic.consume(meta[:chan], meta[:queue])

      payload = "foo"
      correlation_id = "correlation_id"
      exchange = ""
      routing_key = meta[:queue]

      Basic.publish(meta[:chan], exchange, routing_key, payload, correlation_id: correlation_id)

      assert_receive {:basic_deliver,
                      ^payload,
                      %{consumer_tag: ^consumer_tag,
                        correlation_id: ^correlation_id,
                        routing_key: ^routing_key}}
    end
  end
end
