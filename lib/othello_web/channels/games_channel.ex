defmodule OthelloWeb.GamesChannel do
  use OthelloWeb, :channel

  alias Othello.Game

  def join("game:" <> name, payload, socket) do
    if authorized?(payload) do
      game = Othello.Game.load(name) || Game.new()
      socket = socket
      |> assign(:name, name)
      |> assign(:game, game)
      |> assign(:user, payload["user"])

      {:ok, %{ "game" => game, "user" => payload["user"]}, socket}
      # {:ok, %{"join" => name, "game" => game, "user" => payload["user"]}, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_in("othello", %{"state" => state}, socket) do
    name = socket.assigns[:name]
    user  = socket.assigns[:user]
    #game = Game.load(name)
    game =  %{ name: name, host: user, state: state }
    Game.save(socket.assigns[:name], game)

    broadcast socket, "othello", %{"game" => game}
    {:reply, {:ok, %{}}, socket}
    #{:reply, {:ok, %{"game" => game}}, socket}
  end

  def handle_in("doReset", %{}, socket) do
    game = Game.new()
    socket = assign(socket, :game, game)
    Othello.Game.save(socket.assigns[:name], game)
    {:reply, {:ok, %{"game" => game}}, socket}
  end

  def handle_in("doLocal", %{}, socket) do
    game = Game.doReset(socket.assigns[:game])
    socket = assign(socket, :game, game)
    Othello.GameBackup.save(socket.assigns[:name], game)
    {:reply, {:ok, %{"game" => game}}, socket}
  end

  def handle_in("showTile", %{"opentile" => id}, socket) do
    game = Game.showTile(socket.assigns[:game], id)
    Othello.GameBackup.save(socket.assigns[:name], game)
    socket = assign(socket, :game, game)
    {:reply, {:ok, %{"game" => game}}, socket}
  end

  def handle_in("diffTiles", %{"queArray" => queArray, "opentile1" => opentile1, "opentile2" => opentile2, "disableClick" => boole}, socket) do
    game = Game.diffTiles(socket.assigns[:game], queArray, opentile1, opentile2, boole)
    Othello.GameBackup.save(socket.assigns[:name], game)
    socket = assign(socket, :game, game)
    {:reply, {:ok, %{"game" => game}}, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
