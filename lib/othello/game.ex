defmodule Othello.Game do
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
      game = %{ name: name, host: user, state: new() }
      save(name, game)
    end

  end

  @board_squares 0..63

  def initSq do
    initSquares = Enum.map(@board_squares, fn(x) -> nil end)
    initSquares = initSquares
                  |> List.insert_at(27, 'X')
                  |> List.insert_at(28, 'O')
                  |> List.insert_at(35, 'O')
                  |> List.insert_at(36, 'X')
    initSquares
  end

  def new do
    %{
      squares: [],
      xNumbers: 2,
      oNumbers: 2,
      xWasNext: true,
      xIsNext: true,
      player1: "",
      player2: "",
    }
  end

  def client_view(game) do
    initSquares = initSq()
    %{
      squares: initSquares,
      xNumbers: 2,
      oNumbers: 2,
      xWasNext: true,
      xIsNext: true,
      winner: nil,
      availableMoves: [20, 29, 34, 43],
      availableMovesOpposite: [19, 26, 37, 44],
      status: nil,
      player1: "",
      player2: "",
    }
  end



  def doReset(game) do
    squares = game.squares
    xNumbers = game.xNumbers
    oNumbers = game.oNumbers
    xWasNext = game.xWasNext
    xIsNext = game.xIsNext
    winner = game.winner
    availableMoves = game.availableMoves
    availableMovesOpposite = game.availableMovesOpposite
    status = game.status

    initSquares = initSq()
    %{game | squares: initSquares, xNumbers: 2, oNumbers: 2, xWasNext: true, xIsNext: true, winner: nil, availableMoves: [20, 29, 34, 43], availableMovesOpposite: [19, 26, 37, 44], status: nil}
  end

  def calculateWinner(xNumbers, oNumbers) do
    c_winner = cond do
                xNumbers + oNumbers < 64 -> nil
                xNumbers === oNumbers -> 'XO'
                xNumbers > oNumbers -> 'X'
                true -> 'O'
              end
    c_winner
  end

  def doLocal(game) do
    squares = game.squares
    xNumbers = game.xNumbers
    oNumbers = game.oNumbers
    xWasNext = game.xWasNext
    xIsNext = game.xIsNext
    winner = game.winner
    availableMoves = game.availableMoves
    availableMovesOpposite = game.availableMovesOpposite
    status = game.status
    initSquares = initSq()
    IO.puts "in local"
    IO.inspect initSquares
    #{:squares, squares} = List.keyfind(current, :squares, 0)
    #{:xNumbers, xN} = List.keyfind(current, :xNumbers, 1)
    #{:oNumbers, oN} = List.keyfind(current, :oNumbers, 2)
    #{:xWasNext, xWasNext} = List.keyfind(current, :xWasNext, 3)
    winner = calculateWinner(xNumbers, oNumbers);
    #availableMoves = checkAvailableMoves(xWasNext, squares)
    #availableMovesOpposite = checkAvailableMoves(!xWasNext, squares)

    if (length(availableMoves) == 0 && length(availableMovesOpposite) == 0) do
      winner = cond do
                xNumbers === oNumbers -> 'XO'
                xNumbers > oNumbers -> 'X'
                true -> 'O'
              end
    end

    status = if(winner) do
              cond do
                winner == 'XO' -> 'It\'s a draw'
                winner == 'X' -> 'The winner is White!'
                winner == 'O' -> 'The winner is Black!'
                xIsNext -> 'Black\'s turn with ' + length(availableMoves) + ' available moves.'
                true -> 'White\'s turn with ' + length(availableMoves) + ' available moves.'
              end
            end

    %{game | squares: squares, xNumbers: xNumbers, oNumbers: oNumbers, xWasNext: true, xIsNext: xIsNext, winner: winner, availableMoves: availableMoves, availableMovesOpposite: availableMovesOpposite, status: status}
  end

#  local() {
#    this.history = this.state.history.slice();
#    this.current = this.history[this.state.stepNumber];
#
#    this.winner = this.calculateWinner(this.current.xNumbers, this.current.oNumbers);
#
#    this.availableMoves = this.checkAvailableMoves(this.current.xWasNext, this.current.squares);
#    this.availableMovesOpposite = this.checkAvailableMoves(!this.current.xWasNext, this.current.squares);
#
#    if ((this.availableMoves.length === 0) && (this.availableMovesOpposite.length === 0)) {
#      this.winner = this.current.xNumbers === this.current.oNumbers ? 'XO' : this.current.xNumbers > this.current.oNumbers ? 'X' : 'O';
#    }
#
#    this.status =
#      this.winner ?
#        (this.winner === 'XO') ? 'It\'s a draw' : 'The winner is ' + (winner === 'W' ? 'White!' : 'Black!') :
#        [this.state.xIsNext ? 'Black\'s turn' : 'White\'s turn', ' with ', this.availableMoves.length, ' available moves.'].join('');
#  }


end
