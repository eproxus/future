Code.require_file "test_helper.exs", __DIR__

defmodule FutureTest do
  use ExUnit.Case
  import CompileAssertion

  require Future

  test "two futures" do
    f = Future.new(fn x -> x end)
    f1 = f.(1)
    f2 = f.(2)
    assert 1 == Future.value(f1)
    assert 2 == Future.value(f2)
  end

  test "raises" do
    assert_raise RuntimeError, "test", fn ->
      Future.value Future.new(fn _ -> raise "test" end).(1)
    end
  end

  test "exhaustion" do
    f = Future.new(fn x -> x end).(1)
    assert 1 == Future.value f
    assert_raise Future.Error, "exhausted", fn ->
      Future.value f
    end
  end

  test "a future with multiple arguments" do
    f = Future.new(fn x, y, z -> x + y + z end)
    f1 = f.(1, 2, 3)
    assert 6 == Future.value(f1)
  end

  def addition(x,y) do
    x + y
  end

  test "a future with a &function argument" do
    f = Future.new(&addition/2)
    f1 = f.(1,2)
    assert 3 == Future.value(f1)
  end

  test "a future with no arguments" do
    f = Future.new(fn -> 3 * 3 end)
    f1 = f.()
    assert 9 == Future.value(f1)
  end

  test "calling a future with a non function value raises an error" do
    assert_compile_fail Future.Error, "import Future; Future.new(10)"
  end

end
