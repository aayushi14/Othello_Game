defmodule OthelloWeb.GameController do
  use OthelloWeb, :controller
  alias Othello.Game


  def show(conn, %{"gname" => name}) do
    user = get_session(conn, :user)
    game = Othello.Game.load(name)
    state = game[:state]

    host = (user == game[:host])

    if !is_nil(user) and !is_nil(game) do
      render conn, "show.html", user: user, host: host, game: name, state: state

    else
      conn
      |> put_flash(:error, "Bad user or game chosen")
      |> redirect(to: "/")

    end
  end


  def join(conn, %{"join_data" => join}) do
    IO.inspect join;
    game = Othello.Game.join(join["game"], join["user"])
    #IO.inspect conn
    conn
    |> put_session(:user, join["user"])
    |> redirect(to: "/game/" <> join["game"])
  end

end
