defmodule Othello.Game do

  @board_squares 0..63

  def start_link do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def put(gname, game) do
    Agent.update(__MODULE__, &Map.put(&1, gname, game))
    game
  end

  def get(gname) do
    Agent.get(__MODULE__, &Map.get(&1, gname))
  end

  def join(gname, user) do
    game = get(gname)

    if game do
      game
    else
      game = %{ name: gname, host: user }
      put(gname, game)
    end
  end

  def new do
    %{
      squares: [],
      xNumbers: 2,
      oNumbers: 2,
      xWasNext: true,
      stepNumber: 0,
      xIsNext: true,
    }
  end

  def client_view(game) do

    initSquares = Enum.map(@board_squares, fn(x) -> nil end)
    initSquares = initSquares
      |> List.insert_at(27, 'X')
      |> List.insert_at(28, 'O')
      |> List.insert_at(35, 'O')
      |> List.insert_at(36, 'X')
    IO.inspect initSquares

   %{
      squares: initSquares,
      xNumbers: 2,
      oNumbers: 2,
      xWasNext: true,
      stepNumber: 0,
      xIsNext: true
    }
  end

end
