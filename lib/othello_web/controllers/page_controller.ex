defmodule OthelloWeb.PageController do
  use OthelloWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
    # , lobby: GameBackUp.lobby, instances: GameBackUp.instances
  end

    def game(conn, params) do
    render conn, "game.html", game: params["game"], user: params["user"]
  end

end
