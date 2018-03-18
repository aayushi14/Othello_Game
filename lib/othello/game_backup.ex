defmodule Othello.GameBackup do
  use Agent

  def start_link do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def save(name, game) do
    Agent.update __MODULE__, fn state ->
      Map.put(state, name, game)
    end
  end

  def load(name) do
    Agent.get __MODULE__, fn state ->
      Map.get(state, name)
    end
  end

  def join(name, user) do
    game = load(name)
    if game do
      game
    else
      game = %{ name: name, host: user, state: Othello.Game.new() }
      save(name, game)
    end
  end

end
