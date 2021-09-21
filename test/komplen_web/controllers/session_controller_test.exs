defmodule KomplenWeb.SessionControllerTest do
  use KomplenWeb.ConnCase

  alias Komplen.Accounts

  @valid_user_attrs %{name: "some name", username: "some username"}
  @invalid_user_attrs %{name: "invalid name"}
  @create_attrs %{"user" => @valid_user_attrs}
  @invalid_attrs %{"user" => @invalid_user_attrs}

  def fixture(:user) do
    {:ok, user} = Accounts.create_user(@valid_user_attrs)
    user
  end

  @moduletag :SessionController

  describe "new session" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.session_path(conn, :new))
      assert conn.status == 200
    end
  end

  describe "create session" do
    setup [:create_user]

    test "redirects to / when data is valid", %{conn: conn} do
      conn = post(conn, Routes.session_path(conn, :create), @create_attrs)

      # FIXME: couldn't test for the session user_id
      assert get_flash(conn, :info) == "Welcome some name"
      assert redirected_to(conn) == "/"
    end

    test "redirect to /new when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.session_path(conn, :create), @invalid_attrs)
      
      assert get_flash(conn, :error) == "Bad name"
      assert redirected_to(conn) == Routes.session_path(conn, :new)
    end
  end

  # describe "edit session" do
  #   setup [:create_session]

  #   test "renders form for editing chosen session", %{conn: conn, session: session} do
  #     conn = get(conn, Routes.session_path(conn, :edit, session))
  #     assert html_response(conn, 200) =~ "Edit Session"
  #   end
  # end

  # describe "update session" do
  #   setup [:create_session]

  #   test "redirects when data is valid", %{conn: conn, session: session} do
  #     conn = put(conn, Routes.session_path(conn, :update, session), session: @update_attrs)
  #     assert redirected_to(conn) == Routes.session_path(conn, :show, session)

  #     conn = get(conn, Routes.session_path(conn, :show, session))
  #     assert html_response(conn, 200)
  #   end

  #   test "renders errors when data is invalid", %{conn: conn, session: session} do
  #     conn = put(conn, Routes.session_path(conn, :update, session), session: @invalid_attrs)
  #     assert html_response(conn, 200) =~ "Edit Session"
  #   end
  # end

  # describe "delete session" do
  #   setup [:create_session]

  #   test "deletes chosen session", %{conn: conn, session: session} do
  #     conn = delete(conn, Routes.session_path(conn, :delete, session))
  #     assert redirected_to(conn) == Routes.session_path(conn, :index)
  #     assert_error_sent 404, fn ->
  #       get(conn, Routes.session_path(conn, :show, session))
  #     end
  #   end
  # end

  defp create_user(_) do
    user = fixture(:user)
    %{user: user}
  end

end
