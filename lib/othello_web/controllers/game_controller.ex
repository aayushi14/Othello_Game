defmodule OthelloWeb.GameController do
  use OthelloWeb, :controller
  alias Othello.Game


  def show(conn, %{"gname" => name}) do
    user = get_session(conn, :user)
    game = Game.load(name)
    IO.puts("*-*-*-GAME-*-*-*")
    IO.inspect game
    state = game[:state]

    host = (user == game[:host])

    if !is_nil(user) and !is_nil(game) do
      IO.puts("*-*-*-STATE-*-*-*") 
      IO.inspect state
      render conn, "show.html", user: user, host: host, game: name, state: state

    else
      conn
      |> put_flash(:error, "Bad user or game chosen")
      |> redirect(to: "/")

    end
  end


  def join(conn, %{"join_data" => join}) do
    IO.inspect join;
    game = Game.join(join["game"], join["user"])
    #IO.inspect conn
    conn
    |> put_session(:user, join["user"])
    |> redirect(to: "/game/" <> join["game"])
  end

end
