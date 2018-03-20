defmodule OthelloWeb.GamesChannel do
  use OthelloWeb, :channel

  alias Othello.Game
  alias Othello.GameBackup

  def join("games:" <> g_name, params, socket) do
    IO.puts "INSIDE JOIN"
    # or the game has already started
    user = params["user"]
    game = GameBackup.load(g_name) || Game.new()
    IO.puts "squares length"
    IO.inspect length(game.squares)
    
    IO.inspect game

    game = Game.join(game, user)

    GameBackup.save(g_name, game)
    socket = socket
      |> assign(:name, g_name)

    # send(self(), :after_join)
    {:ok, %{"join" => g_name, "game" => Game.client_view(game)}, socket}
  end

  def handle_info(:after_join, socket) do
    game = GameBackup.load(socket.assigns[:name])
    broadcast! socket, "join", %{"game_state" => Game.client_view(game)}
    {:noreply, socket}
  end


  # def handle_in("othello", %{"state" => state}, socket) do
  #   name = socket.assigns[:name]
  #   user  = socket.assigns[:user]
  #   #game = Game.load(name)
  #   game =  %{ name: name, host: user, state: state }
  #   GameBackup.save(name, game)
  #
  #   broadcast socket, "othello", %{"game" => game}
  #   {:reply, {:ok, %{}}, socket}
  #   #{:reply, {:ok, %{"game" => game}}, socket}
  # end

  def handle_in("tohandleClick", %{"id" => id}, socket) do
    game = GameBackup.load(socket.assigns[:name])
    game = Game.tohandleClick(game, id)
    IO.puts("handle_in game: ")
    IO.inspect game

    GameBackup.save(socket.assigns[:name], game)
    socket = assign(socket, :game, game)
    {:reply, {:ok, %{"game" => game}}, socket}
  end

  def handle_in("tocheckAvailableMoves", %{"xWasNext" => xWasNext, "squares" => squares}, socket) do
    game = GameBackup.load(socket.assigns[:name])
    game = Game.tocheckAvailableMoves(socket.assigns[:game], xWasNext, squares)
    GameBackup.save(socket.assigns[:name], game)
    socket = assign(socket, :game, game)
    {:reply, {:ok, %{"game" => game}}, socket}
  end


  def handle_in("tocheckAvailableMovesOpposite", %{"notxWasNext" => notxWasNext, "squares" => squares}, socket) do
    game = GameBackup.load(socket.assigns[:name])
    game = Game.tocheckAvailableMovesOpposite(socket.assigns[:game], notxWasNext, squares)
    GameBackup.save(socket.assigns[:name], game)
    socket = assign(socket, :game, game)
    {:reply, {:ok, %{"game" => game}}, socket}
  end

  def handle_in("toReset", %{}, socket) do
    game = Game.new()
    GameBackup.save(socket.assigns[:name], game)
    socket = assign(socket, :game, game)
    {:reply, {:ok, %{"game" => game}}, socket}
  end


  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
