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

  #   # For lobby to get all game names
  # def lobby do
  #   Agent.get __MODULE__, fn state ->
  #     Map.keys(state)
  #   end
  # end

  # # Return the map of all game instances
  # def instances do
  #   Agent.get __MODULE__, fn state ->
  #     state
  #   end
  # end

end
