defmodule Othello.Game do

  # Join a new user
  # If it is first user, set it with black piece
  # If it is second user, set it with white piece
  # else add the user in the observer list
  def join(game, user) do
    cond do
      # if the user has already joined, return that game
      game.black_player == user or game.white_player == user or Enum.member?(game.spectators, user) ->
        game
      game.black_player == "" and game.white_player == "" ->
        if :rand.uniform(2) == 1 do
          Map.put(game, :white_player, user)
        else
          game
          |> Map.put(:black_player, user)
          |> Map.put(:current_player, user)
        end
      game.black_player == "" or game.white_player == "" ->
        if game.white_player == "" do
          Map.put(game, :white_player, user)
        else
          game
          |> Map.put(:black_player, user)
          |> Map.put(:current_player, user)
        end
      true ->
        Map.put(game, :spectators, List.insert_at(game.spectators, -1, user))
    end
  end

  @board_squares 0..63

  def initSq do
    initSquares = Enum.map(@board_squares, fn(x) -> nil end)
    initSquares = initSquares
                  |> List.replace_at(27, "X")
                  |> List.replace_at(28, "O")
                  |> List.replace_at(35, "O")
                  |> List.replace_at(36, "X")
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
      availableMoves: [20, 29, 34, 43],
      availableMovesOpposite: [19, 26, 37, 44],
      black_player: "",
      white_player: "",
      spectators: [],
      current_player: "",
    }
  end

  # Initialize the board
  def client_view(game) do
    %{
      squares: game.squares,
      xNumbers: game.xNumbers,
      oNumbers: game.oNumbers,
      xWasNext: game.xWasNext,
      xIsNext: game.xIsNext,
      availableMoves: game.availableMoves,
      availableMovesOpposite: game.availableMovesOpposite,
      black_player: game.black_player,
      white_player: game.white_player,
      spectators: game.spectators,
      current_player: game.current_player,
    }
  end


  def toReset(game) do
    squares = game.squares
    xNumbers = game.xNumbers
    oNumbers = game.oNumbers
    xWasNext = game.xWasNext
    xIsNext = game.xIsNext
    availableMoves = game.availableMoves
    availableMovesOpposite = game.availableMovesOpposite

    initSquares = initSq()
    %{game | squares: initSquares, xNumbers: 2, oNumbers: 2, xWasNext: true, xIsNext: true, availableMoves: [20, 29, 34, 43], availableMovesOpposite: [19, 26, 37, 44]}
  end

  def calculateWinner(xNumbers, oNumbers) do
    IO.puts "inside calculateWinner"
    c_winner = cond do
                xNumbers + oNumbers < 64 -> nil
                xNumbers === oNumbers -> "XO"
                xNumbers > oNumbers -> "X"
                true -> "O"
              end
    IO.puts "c_winner"
    IO.inspect c_winner
    c_winner
  end

  def for_loop(y, offset, lastXpos, lastYpos, flippedSquares, xIsNext, atleastOneMarkIsFlipped, squares, position, modifiedBoard, startX, startY) when is_integer(y) do
    IO.puts "INSIDE for_loop: y-------- "
    IO.inspect y
    modifiedBoard = infor_loop(y, offset, lastXpos, lastYpos, flippedSquares, xIsNext, atleastOneMarkIsFlipped, squares, position, modifiedBoard, startX, startY)
    IO.puts "modifiedBoard for_loop: "
    IO.inspect modifiedBoard
    modifiedBoard
  end

  defp infor_loop(y, offset, lastXpos, lastYpos, flippedSquares, xIsNext, atleastOneMarkIsFlipped, squares, position, modifiedBoard, startX, startY) when y >= 64, do: modifiedBoard

  defp infor_loop(y, offset, lastXpos, lastYpos, flippedSquares, xIsNext, atleastOneMarkIsFlipped, squares, position, modifiedBoard, startX, startY) when y < 64 do
    IO.puts "INSIDE infor_loop: "
    # Calculate the row and col of the current square
    {xPos, yPos} = {rem(y,8), div((y - rem(y,8)),8)}
    IO.puts "xPos, yPos : "
    IO.inspect {xPos, yPos}
    IO.puts "lastXpos, lastYPos"
    IO.inspect {lastXpos, lastYpos}

    # Fix when board is breaking into a new row or col
    if (abs(lastXpos - xPos) > 1 || abs(lastYpos - yPos) > 1) do
      IO.puts "FIX board modifiedBoard: "
      IO.inspect modifiedBoard
      modifiedBoard
    else
      IO.puts "else of FIX board flippedSquares: "
      IO.inspect flippedSquares
      IO.inspect xIsNext
       IO.puts "infor_loop just before COND"
        IO.inspect Enum.at(flippedSquares, y)
      cond do

        # Next square was occupied with the opposite color
        Enum.at(flippedSquares,y) === (if !xIsNext, do: "X", else: "O") ->
          sq = Enum.at(flippedSquares, y)
          sq = if xIsNext, do: "X", else: "O"
          IO.puts "first cond sq: "
          IO.inspect sq
          flippedSquares = List.replace_at(flippedSquares, y, sq)
          atleastOneMarkIsFlipped = true
          {lastXpos, lastYpos} = {xPos, yPos}
          IO.puts "inside opposite color flippedSquares: "
          IO.inspect flippedSquares
          modifiedBoard = flippedSquares
          IO.puts "first cond calling for_loop, y and offset:"
          IO.inspect y
          IO.inspect offset
          modifiedBoard = for_loop(y + offset, offset, lastXpos, lastYpos, flippedSquares, xIsNext, atleastOneMarkIsFlipped, squares, position, modifiedBoard, startX, startY)
        # Next square was occupied with the same color
        (Enum.at(flippedSquares,y) === (if xIsNext, do: "X", else: "O")) && atleastOneMarkIsFlipped ->
          sq = if xIsNext, do: "X", else: "O"
          IO.puts "second cond sq: "
          IO.inspect sq
          flippedSquares = List.replace_at(flippedSquares, position, sq)
          IO.puts "inside same color flippedSquares: "
          IO.inspect flippedSquares
          modifiedBoard = flippedSquares
          modifiedBoard = foreach_loop(offset, squares, position, xIsNext, modifiedBoard, startX, startY)
          modifiedBoard
        true ->
          IO.puts "true offset: "
          IO.inspect offset
          modifiedBoard = foreach_loop(offset, squares, position, xIsNext, modifiedBoard, startX, startY)
          modifiedBoard
      end
    end
    modifiedBoard
  end

  def setOffset(offset) do
    offset = case offset do
      0 -> offset = 1
      1 -> offset = 7
      7 -> offset = 8
      8 -> offset = 9
      9 -> offset = -1
      -1 -> offset = -7
      -7 -> offset = -8
      -8 -> offset = -9
      _ -> offset = :ok
    end
    offset
  end

  def foreach_loop(offset, squares, position, xIsNext, modifiedBoard, startX, startY) do
    IO.puts "INSIDE foreach_loop:"
    IO.puts "INSIDE foreach_loop ------------------ position:"
    IO.inspect position
    # for offset <- [1, 7, 8, 9, -1, -7, -8, -9] do
      flippedSquares = if modifiedBoard != nil, do: modifiedBoard, else: squares
      IO.puts "flippedSquares:"
      IO.inspect flippedSquares

      atleastOneMarkIsFlipped = false
      {lastXpos, lastYpos} = {startX, startY}
      offset = setOffset(offset)
      IO.puts "offset: "
      IO.inspect offset
      if offset != :ok do
        y = position + offset
        IO.puts "inside offset check:            modifiedBoard:"
        IO.inspect modifiedBoard
        modifiedBoard = for_loop(y, offset, lastXpos, lastYpos, flippedSquares, xIsNext, atleastOneMarkIsFlipped, squares, position, modifiedBoard, startX, startY)
        modifiedBoard
      else
        modifiedBoard
      end

      IO.puts "ending foreach_loop modifiedBoard "
      IO.inspect modifiedBoard
    # end
    modifiedBoard
  end


  def flipSquares(squares, position, xIsNext) do
    IO.puts "INSIDE flipSquares"
    modifiedBoard = nil

    # Calculate row and col of the starting position
    {startX, startY} = {rem(position,8), div((position - rem(position,8)),8)}
    IO.puts "startX  startY"
    IO.inspect {startX, startY}

    IO.puts "squares in flipSquares: "
    IO.inspect squares

    IO.puts "Enum.at(squares, position):"
    IO.inspect Enum.at(squares, position)

    if (Enum.at(squares, position) !== nil) do
      IO.puts "Squares in enum:"
      IO.inspect squares
      IO.puts "sp:"
      IO.inspect Enum.at(squares, position)
      modifiedBoard = nil
    else
      # Iterate all directions, these numbers are the offsets in the array to reach next square
      modifiedBoard = foreach_loop(0, squares, position, xIsNext, modifiedBoard, startX, startY)
    end

    IO.puts "INSIDE flipSquares modifiedBoard: "
    IO.inspect modifiedBoard
    modifiedBoard
  end

  def getavailableMoves(squares, flipSquares) do
    IO.puts "inside getavailableMoves>>>"
    IO.inspect(squares)
    squares
    |> Enum.reduce([], fn(index, acc) -> [flipSquares.(index)] end)
    |> Enum.reverse()
