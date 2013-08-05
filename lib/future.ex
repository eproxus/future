defmodule Future do

  defexception Error, message: nil

  defmacro new(fun) do
    wrap_fun(fun, arity_of(fun))
  end

  defp wrap_fun(fun, arity) do
    args = Enum.map(1..arity, fn x -> { :"x#{x}", [], nil } end)

    quote do
      fn(unquote_splicing(args)) ->
        spawn_link fn ->
          value = try do
            { :ok, unquote(fun).(unquote_splicing(args)) }
        rescue
          e -> { :error, e }
        end

        receive do
          pid ->
            pid <- { self, value }
          end
        end
      end
    end
  end

  defp arity_of({ :fn, _, [[do: { :->, _, [{ args, _, _ }] }]] }) do
    Enum.count(args)
  end

  defp arity_of({ fun_name, _, [{ :/, _, [_, arity] }] }) when fun_name == :function or fun_name == :& do
    arity
  end

  defp arity_of(_) do
    raise Error, message: "Future.new/1 only takes functions as an argument."
  end

  def value(pid, timeout // :infinity, default // { :error, :timeout }) do
    unless Process.alive? pid do
      raise Error, message: "exhausted"
    end
    pid <- self
    receive do
      { ^pid, { :ok, value } } -> value
      { ^pid, { :error, e } }  -> raise e
    after
      timeout -> default
    end
  end
end
