defmodule Othello.Game do
  @moduledoc """
  Game board
  """

  # total squares in the board
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
      black_pieces: 2,
      white_pieces: 2,
      xWasNext: true,
      xIsNext: true,
      availableMoves: [],
      availableMovesOpposite: [],
      black_player: nil,
      white_player: nil,
      spectators: [],
      current_player: nil,
      msgs: [],
      status: "Waiting",    # game status can be Waiting, Playing and Finished
    }
  end

  @doc """
  Initialize the board
  """
  def client_view(game) do
    %{
      squares: game.squares,
      black_pieces: game.black_pieces,
      white_pieces: game.white_pieces,
      xWasNext: game.xWasNext,
      xIsNext: game.xIsNext,
      availableMoves: game.availableMoves,
      availableMovesOpposite: game.availableMovesOpposite,
      black_player: game.black_player,
      white_player: game.white_player,
      spectators: game.spectators,
      current_player: game.current_player,
      msgs: game.msgs,
      status: game.status,
    }
  end

  @doc """
  Join a new user
  If it is first user, randomly set it with black or white piece
  If it is second user, set it with the remaining piece
  else add the user in the spectator list
  """
  def join(game, user_name) do
    IO.puts "INSIDE JOIN"
    IO.inspect user_name
    IO.puts "----------"
    black_player = game.black_player
    white_player = game.white_player
    current_player = game.current_player
    spectators = game.spectators
    msgs = game.msgs
    status = game.status

    cond do
      # if the user has already joined, return that game
      black_player == user_name or white_player == user_name or Enum.member?(spectators, user_name) ->
        game
      black_player == nil and white_player == nil ->
        if :rand.uniform(2) == 1 do
          msgs = List.insert_at(msgs, -1, ["system", "[game]: " <> user_name <> " joined as white player."])
          white_player = user_name
        else
          msgs = List.insert_at(msgs, -1, ["system", "[game]: " <> user_name <> " joined as black player."])
          black_player = user_name
          current_player = user_name
        end
      black_player == nil or white_player == nil ->
        if white_player == nil do
          msgs = List.insert_at(msgs, -1, ["system", "[game]: " <> user_name <> " joined as white player."])
          white_player = user_name
          status = "Playing"
        else
          msgs = List.insert_at(msgs, -1, ["system", "[game]: " <> user_name <> " joined as black player."])
          black_player = user_name
          current_player = user_name
          status = "Playing"
        end
      true ->
        msgs = List.insert_at(msgs, -1, ["system", "[game]: " <> user_name <> " joined as spectator."])
        spectators = List.insert_at(game.spectators, -1, user_name)
    end
    %{game | black_player: black_player, white_player: white_player, current_player: current_player, spectators: spectators, msgs: msgs, status: status}
  end

  @doc """
  A user leaves
  If the game has started, and one player leaves, the opposite wins
  else just remove the player or observer
  If no user is in the game, delete the game
  """
  def userLeavesGame(game, user_type, user_name) do
    black_player = game.black_player
    white_player = game.white_player
    current_player = game.current_player
    spectators = game.spectators
    msgs = game.msgs
    status = game.status
    msgs = List.insert_at(msgs, -1, ["system", "[game]: " <> user_name <> " has left the game."])
    case user_type do
      :black_player ->
        black_player = nil
        status = "Waiting"
      :white_player ->
        white_player = nil
        status = "Waiting"
      :spectator ->
        spectators = List.delete(game.spectators, user_name)
    end
    %{game | black_player: black_player, white_player: white_player, current_player: current_player, spectators: spectators, msgs: msgs, status: status}
  end

  @doc """
  If the number of black and white pieces
  add up to less than 64, no winner as of yet
  is equal, its a tie
  is such that black is more, black player is the winner
  else white is the winner
  """
  def calculateWinner(black_pieces, white_pieces) do
    IO.puts "inside calculateWinner"
    winner = cond do
      black_pieces + white_pieces < 64 -> nil
      black_pieces === white_pieces -> "XO"
      black_pieces > white_pieces -> "X"
      true -> "O"
    end
    # IO.puts "winner"
    # IO.inspect winner
    winner
  end

  # initiates the recusion over y (acts like for loop)
  def for_loop(y, offset, lastXpos, lastYpos, flippedSquares, xIsNext, atleastOneMarkIsFlipped, squares, position, modifiedBoard, startX, startY) when is_integer(y) do
    flippedSquares = infor_loop(y, offset, lastXpos, lastYpos, flippedSquares, xIsNext, atleastOneMarkIsFlipped, squares, position, modifiedBoard, startX, startY)
    flippedSquares
  end

  # recursive call until y becomes greater than or equal to 64
  defp infor_loop(y, offset, lastXpos, lastYpos, flippedSquares, xIsNext, atleastOneMarkIsFlipped, squares, position, modifiedBoard, startX, startY) when y >= 64, do: modifiedBoard

  # recursive call until y is less than 64
  defp infor_loop(y, offset, lastXpos, lastYpos, flippedSquares, xIsNext, atleastOneMarkIsFlipped, squares, position, modifiedBoard, startX, startY) when y < 64 do
    # IO.puts "INSIDE infor_loop: "
    # Calculate the row and col of the current square
    {xPos, yPos} = {rem(y,8), div((y - rem(y,8)),8)}

    # Fix when board is breaking into a new row or col
    if (abs(lastXpos - xPos) > 1 || abs(lastYpos - yPos) > 1) do
      # IO.puts "if of FIX board flippedSquares: "
      # IO.inspect flippedSquares
      flippedSquares
    else
      IO.puts "else of FIX board flippedSquares: "
      IO.inspect flippedSquares
      IO.inspect xIsNext
      #  IO.puts "in else of infor_loop just before COND"
      IO.inspect Enum.at(flippedSquares, y)
      cond do
        # Next square was occupied with the opposite color
        Enum.at(flippedSquares, y) === (if !xIsNext, do: "X", else: "O") ->
          sq = if xIsNext, do: "X", else: "O"
           IO.puts "first cond sq: replacing position with sq "
           IO.inspect sq
          flippedSquares = List.replace_at(flippedSquares, y, sq)
          atleastOneMarkIsFlipped = true
          {lastXpos, lastYpos} = {xPos, yPos}
          # IO.puts "inside opposite color flippedSquares: "
          # IO.inspect flippedSquares
          modifiedBoard = flippedSquares
          # IO.puts "first cond calling for_loop, y and offset:"
          # IO.inspect y
          # IO.inspect offset
          flippedSquares = infor_loop(y + offset, offset, lastXpos, lastYpos, flippedSquares, xIsNext, atleastOneMarkIsFlipped, squares, position, modifiedBoard, startX, startY)
        # Next square was occupied with the same color
        ((Enum.at(flippedSquares, y) === (if xIsNext, do: "X", else: "O")) && atleastOneMarkIsFlipped)  ->
          sq = if xIsNext, do: "X", else: "O"
           IO.puts "second cond sq: replacing position with: "
           IO.inspect sq
          flippedSquares = List.replace_at(flippedSquares, position, sq)
          modifiedBoard = flippedSquares
          # IO.puts "inside same color flippedSquares: "
          # IO.inspect flippedSquares
          # IO.puts "inside same color modifiedBoard: "
          # IO.inspect modifiedBoard
          flippedSquares = foreach_loop(offset, squares, position, xIsNext, modifiedBoard, startX, startY)
          # IO.puts "second cond after in infor flippedSquares: "
          # IO.inspect flippedSquares
          flippedSquares
        true ->
           IO.puts "true offset: "
           IO.inspect offset
          flippedSquares = foreach_loop(offset, squares, position, xIsNext, modifiedBoard, startX, startY)
          # IO.puts "if true in cond of infor flippedSquares: "
          # IO.inspect flippedSquares
          flippedSquares
      end
      flippedSquares
    end
    flippedSquares
  end

  @doc """
  the index of the square clicked by user is 0, and the indexes for surrounding
  squares is 1, 7, 8, 9, -1, -7, -8, -9.
  check the current status of each of these squares
  """
  def setOffset(offset) do
    offset = case offset do
      0 -> 1
      1 -> 7
      7 -> 8
      8 -> 9
      9 -> -1
      -1 -> -7
      -7 -> -8
      -8 -> -9
      _ -> "ok"
    end
    offset
  end

  # for each offset around the current index
  def foreach_loop(offset, squares, position, xIsNext, modifiedBoard, startX, startY) do
    IO.puts "INSIDE foreach_loop:"
    IO.puts "position:"
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
      if offset != "ok" do
        y = position + offset
        flippedSquares = for_loop(y, offset, lastXpos, lastYpos, flippedSquares, xIsNext, atleastOneMarkIsFlipped, squares, position, modifiedBoard, startX, startY)
        flippedSquares
      else
        flippedSquares
      end

      IO.puts "ending foreach_loop flippedSquares "
      IO.inspect flippedSquares
    # end
    flippedSquares
  end

  @doc """
  returns a modified board after flipping the square,
  filling it with black or white piece
  """
  def flipSquares(squares, position, xIsNext) do
    #IO.puts "INSIDE flipSquares"
    modifiedBoard = nil

    # Calculate row and col of the starting position
    {startX, startY} = {rem(position,8), div((position - rem(position,8)),8)}
    # IO.puts "squares in flipSquares: "
    # IO.inspect squares
    #
    # IO.puts "position in flipSquares: "
    # IO.inspect position
    #
    # IO.puts "Enum.at(squares, position):"
    # IO.inspect Enum.at(squares, position)

    if (Enum.at(squares, position) !== nil) do
      # IO.puts "Squares in enum:"
      # IO.inspect squares
      # IO.puts "sp:"
      # IO.inspect Enum.at(squares, position)
      modifiedBoard = nil
    else
      # Iterate all directions, these numbers are the offsets in the array to reach next square
      modifiedBoard = foreach_loop(0, squares, position, xIsNext, modifiedBoard, startX, startY)
    end

    #IO.puts "INSIDE flipSquares modifiedBoard: "
    #IO.inspect modifiedBoard

    modifiedBoard
  end

  # initiates the recusion over index
  def getAvailableSquaresIndex_loop(squares, index, color, listOfAvailableSquaresIndex) when is_integer(index) do
    # IO.puts "inside GET_loop index"
    # IO.inspect index
    listOfAvailableSquaresIndex = ingetAvailableSquaresIndex_loop(squares, index, color, listOfAvailableSquaresIndex)
    # IO.puts "inside GET_loop listOfAvailableSquaresIndex"
    # IO.inspect listOfAvailableSquaresIndex
    listOfAvailableSquaresIndex
  end

  # recursive call until index becomes greater than or equal to 64
  defp ingetAvailableSquaresIndex_loop(squares, index, color, listOfAvailableSquaresIndex) when index >= 64, do: listOfAvailableSquaresIndex

  # recursive call until index is less than 64
  defp ingetAvailableSquaresIndex_loop(squares, index, color, listOfAvailableSquaresIndex) when index < 64 do
    # IO.puts "inside INget_loop"
    # IO.puts "inside INget_loop BEFORE flipSquares index"
    # IO.inspect index

    modifiedBoard = flipSquares(squares, index, color)

    # IO.puts "inside INget_loop AFTER flipSquares index"
    # IO.inspect index
    # IO.puts "inside INget_loop squares"
    # IO.inspect squares
    # IO.puts "inside INget_loop modifiedBoard"
    # IO.inspect modifiedBoard
    if modifiedBoard != nil do

      if Enum.at(modifiedBoard, index) != nil do
        IO.inspect index
        listOfAvailableSquaresIndex = listOfAvailableSquaresIndex ++ [index]
        # IO.puts "check here: listOfAvailableSquaresIndex "
        # IO.inspect listOfAvailableSquaresIndex, charlists: false
      else
        listOfAvailableSquaresIndex
      end
    else
      listOfAvailableSquaresIndex
    end
      # IO.puts "inside INget_loop listOfAvailableSquaresIndex"
      # IO.inspect listOfAvailableSquaresIndex, charlists: :as_lists
      listOfAvailableSquaresIndex = ingetAvailableSquaresIndex_loop(squares, index + 1, color, listOfAvailableSquaresIndex)
      listOfAvailableSquaresIndex
  end

  @doc """
  returns a list of all the available squares that a player can click on to get
  maximum pieces of his color on the board
  """
  def checkAvailableMoves(color, squares) do
    # IO.puts "============INSIDE checkAvailableMoves============"
    # IO.inspect(squares)

    availableSquares = getAvailableSquaresIndex_loop(squares, 0, color, [])
    # IO.puts "availableSquares: "
    # IO.inspect availableSquares
    availableSquares
  end

  @doc """
  returns a board for the opponent player, replacing the squares with pieces
  as per the actions of current player click
  """
  def handleClick(game, id) do
    IO.puts "INSIDE---------------------handleClick"
    IO.inspect(game.squares)
    squares = game.squares
    black_pieces = game.black_pieces
    white_pieces = game.white_pieces
    xWasNext = game.xWasNext
    xIsNext = game.xIsNext
    black_player = game.black_player
    white_player = game.white_player
    current_player= game.current_player
    availableMoves = game.availableMoves

    if calculateWinner(black_pieces, white_pieces) || Enum.at(squares,id) do
      # IO.puts "handleClick calculateWinner"
      changedSquares = squares
    else
      # IO.puts "else handleClick"
      changedSquares = flipSquares(squares, id, xIsNext)
      if changedSquares === nil do
        # IO.puts "else, if, handleClick"
        changedSquares = squares
      else
        # IO.puts "else, if, else, handleClick"
        black_pieces = Enum.reduce(changedSquares, 0, fn(current, acc) -> (if current === "X", do: acc + 1, else: acc) end)
        white_pieces = Enum.reduce(changedSquares, 0, fn(current, acc) -> (if current === "O", do: acc + 1, else: acc) end)
        IO.puts "xIsNext----------------------------------------"
        IO.inspect !xIsNext
        IO.puts "changedSquares--------------------------------"
        IO.inspect changedSquares
        availableSquares = checkAvailableMoves( !xIsNext, changedSquares)
        shouldTurnColor = if length(availableSquares) > 0, do: !xIsNext, else: xIsNext
        IO.puts "availableSquares--------"
        IO.inspect availableSquares
        #IO.puts "shouldTurnColor--------------------------------"
        #IO.inspect shouldTurnColor
      end
    end

    # IO.puts "black_player"
    # IO.inspect black_player
    # IO.puts "white_player"
    # IO.inspect white_player
    # IO.puts "current_player"
    # IO.inspect current_player
    # IO.puts "*******************************"

    if current_player == black_player do
      current_player = white_player
    else
      current_player = black_player
    end
    IO.puts "current_player"
    IO.inspect current_player

    %{game | availableMoves: availableSquares, squares: changedSquares, black_pieces: black_pieces, white_pieces: white_pieces, xWasNext: shouldTurnColor, xIsNext: shouldTurnColor, current_player: current_player}
  end

  @doc """
  returns a list of indexes of the squares where current player can click,
  to get maximum pieces of his color on the board
  """
  def tocheckAvailableMoves(game, color, squares) do
    availableMoves = game.availableMoves
    availableMoves = checkAvailableMoves(color, squares)
    IO.puts "after checkAvailableMoves availableMoves: "
    IO.inspect availableMoves
    %{game | availableMoves: availableMoves}
  end

  # returns the message list updated by appending messages sent by the users
  def send_msg(game, user_name, msg) do
    black_player = game.black_player
    white_player = game.white_player
    msgs = game.msgs
    if user_name == black_player or user_name == white_player do
      msgs = List.insert_at(msgs, -1, ["player", "[" <> user_name <> "]: " <> msg])
    else
      msgs = List.insert_at(msgs, -1, ["spectator", "[" <> user_name <> "]: " <> msg])
    end
    %{game | msgs: msgs}
  end

end
