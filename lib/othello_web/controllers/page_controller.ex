defmodule OthelloWeb.PageController do
  use OthelloWeb, :controller

  alias Othello.GameBackup

  def index(conn, _params) do
    render conn, "index.html", room: GameBackup.room, instances: GameBackup.instances
  end

    def game(conn, params) do
    render conn, "game.html", game: params["game"], user: params["user"]
  end

end
