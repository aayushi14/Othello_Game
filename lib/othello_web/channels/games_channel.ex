defmodule OthelloWeb.GamesChannel do
  use OthelloWeb, :channel

  alias Othello.Game

  def join("game:" <> name, payload, socket) do

    if authorized?(payload) do

      IO.puts "*-*-*-*-*-*-PAYLOAD-*-*-*-*-*-*-*"

      IO.inspect payload

      game = Othello.Game.load(name) || Game.new()

      socket = socket
      |> assign(:name, name)
      |> assign(:game, game)
      |> assign(:user, payload["user"])
     
      IO.puts "*-*-*-*-*-*-SOCKET-*-*-*-*-*-*-*"
      IO.inspect socket

      IO.puts "*-*-*-*-*-*-PAYLOAD-*-*-*-*-*-*-*"
      IO.inspect payload
      {:ok, %{ "game" => game, "user" => payload["user"]}, socket}
      # {:ok, %{"join" => name, "game" => game, "user" => payload["user"]}, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_in("othello", %{"state" => state}, socket) do
    name = socket.assigns[:name]
    user  = socket.assigns[:user]
    game =  %{ name: name, host: user, state: state }
    Game.save(socket.assigns[:name], game)
    #socket = assign(socket, :game, game)
    IO.inspect game
    {:reply, {:ok, %{"game" => game}}, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
