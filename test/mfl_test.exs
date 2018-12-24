defmodule MFLTest do
  use ExUnit.Case
  doctest MFL

  test "greets the world" do
    assert MFL.hello() == :world
  end
end
