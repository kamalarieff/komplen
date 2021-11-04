defmodule KomplenWeb.VouchControllerTest do
  use KomplenWeb.ConnCase

  alias Komplen.{Accounts, Complaints}

  @create_user_attrs %{"name" => "some name", "username" => "some username"}
  @create_complaint_attrs %{"body" => "some body", "title" => "some title"}

  def fixture(:vouch, attrs) do
    %{user: user, complaint: complaint} = attrs
    {:ok, vouch} = Complaints.add_vouch(%{user_id: user.id, complaint_id: complaint.id})
    vouch
  end

  def fixture(:user_complaint) do
    {:ok, user} = Accounts.create_user(@create_user_attrs)

    {:ok, complaint} =
      @create_complaint_attrs
      |> Map.put("user", user)
      |> Complaints.create_complaint()

    {user, complaint}
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all vouches", %{conn: conn} do
      conn = get(conn, Routes.vouch_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create vouch" do
    setup [:create_user_complaint]

    test "renders vouch when data is valid", %{conn: conn, user: user, complaint: complaint} do
      conn =
        conn
        |> init_test_session(user_id: user.id)
        |> post(Routes.vouch_path(conn, :create), %{"complaint_id" => complaint.id})

      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.vouch_path(conn, :show, id))

      assert %{
               "id" => id
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when user is not logged in", %{conn: conn, complaint: complaint} do
      conn =
        conn
        |> init_test_session(%{})
        |> fetch_flash()
        |> post(Routes.vouch_path(conn, :create), %{"complaint_id" => complaint.id})

      assert redirected_to(conn) == Routes.session_path(conn, :new)
    end

    test "renders errors when data is invalid", %{conn: conn, user: user} do
      conn =
        conn
        |> init_test_session(user_id: user.id)
        |> post(Routes.vouch_path(conn, :create), %{"complaint_id" => -1})

      assert %{
               "complaint_id" => ["does not exist"]
             } = json_response(conn, 422)["errors"]

      # assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete vouch" do
    setup [:create_vouch]

    test "deletes chosen vouch", %{conn: conn, user: user, vouch: vouch} do
      conn =
        conn
        |> init_test_session(user_id: user.id)
        |> delete(Routes.vouch_path(conn, :delete, vouch.id))

      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.vouch_path(conn, :show, vouch.id))
      end
    end

    @tag :individual_test
    test "redirects to login page when user is not logged in", %{conn: conn, vouch: vouch} do
      conn =
        conn
        |> init_test_session(%{})
        |> fetch_flash()
        |> delete(Routes.vouch_path(conn, :delete, vouch.id))

      assert redirected_to(conn) == Routes.session_path(conn, :new)
    end
  end

  defp create_user_complaint(_) do
    {user, complaint} = fixture(:user_complaint)
    %{user: user, complaint: complaint}
  end

  defp create_vouch(_) do
    {user, complaint} = fixture(:user_complaint)
    vouch = fixture(:vouch, %{user: user, complaint: complaint})
    %{vouch: vouch, user: user, complaint: complaint}
  end
end
