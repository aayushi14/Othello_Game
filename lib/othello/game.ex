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
    initSquares = initSq()
    %{
      squares: initSquares,
      xNumbers: 2,
      oNumbers: 2,
      xWasNext: true,
      xIsNext: true,
      winner: '',
      availableMoves: [20, 29, 34, 43],
      availableMovesOpposite: [19, 26, 37, 44],
      status: '',
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
      winner: '',
      availableMoves: [20, 29, 34, 43],
      availableMovesOpposite: [19, 26, 37, 44],
      status: '',
      player1: "",
      player2: "",
    }
  end

  def toReset(game) do
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
    IO.puts "inside calculateWinner"
    c_winner = cond do
                xNumbers + oNumbers < 64 -> nil
                xNumbers === oNumbers -> 'XO'
                xNumbers > oNumbers -> 'X'
                true -> 'O'
              end
    IO.puts "c_winner"
    IO.inspect(c_winner)
    c_winner
  end

  def inside_forLoop(y, offset, lastXpos, lastYpos, xPos, yPos, flippedSquares, xIsNext, atleastOneMarkIsFlipped, squares, position, modifiedBoard, startX, startY) do
    # Fix when board is breaking into a new row or col
    if (abs(lastXpos - xPos) > 1 || abs(lastYpos - yPos) > 1), do: foreach_loop(squares, position, xIsNext, modifiedBoard, startX, startY)

    IO.puts "xIsNext: "
    IO.inspect xIsNext
    IO.puts "flippedSquares[y]: "
    IO.inspect Enum.at(flippedSquares,y)
    IO.puts "atleastOneMarkIsFlipped: "
    IO.inspect atleastOneMarkIsFlipped

    cond do
      # Next square was occupied with the opposite color
      Enum.at(flippedSquares,y) === (if !xIsNext, do: 'X', else: 'O') ->
        sq = Enum.at(flippedSquares,y)
        sq = if xIsNext, do: 'X', else: 'O'
        List.replace_at(flippedSquares, y, sq)
        atleastOneMarkIsFlipped = true
        {lastXpos, lastYPos} = {xPos, yPos}
  ##      for_loop(y+offset, offset, lastXpos, lastYpos, xPos, yPos, flippedSquares, xIsNext, atleastOneMarkIsFlipped, position, modifiedBoard, startX, startY)
      # Next square was occupied with the same color
      (Enum.at(flippedSquares,y) === (if xIsNext, do: 'X', else: 'O')) && atleastOneMarkIsFlipped ->
        sq = Enum.at(flippedSquares,position)
        sq = if xIsNext, do: 'X', else: 'O'
        List.replace_at(flippedSquares, position, sq)
        modifiedBoard = Enum.slice(flippedSquares, 0, 64)
      true ->
        modifiedBoard
    end
    foreach_loop(squares, position, xIsNext, modifiedBoard, startX, startY)

    # # Next square was occupied with the opposite color
    # if Enum.at(flippedSquares,y) === (if !xIsNext, do: 'X', else: 'O') do
    #   sq = Enum.at(flippedSquares,y)
    #   sq = if xIsNext, do: 'X', else: 'O'
    #   List.replace_at(flippedSquares, y, sq)
    #   atleastOneMarkIsFlipped = true
    #   lastXpos = xPos
    #   lastYPos = yPos
    #   for_loop(y+offset, offset, lastXpos, lastYpos, xPos, yPos, flippedSquares, xIsNext, atleastOneMarkIsFlipped, position, modifiedBoard, startX, startY)
    # end
    # # Next square was occupied with the same color
    # else if (Enum.at(flippedSquares,y) === (if xIsNext, do: 'X', else: 'O')) && atleastOneMarkIsFlipped do
    #   sq = Enum.at(flippedSquares,position)
    #   sq = if xIsNext, do: 'X', else: 'O'
    #   List.replace_at(flippedSquares, position, sq)
    #   modifiedBoard = Enum.slice(flippedSquares, 0, 64)
    # end

  end

  def print_multiple_times(msg, n) when n <= 1 do
    IO.puts msg
  end

  def print_multiple_times(msg, n) do
    IO.puts msg
    print_multiple_times(msg, n - 1)
  end

  def action do
    IO.puts "hello"
  end

  def exfor_loop(count, action) when is_integer(count) do
    exloop(action, count, 0)
  end

   defp exloop(_action, count, acc) when acc > count, do: :ok
   defp exloop(action, count, acc) when acc <= count do
       action.(acc)
       exloop(action, count, acc+1)
   end

  def for_loop(y, offset, lastXpos, lastYpos, flippedSquares, xIsNext, atleastOneMarkIsFlipped, squares, position, modifiedBoard, startX, startY) when is_integer(y) do
    infor_loop(y, offset, lastXpos, lastYpos, flippedSquares, xIsNext, atleastOneMarkIsFlipped, squares, position, modifiedBoard, startX, startY)
  end
  defp infor_loop(y, offset, lastXpos, lastYpos, flippedSquares, xIsNext, atleastOneMarkIsFlipped, squares, position, modifiedBoard, startX, startY) when y >= 64, do: :ok

  defp infor_loop(y, offset, lastXpos, lastYpos, flippedSquares, xIsNext, atleastOneMarkIsFlipped, squares, position, modifiedBoard, startX, startY) when y < 64 do
    # Calculate the row and col of the current square
    {xPos, yPos} = {rem(y,8), (y - rem(y,8))/8}
    IO.puts "X:"
    IO.inspect xPos
    IO.puts "Y:"
    IO.inspect yPos

    # Fix when board is breaking into a new row or col
    if (abs(lastXpos - xPos) > 1 || abs(lastYpos - yPos) > 1) do
      modifiedBoard
    else
      cond do
        # Next square was occupied with the opposite color
        Enum.at(flippedSquares,y) === (if !xIsNext, do: 'X', else: 'O') ->
          sq = Enum.at(flippedSquares,y)
          sq = if xIsNext, do: 'X', else: 'O'
          List.replace_at(flippedSquares, y, sq)
          atleastOneMarkIsFlipped = true
          {lastXpos, lastYPos} = {xPos, yPos}
          example = exfor_loop(1, action)
  #        modifiedBoard = infor_loop(y+offset, offset, lastXpos, lastYpos, xPos, yPos, flippedSquares, xIsNext, atleastOneMarkIsFlipped, position, modifiedBoard, startX, startY)
        # Next square was occupied with the same color
        (Enum.at(flippedSquares,y) === (if xIsNext, do: 'X', else: 'O')) && atleastOneMarkIsFlipped ->
          sq = Enum.at(flippedSquares,position)
          sq = if xIsNext, do: 'X', else: 'O'
          List.replace_at(flippedSquares, position, sq)
          modifiedBoard = Enum.slice(flippedSquares, 0, 64)
        true ->
          modifiedBoard
      end
    end
  #  inside_forLoop(y, offset, lastXpos, lastYpos, xPos, yPos, flippedSquares, xIsNext, atleastOneMarkIsFlipped, squares, position, modifiedBoard, startX, startY)
    modifiedBoard
  end

  def for_loop(y, offset, lastXpos, lastYpos, flippedSquares, xIsNext, atleastOneMarkIsFlipped, squares, position, modifiedBoard, startX, startY) when is_integer(y) do
    infor_loop(y, offset, lastXpos, lastYpos, flippedSquares, xIsNext, atleastOneMarkIsFlipped, squares, position, modifiedBoard, startX, startY)
  end

  def foreach_loop(squares, position, xIsNext, modifiedBoard, startX, startY) do
    for offset <- [1, 7, 8, 9, -1, -7, -8, -9] do
      flippedSquares = if modifiedBoard != nil, do: Enum.slice(modifiedBoard, 0, 64), else: Enum.slice(squares, 0, 64)
      IO.puts "flippedSquares:"
      IO.inspect flippedSquares

      atleastOneMarkIsFlipped = false
      {lastXpos, lastYpos} = {startX, startY}

      y = position + offset
      modifiedBoard = for_loop(position + offset, offset, lastXpos, lastYpos, flippedSquares, xIsNext, atleastOneMarkIsFlipped, squares, position, modifiedBoard, startX, startY)
    end
    modifiedBoard
  end


    # def fetch_something
    #   tries = 0
    #   body = nil
    #   loop do
    #     status, body = make_external_http_call
    #     break if status == 200
    #     tries += 1
    #     if tries >= 5
    #       body = "Service not available"
    #       break
    #     end
    #   end
    #   body
    # end

    # def fetch_something(tries \\ 0)
    # def fetch_something(tries) when tries < 5
    #   case make_external_http_call do
    #     {200, body} -> body
    #     {_status, _body} -> fetch_something(tries + 1)
    #   end
    # end
    # def fetch_something(tries) when tries >= 5 do
    #   "Service not available"
    # end

  def flipSquares(squares, position, xIsNext) do
    modifiedBoard = nil

    # Calculate row and col of the starting position
    {startX, startY} = {rem(position,8), (position - rem(position,8))/8}
    IO.puts "startX:"
    IO.inspect startX
    IO.puts "startY:"
    IO.inspect startY

    if (Enum.at(squares, position) !== nil) do
      IO.puts "Squares:"
      IO.inspect squares
      IO.puts "sp:"
      IO.inspect Enum.at(squares, position)
      modifiedBoard = nil
    else
      # Iterate all directions, these numbers are the offsets in the array to reach next square
      modifiedBoard = foreach_loop(squares, position, xIsNext, modifiedBoard, startX, startY)
    end

    IO.puts "modifiedBoard: "
    IO.inspect modifiedBoard
    modifiedBoard
  end

  def checkAvailableMoves(color, squares) do
    IO.puts "inside checkAvailableMoves"
    IO.inspect(squares)
    modifiedBoard = flipSquares(squares, 26, color)
    IO.puts "inside checkAvailableMoves-----------------modifiedBoard: "
    IO.inspect modifiedBoard
    squares = Enum.map(squares, fn(index) -> (if flipSquares(squares, index, color) !== nil, do: index, else: nil) end)
    asquares = Enum.filter(squares, fn(item) -> item !== nil end)
    IO.puts "squares"
    IO.inspect(squares)
    IO.puts "asquares"
    IO.inspect(asquares)
    asquares
  end

  def tohandleClick(game, id) do
    IO.puts "---------------------"
    IO.inspect(game.state.squares)
    squares = game.state.squares
    xNumbers = game.state.xNumbers
    oNumbers = game.state.oNumbers
    xWasNext = game.state.xWasNext
    xIsNext = game.state.xIsNext

    # if (Enum.at(squares, position) === nil) do
    #    changedSquares = flipSquares(squares, position, xIsNext, modifiedBoard, startX, startY)
    # else
    #    changedSquares = nil
    # end

    if calculateWinner(xNumbers, oNumbers) || Enum.at(squares,id) do
        changedSquares = squares
    else
      changedSquares = flipSquares(squares, id, xIsNext)
      if changedSquares === nil do
        changedSquares = squares
      else
        xNumbers = Enum.reduce(changedSquares, 0, fn(current, acc) -> (if current === 'X', do: acc + 1, else: acc) end)
        oNumbers = Enum.reduce(changedSquares, 0, fn(current, acc) -> (if current === 'O', do: acc + 1, else: acc) end)
        shouldTurnColor = if checkAvailableMoves(!xIsNext, changedSquares).length > 0, do: !xIsNext, else: xIsNext
      end
    end
    %{game | squares: changedSquares, xNumbers: xNumbers, oNumbers: oNumbers, xWasNext: shouldTurnColor, xIsNext: shouldTurnColor}
  end

  def inRender(game) do
    IO.puts "inRender game-----------"
    IO.inspect(game)
    squares = game.state.squares
    xNumbers = game.state.xNumbers
    oNumbers = game.state.oNumbers
    xWasNext = game.state.xWasNext
    xIsNext = game.state.xIsNext
    winner = game.state.winner
    availableMoves = game.state.availableMoves
    availableMovesOpposite = game.state.availableMovesOpposite
    status = game.state.status
    initSquares = initSq()
    IO.puts "in local"
    IO.inspect initSquares
    IO.puts "availableMoves"
    IO.inspect availableMoves
    IO.puts "availableMovesOpposite"
    IO.inspect availableMovesOpposite

    winner = calculateWinner(xNumbers, oNumbers);
    availableMoves = checkAvailableMoves(xWasNext, squares)
    availableMovesOpposite = checkAvailableMoves(!xWasNext, squares)

    if (length(availableMoves) == 0 && length(availableMovesOpposite) == 0) do
      IO.puts "before winner"
      winner = cond do
                xNumbers === oNumbers -> 'XO'
                xNumbers > oNumbers -> 'X'
                true -> 'O'
              end
      IO.puts "after winner"
      IO.inspect winner
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

    %{game | winner: winner, availableMoves: availableMoves, availableMovesOpposite: availableMovesOpposite, status: status}
  end

#  inRender() {
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
