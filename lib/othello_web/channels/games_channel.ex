defmodule OthelloWeb.GamesChannel do
  use OthelloWeb, :channel

  alias Othello.Game
  alias Othello.GameBackup

  def join("games:" <> game_name, params, socket) do
    IO.inspect params
    IO.puts "INSIDE JOIN"
    # or the game has already started
    user = params["user"]
    IO.inspect user

    IO.puts "*_*_*_*_*_*_"
    game = GameBackup.load(game_name) || Game.new()
    game = Game.join(game, user)

    GameBackup.save(game_name, game)
    socket = socket
      |> assign(:name, game_name)

    send(self(), :after_join)
    {:ok, %{"join" => game_name, "game" => Game.client_view(game)}, socket}
  end

  def handle_info(:after_join, socket) do
    game = GameBackup.load(socket.assigns[:name])
    broadcast! socket, "join", %{"game_state" => Game.client_view(game)}
    {:noreply, socket}
  end

  def handle_in("toleaveGame", %{"current_player" => current_player, "black_player" => black_player, "white_player" => white_player, "spectators" => spectators}, socket) do
    game = GameBackup.load(socket.assigns[:name])
    game = Game.tohandleClick(game, current_player, black_player, white_player, spectators)
    IO.puts("handle_in game: ")
    IO.inspect game

    GameBackup.save(socket.assigns[:name], game)

    socket = assign(socket, :game, game)
    IO.inspect socket

    broadcast socket, "toleaveGame", %{"game_state" => Game.client_view(game)}
    {:noreply, socket}
  end

  # When any user leaves the game
  def handle_in("toleaveGame", %{}, socket) do
    game_name = socket.assigns[:game_name]
    user_name = socket.assigns[:user_name]
    game = GameBackUp.load(game_name)
    status = game.status

    user_type = cond do
      user_name == game.black_player ->
        :black_player
      user_name == game.white_player ->
        :white_player
      true ->
        :spectator
    end

    # if game has no users, delete this game from GameBackUp
    game = Game.userLeavesGame(game, user_type, user_name)
    GameBackUp.save(game_name, game)

    if game.black_player == "" and game.white_player == "" and game.spectators == [] do
      GameBackUp.remove(game_name)
    end

    # if one of the players leaves the game, the other player wins
    is_player = user_type == :black_player or user_type == :white_player
    if is_player and status == "Playing"  do
      GameBackUp.save(game_name, Map.put(game, :status, "Finished"))
      broadcast! socket, "left_game", %{"game_state" => Game.client_view(game)}
    # else just update the status
    else
      broadcast! socket, "new_msg", %{"game_state" => Game.client_view(game)}
    end
    {:noreply, socket}
  end

  def handle_in("tohandleClick", %{"id" => id}, socket) do
    game = GameBackup.load(socket.assigns[:name])
    game = Game.tohandleClick(game, id)
    IO.puts("handle_in game: ")
    IO.inspect game

    GameBackup.save(socket.assigns[:name], game)

    socket = assign(socket, :game, game)
    IO.inspect socket

    broadcast socket, "tohandleClick", %{"game_state" => Game.client_view(game)}
    {:noreply, socket}
  end

  def handle_in("tocheckAvailableMoves", %{"xWasNext" => xWasNext, "squares" => squares}, socket) do
    game = GameBackup.load(socket.assigns[:name])
    IO.puts "handle_in loaded game"
    IO.inspect game
    IO.puts "*******--------------------------------******"

    game = Game.tocheckAvailableMoves(game, xWasNext, squares)
    GameBackup.save(socket.assigns[:name], game)

    IO.inspect game

    IO.puts "AFTER tocheckAvailableMoves"
    socket = assign(socket, :game, game)

    broadcast socket, "tocheckAvailableMoves", %{"game_state" => Game.client_view(game)}
    {:noreply, socket}
  end


  def handle_in("tocheckAvailableMovesOpposite", %{"notxWasNext" => notxWasNext, "squares" => squares}, socket) do
    game = GameBackup.load(socket.assigns[:name])
    game = Game.tocheckAvailableMovesOpposite(game, notxWasNext, squares)
    GameBackup.save(socket.assigns[:name], game)
    socket = assign(socket, :game, game)

    broadcast socket, "tocheckAvailableMovesOpposite", %{"game_state" => Game.client_view(game)}
    {:noreply, socket}
  end

  def handle_in("toReset", %{}, socket) do
    game = Game.new()
    GameBackup.save(socket.assigns[:name], game)
    socket = assign(socket, :game, game)

    broadcast socket, "toReset", %{"game_state" => Game.client_view(game)}
    {:noreply, socket}
  end

  def handle_in("send_msg", %{"user_name" => user_name, "msg" => msg}, socket) do
    game = GameBackUp.load(socket.assigns[:name])
    game = Game.send_msg(game, user_name, msg)
    GameBackUp.save(socket.assigns[:name], game)
    broadcast! socket, "new_msg", %{"game_state" => Game.client_view(game)}
    {:noreply, socket}
  end

end
