defmodule OthelloWeb.GamesChannel do
  use OthelloWeb, :channel

  alias Othello.Game
  alias Othello.GameBackup

  def join("games:" <> game_name, params, socket) do
    # or the game has already started
    user = params["user"]
    game = GameBackup.load(game_name) || Game.new()
    game = Game.join(game, user)

    GameBackup.save(game_name, game)
    socket = socket
      |> assign(:game_name, game_name)
      |> assign(:user, user)

    send(self(), :after_join)
    {:ok, %{"join" => game_name, "game" => Game.client_view(game)}, socket}
  end

  # broadcast the state after new user has joined
  def handle_info(:after_join, socket) do
    game = GameBackup.load(socket.assigns[:game_name])
    broadcast! socket, "join", %{"game_state" => Game.client_view(game)}
    {:noreply, socket}
  end

  # When any user leaves the game
  def handle_in("leaveGame", %{}, socket) do
    game_name = socket.assigns[:game_name]
    user = socket.assigns[:user]
    game = GameBackup.load(game_name)
    status = game.status

    user_type = cond do
      user == game.black_player ->
        :black_player
      user == game.white_player ->
        :white_player
      true ->
        :spectator
    end

    # if game has no users, delete this game from GameBackup
    game = Game.userLeavesGame(game, user_type, user)
    GameBackup.save(game_name, game)

    if game.black_player == nil and game.white_player == nil and game.spectators == [] do
      GameBackup.remove(game_name)
    end

    # if one of the players leaves the game, then the other player wins
    is_player = user_type == :black_player or user_type == :white_player
    if is_player and status == "Playing"  do
      GameBackup.save(game_name, Map.put(game, :status, "Finished"))
      broadcast! socket, "left_game", %{"game_state" => Game.client_view(game)}
    # else just update the status
    else
      broadcast! socket, "new_msg", %{"game_state" => Game.client_view(game)}
    end
    {:noreply, socket}
  end

  def handle_in("handleClick", %{"id" => id}, socket) do
    game = GameBackup.load(socket.assigns[:game_name])
    game = Game.handleClick(game, id)
    GameBackup.save(socket.assigns[:game_name], game)
    socket = assign(socket, :game, game)
    broadcast socket, "handleClick", %{"game_state" => Game.client_view(game)}
    {:noreply, socket}
  end

  def handle_in("tocheckAvailableMoves", %{"blackWasNext" => blackWasNext, "squares" => squares}, socket) do
    game = GameBackup.load(socket.assigns[:game_name])
    game = Game.tocheckAvailableMoves(game, blackWasNext, squares)
    GameBackup.save(socket.assigns[:game_name], game)
    socket = assign(socket, :game, game)
    broadcast socket, "tocheckAvailableMoves", %{"game_state" => Game.client_view(game)}
    {:noreply, socket}
  end

  def handle_in("toReset", %{}, socket) do
    game = Game.new()
    GameBackup.save(socket.assigns[:game_name], game)
    socket = assign(socket, :game, game)

    broadcast socket, "toReset", %{"game_state" => Game.client_view(game)}
    {:noreply, socket}
  end

  # Force switch player if current player has no valid moves
  def handle_in("switch_player", _payload, socket) do
    game = GameBackup.load(socket.assigns[:game_name])
    game = Game.switch_player(game)
    GameBackup.save(socket.assigns[:game_name], game)
    if game.status == "Finished" do
      broadcast! socket, "finish", %{"game_state" => Game.client_view(game)}
      {:noreply, socket}
    else
      broadcast! socket, "move", %{"game_state" => Game.client_view(game)}
      {:noreply, socket}
    end
  end

  def handle_in("send_msg", %{"user_name" => user_name, "msg" => msg}, socket) do
    game = GameBackup.load(socket.assigns[:game_name])
    game = Game.send_msg(game, user_name, msg)
    GameBackup.save(socket.assigns[:game_name], game)
    broadcast! socket, "new_msg", %{"game_state" => Game.client_view(game)}
    {:noreply, socket}
  end

end
