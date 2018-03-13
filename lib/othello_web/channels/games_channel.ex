defmodule OthelloWeb.GamesChannel do
  use OthelloWeb, :channel

  alias Othello.Game
  alias Phoenix.Socket

  def join("game:" <> name, payload, socket) do
    # game = Game.get(name) || Game.new()
    # IO.puts "-*-*-*-*-*-*-*-*-*-*-*-*-"
    #IO.inspect game
    # IO.inspect payload
    # IO.puts "-*-*-*-*-*-*-*-*-*-*-*-*-"

    #state = game|> Map.get(:state);

    #IO.inspect state

    if authorized?(payload) do
      IO.puts "-*-*-*-*-*-*-*-*-*-*-*-*-"
      IO.inspect socket
      #game = Othello.GameBackup.load(name) || Game.new()
      socket = socket
      |> Socket.assign(:name, name)
      #|> assign(:game, game)
      |> Socket.assign(:user, payload["user"])
      IO.inspect socket
      IO.puts "-*-*-*-*-*-*-*-*-*-*-*-*-"

      {:ok, %{"join" => name, "user" => payload["user"]}, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
