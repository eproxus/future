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

  test "raises" do
    assert_raise RuntimeError, "test", fn ->
      Future.value Future.new(fn x -> raise "test" end).(1)
    end
  end

  test "exhaustion" do
    f = Future.new(fn x -> x end).(1)
    assert 1 == Future.value f
    assert_raise Future.Error, "exhausted", fn ->
      Future.value f
    end
  end

end