#    modifiedBoard = flipSquares(squares, index, color)
#    if modifiedBoard !== nil do:
  end

  def getmodifiedIndex_loop(squares, index, color, listOfModifiedIndex) when is_integer(index) do
    IO.puts "inside getmodifiedIndex_loop index"
    IO.inspect index
    listOfModifiedIndex = ingetmodifiedIndex_loop(squares, index, color, listOfModifiedIndex)
    IO.puts "inside getmodifiedIndex_loop listOfModifiedIndex"
    IO.inspect listOfModifiedIndex
    listOfModifiedIndex
  end
  defp ingetmodifiedIndex_loop(squares, index, color, listOfModifiedIndex) when index >= 64, do: listOfModifiedIndex

  defp ingetmodifiedIndex_loop(squares, index, color, listOfModifiedIndex) when index < 64 do
    IO.puts "inside ingetmodifiedIndex_loop"
    IO.puts "inside ingetmodifiedIndex_loop BEFORE flipSquares index"
    IO.inspect index
    modifiedBoard = flipSquares(squares, index, color)
    IO.puts "inside ingetmodifiedIndex_loop AFTER flipSquares index"
    IO.inspect index
    IO.puts "inside ingetmodifiedIndex_loop squares"
    IO.inspect squares
    IO.puts "inside ingetmodifiedIndex_loop modifiedBoard"
    IO.inspect modifiedBoard
    if Enum.at(squares, index) != nil do
      listOfModifiedIndex = listOfModifiedIndex ++ [index]
    end
    IO.puts "inside ingetmodifiedIndex_loop listOfModifiedIndex"
    IO.inspect listOfModifiedIndex
    listOfModifiedIndex = ingetmodifiedIndex_loop(squares, index + 1, color, listOfModifiedIndex)
    listOfModifiedIndex
  end

  def checkAvailableMoves(color, squares) do
    IO.puts "============INSIDE checkAvailableMoves============"
    IO.inspect(squares)
    modifiedSquares = getmodifiedIndex_loop(squares, 0, color, [])
    IO.puts "modifiedSquares: "
    IO.inspect modifiedSquares
    modifiedSquares
  end

  def tohandleClick(game, id) do
    IO.puts "INSIDE---------------------tohandleClick"
    IO.inspect(game.squares)
    squares = game.squares
    xNumbers = game.xNumbers
    oNumbers = game.oNumbers
    xWasNext = game.xWasNext
    xIsNext = game.xIsNext
    black_player = game.black_player
    white_player = game.white_player
    current_player= game.current_player

    if calculateWinner(xNumbers, oNumbers) || Enum.at(squares,id) do
      IO.puts "tohandleClick calculateWinner"
      changedSquares = squares
    else
      IO.puts "else tohandleClick"
      changedSquares = flipSquares(squares, id, xIsNext)
      if changedSquares === nil do
        IO.puts "else, if, tohandleClick"
        changedSquares = squares
      else
        IO.puts "else, if, else, tohandleClick"
        xNumbers = Enum.reduce(changedSquares, 0, fn(current, acc) -> (if current === "X", do: acc + 1, else: acc) end)
        oNumbers = Enum.reduce(changedSquares, 0, fn(current, acc) -> (if current === "O", do: acc + 1, else: acc) end)
        shouldTurnColor = if length(checkAvailableMoves(!xIsNext, changedSquares)) > 0, do: !xIsNext, else: xIsNext
        IO.puts "shouldTurnColor"
        IO.inspect shouldTurnColor
      end
    end

    IO.puts "black_player"
    IO.inspect black_player
    IO.puts "white_player"
    IO.inspect "white_player"
    IO.puts "current_player"
    IO.inspect "current_player"
    IO.puts "*******************************"

    if current_player == black_player do
      current_player = white_player
    else
      current_player = black_player
    end
    IO.puts "current_player"
    IO.inspect "current_player"

    %{game | squares: changedSquares, xNumbers: xNumbers, oNumbers: oNumbers, xWasNext: shouldTurnColor, xIsNext: shouldTurnColor, current_player: current_player}
  end

  def tocheckAvailableMoves(game, color, squares) do
    availableMoves = game.availableMoves
    IO.puts "INSIDE tocheckAvailableMoves squares"
    IO.inspect(squares)
    IO.puts "INSIDE tocheckAvailableMoves availableMoves"
    IO.inspect(availableMoves)
    availableMoves = checkAvailableMoves(color, squares)
    IO.puts "after checkAvailableMoves availableMoves: "
    IO.inspect availableMoves
    %{game | availableMoves: availableMoves}
  end

  def tocheckAvailableMovesOpposite(game, color, squares) do
    availableMovesOpposite = game.availableMovesOpposite
    IO.puts "INSIDE tocheckAvailableMovesOpposite squares"
    IO.inspect(squares)
    IO.puts "INSIDE tocheckAvailableMoves availableMovesOpposite"
    IO.inspect(availableMovesOpposite)
    availableMovesOpposite = checkAvailableMoves(color, squares)
    IO.puts "after checkAvailableMovesOpposite availableMovesOpposite: "
    IO.inspect availableMovesOpposite
    %{game | availableMovesOpposite: availableMovesOpposite}
  end


  # def inRender(game) do
  #   IO.puts "inRender game-----------"
  #   IO.inspect(game)
  #   squares = game.squares
  #   xNumbers = game.xNumbers
  #   oNumbers = game.oNumbers
  #   xWasNext = game.xWasNext
  #   xIsNext = game.xIsNext
  #   availableMoves = game.availableMoves
  #   availableMovesOpposite = game.availableMovesOpposite
  #
  #   initSquares = initSq()
  #   IO.puts "----inRender----"
  #
  #   winner = calculateWinner(xNumbers, oNumbers);
  #   availableMoves = checkAvailableMoves(xWasNext, squares)
  #   availableMovesOpposite = checkAvailableMoves(!xWasNext, squares)
  #
  #   if (length(availableMoves) == 0 && length(availableMovesOpposite) == 0) do
  #     IO.puts "before winner"
  #     winner = cond do
  #               xNumbers === oNumbers -> "XO"
  #               xNumbers > oNumbers -> "X"
  #               true -> "O"
  #             end
  #     IO.puts "after winner"
  #     IO.inspect winner
  #   end
  #
  #   status = if(winner) do
  #             cond do
  #               winner == "XO" -> 'It\'s a draw'
  #               winner == "X" -> 'The winner is White!'
  #               winner == "O" -> 'The winner is Black!'
  #               xIsNext -> 'Black\'s turn with ' + length(availableMoves) + ' available moves.'
  #               true -> 'White\'s turn with ' + length(availableMoves) + ' available moves.'
  #             end
  #           end
  #
  #   %{game | availableMoves: availableMoves, availableMovesOpposite: availableMovesOpposite}
  # end

end
