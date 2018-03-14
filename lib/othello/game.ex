defmodule Othello.Game do
  use Agent

  @board_squares 0..63

  
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
      game = %{ name: name, host: user, state: new() }
      save(name, game)
    end

  end

  def new do
    initSquares = Enum.map(@board_squares, fn(_x) -> nil end)
    initSquares = initSquares
      |> List.insert_at(27, "X")
      |> List.insert_at(28, "O")
      |> List.insert_at(35, "O")
      |> List.insert_at(36, "X")
    IO.inspect initSquares
    
    %{
      squares: initSquares,
      xNumbers: 2,
      oNumbers: 2,
      xWasNext: true,
      xIsNext: true,
      player1: "",
      player2: "",
    }
  end

  def client_view(game) do
    IO.inspect game
    initSquares = Enum.map(@board_squares, fn(_x) -> nil end)
    initSquares = initSquares
      |> List.insert_at(27, "X")
      |> List.insert_at(28, "O")
      |> List.insert_at(35, "O")
      |> List.insert_at(36, "X")
    IO.inspect initSquares

   %{
      squares: initSquares,
      xNumbers: 2,
      oNumbers: 2,
      xWasNext: true,
      xIsNext: true
    }

  end

end
