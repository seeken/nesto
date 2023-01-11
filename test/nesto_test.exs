defmodule NestoTest do
  use ExUnit.Case
  doctest Nesto

  test "greets the world" do
    assert Nesto.hello() == :world
  end
end
