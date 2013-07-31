defmodule Future do

  defexception Error, message: nil

  def new(fun) do
    fn(x) ->
      spawn_link fn ->
        value = try do
          { :ok, fun.(x) }
        rescue
        e -> { :error, e }
      end

      receive do
        pid ->
          pid <- {self, value}
        end
      end
    end
  end

  def value(pid, timeout // :infinity, default // {:error, :timeout}) do
    unless Process.alive? pid do
      raise Error, message: "exhausted"
    end
    pid <- self
    receive do
      {^pid, {:ok, value}} -> value
      {^pid, {:error, e}}  -> raise e
    after
      timeout -> default
    end
  end
end
