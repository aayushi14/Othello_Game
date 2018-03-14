defmodule Othello.Game do

  @board_squares 0..63

  defp initSq do
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

  def showTile(game, id) do
    queArray = game.queArray
    opentile1 = game.opentile1
    opentile2 = game.opentile2
    ansArray = game.loadedArray
    matchedIndex = game.matchedIndex;
    score = game.score
    totalClicks = game.totalClicks
    disableClick = game.disableClick

    temp = Enum.at(ansArray, id)
    queArray = List.replace_at(queArray, id, temp)

   {opentile1, opentile2, matchedIndex, score, totalClicks, disableClick} = cond do
    opentile1 == 16 && opentile2 == 16 && !Enum.member?(matchedIndex, id) ->
    {id, opentile2, matchedIndex, score, totalClicks + 1, disableClick}
    opentile1 != 16 && opentile2 == 16 && id != opentile1 && !Enum.member?(matchedIndex, id) && Enum.at(queArray, opentile1) == Enum.at(queArray, id) ->
    opentile2 = id
    matchedIndex = matchedIndex ++ [opentile1] ++ [opentile2]
    {16, 16, matchedIndex, score + 10, totalClicks + 1, disableClick}
    opentile1 != 16 && opentile2 == 16 && id != opentile1 && !Enum.member?(matchedIndex, id) && Enum.at(queArray, opentile1) != Enum.at(queArray, id) ->
    opentile2 = id
    disableClick = true
    {opentile1, opentile2, matchedIndex, score - 5, totalClicks + 1, disableClick}
    true -> {opentile1, opentile2, matchedIndex, score, totalClicks, disableClick}
   end

   %{game | queArray: queArray, opentile1: opentile1, opentile2: opentile2, matchedIndex: matchedIndex, score: score, totalClicks: totalClicks, disableClick: disableClick}
  end

  def diffTiles(game, queArray, opentile1, opentile2, boole) do
    queArray = game.queArray
    opentile1 = game.opentile1
    opentile2 = game.opentile2
    disableClick = game.disableClick

    queArray = queArray
                |> List.replace_at(opentile1, "?")
                |> List.replace_at(opentile2, "?")
  %{game | queArray: queArray, opentile1: 16, opentile2: 16, disableClick: boole}
  end

end
