defmodule OthelloWeb.GamesChannel do
  use OthelloWeb, :channel

  alias Othello.Game

  def join("game:" <> name, payload, socket) do
    if authorized?(payload) do
      game = Game.load(name) || Game.new()
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

  # def join("game:" <> name, payload, socket) do
  #   if authorized?(payload) do
  #     newState = if(Othello.GameBackup.load(name)) do
  #       Othello.GameBackup.load(name)
  #       else
  #       game = Game.client_view(Game.new())
  #     end
  #     socket = socket
  #     |> assign(:game, newState)
  #     |> assign(:name, name)
  #       {:ok, %{"join" => name, "game" => newState}, socket}
  #   else
  #     {:error, %{reason: "unauthorized"}}
  #   end
  # end

  def handle_in("othello", %{"state" => state}, socket) do
    name = socket.assigns[:name]
    user  = socket.assigns[:user]
    #game = Game.load(name)
    game =  %{ name: name, host: user, state: state }
    Othello.Game.save(socket.assigns[:name], game)

    broadcast socket, "othello", %{"game" => game}
    {:reply, {:ok, %{}}, socket}
    #{:reply, {:ok, %{"game" => game}}, socket}
  end

  def handle_in("tohandleClick", %{"id" => id}, socket) do
    game = Game.tohandleClick(socket.assigns[:game], id)
    socket = assign(socket, :game, game)
    Othello.Game.save(socket.assigns[:name], game)
    {:reply, {:ok, %{"game" => game}}, socket}
  end

  def handle_in("tocalculateWinner", %{"xNumbers" => xNumbers, "oNumbers" => oNumbers}, socket) do
    game = Game.inRender(socket.assigns[:game], xNumbers, oNumbers)
    socket = assign(socket, :game, game)
    Othello.Game.save(socket.assigns[:name], game)
    {:reply, {:ok, %{"game" => game}}, socket}
  end

  def handle_in("tocheckAvailableMoves", %{"xWasNext" => xWasNext, "squares" => squares}, socket) do
    game = Game.inRender(socket.assigns[:game], xWasNext, squares)
    socket = assign(socket, :game, game)
    Othello.Game.save(socket.assigns[:name], game)
    {:reply, {:ok, %{"game" => game}}, socket}
  end

  def handle_in("toReset", %{}, socket) do
    game = Game.new()
    socket = assign(socket, :game, game)
    Othello.Game.save(socket.assigns[:name], game)
    {:reply, {:ok, %{"game" => game}}, socket}
  end


  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
