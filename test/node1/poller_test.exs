defmodule Node1.PollerTest do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  alias AMQP.Connection
  alias AMQP.Channel
  alias AMQP.Basic
  alias Node1.Poller

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

  test "updates messages" do
    assert :ok == Poller.update
  end

  test "upgrade messages offset", meta do
    use_cassette "get_updates" do
      {:noreply, new_state, _timeout} = Poller.handle_cast(:update, %Poller{chan: meta[:chan], offset: 0})
      assert new_state.offset == 667
    end
  end

  test "basic publish to default exchange", meta do
    assert :ok = Basic.publish(meta[:chan], "", "", "ping")
  end
end
