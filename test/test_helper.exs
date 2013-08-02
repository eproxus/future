ExUnit.start

defmodule CompileAssertion do
  def assert_compile_fail(exception, string) do
    case format_rescue(string) do
      { ^exception, _ } -> :ok
      error ->
        raise ExUnit.ExpectationError,
          expected: inspect(exception),
          actual: inspect(elem(error, 0)),
          reason: "match"
    end
  end

  def assert_compile_fail(exception, message, string) do
    case format_rescue(string) do
      { ^exception, ^message } -> :ok
      error ->
        raise ExUnit.ExpectationError,
          expected: "#{inspect exception}[message: #{inspect message}]",
          actual: "#{inspect elem(error, 0)}[message: #{inspect elem(error, 1)}]",
          reason: "match"
    end
  end

  defp format_rescue(expr) do
    result = try do
      :elixir.eval(to_char_list(expr), [])
      nil
      rescue
      error -> { error.__record__(:name), error.message }
    end

    result || raise(ExUnit.AssertionError, message: "Expected expression to fail")
  end
end