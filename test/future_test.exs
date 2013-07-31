Code.require_file "test_helper.exs", __DIR__

defmodule FutureTest do
  use ExUnit.Case

  test "two futures" do
    f = Future.new(fn x -> x end)
    f1 = f.(1)
    f2 = f.(2)
    assert 1 == Future.value(f1)
    assert 2 == Future.value(f2)
  end

end
