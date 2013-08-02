defmodule Future do

  defexception Error, message: nil

  defmacro new(fun) do
    wrap_fun(fun)
  end

  defp wrap_fun({ :fn, _, [[do: { :->, _, [{ args, _, _ }] }]] } = fun) do
    args = Enum.map(1..Enum.count(args), fn x -> { :"x#{x}", [], nil } end)

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

  defp wrap_fun(_) do
    quote do
      raise Error, message: "Future.new/1 only takes an anonymous function as an argument."
    end
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
