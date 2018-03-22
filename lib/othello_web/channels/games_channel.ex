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

  def handle_in("tohandleClick", %{"id" => id}, socket) do
    game = GameBackup.load(socket.assigns[:name])
    game = Game.tohandleClick(game, id)
    IO.puts("handle_in game: ")
    IO.inspect game

    GameBackup.save(socket.assigns[:name], game)
    #socket = assign(socket, :game, game)
    #{:reply, {:ok, %{"game" => game}}, socket}
    broadcast! socket, "tohandleClick", %{"game_state" => Game.client_view(game)}
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
    {:reply, {:ok, %{"game" => game}}, socket}
    # broadcast! socket, "tocheckAvailableMoves", %{"game_state" => Game.client_view(game)}
    # {:noreply, socket}
  end


  def handle_in("tocheckAvailableMovesOpposite", %{"notxWasNext" => notxWasNext, "squares" => squares}, socket) do
    game = GameBackup.load(socket.assigns[:name])
    game = Game.tocheckAvailableMovesOpposite(game, notxWasNext, squares)
    GameBackup.save(socket.assigns[:name], game)
    # socket = assign(socket, :game, game)
    # {:reply, {:ok, %{"game" => game}}, socket}
    broadcast! socket, "tocheckAvailableMovesOpposite", %{"game_state" => Game.client_view(game)}
    {:noreply, socket}
  end

  def handle_in("toReset", %{}, socket) do
    game = Game.new()
    GameBackup.save(socket.assigns[:name], game)
    # socket = assign(socket, :game, game)
    # {:reply, {:ok, %{"game" => game}}, socket}
    broadcast! socket, "toReset", %{"game_state" => Game.client_view(game)}
    {:noreply, socket}
  end


  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
