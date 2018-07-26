defmodule Node1Test do
  use ExUnit.Case
  doctest Node1

  test "greets the world" do
    assert Node1.hello() == :world
  end
end
