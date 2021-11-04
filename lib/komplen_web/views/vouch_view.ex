defmodule KomplenWeb.VouchView do
  use KomplenWeb, :view
  alias KomplenWeb.VouchView

  def render("index.json", %{vouches: vouches}) do
    %{data: render_many(vouches, VouchView, "vouch.json")}
  end

  def render("show.json", %{vouch: vouch}) do
    %{data: render_one(vouch, VouchView, "vouch.json")}
  end

  def render("vouch.json", %{vouch: vouch}) do
    %{id: vouch.id}
  end
end
