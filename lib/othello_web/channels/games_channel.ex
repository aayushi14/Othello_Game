defmodule OthelloWeb.GamesChannel do
  use OthelloWeb, :channel

  alias Othello.Game
  alias Phoenix.Socket

  def join("games:" <> gname, payload, socket) do
    if authorized?(payload) do
      # newState = if(Othello.GameBackup.load(name)) do
      #   Othello.GameBackup.load(name)
      #   else
      #   game = Game.client_view(Game.new())
      # end
      socket = socket
      |> Socket.assign(:name, gname)
      |> Socket.assign(:user, payload["user"])
      # {:ok, %{"join" => name, "game" => newState}, socket}
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_in("doReset", %{}, socket) do
    game = Game.doReset(socket.assigns[:game])
    socket = assign(socket, :game, game)
    Othello.GameBackup.save(socket.assigns[:name], game)
    {:reply, {:ok, %{"game" => game}}, socket}
  end

  def handle_in("loadNew", %{}, socket) do
    game = Game.loadNew(socket.assigns[:game])
    Othello.GameBackup.save(socket.assigns[:name], game)
    socket = assign(socket, :game, game)
    {:reply, {:ok, %{"game" => game}}, socket}
  end


  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
