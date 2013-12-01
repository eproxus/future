# Future

[![Build Status](https://travis-ci.org/eproxus/future.png?branch=master)](https://travis-ci.org/eproxus/future)

Giving Elixir a future.

## Example

Consider the following implementations of a parallel map:

Without futures:



```Elixir
def pmap(collection, fun) do
  me = self
  collection
  |> Enum.map(fn x ->
      spawn_link(fn ->
        me <- {self, fun.(x)}
      end)
    end)
  |> Enum.map(fn pid ->
      receive do
        {^pid, result} -> result
      end
    end)
end
```

With futures:



```Elixir
def pmap(collection, fun) do
  collection
  |> Enum.map(Future.new(fun))
  |> Enum.map(Future.value(&1))
end
```

## TODO

* ~~Return error when exhausted~~
* Add option to not link process
* ~~Handle multiple argument functions~~
* Allow a future to be stopped

