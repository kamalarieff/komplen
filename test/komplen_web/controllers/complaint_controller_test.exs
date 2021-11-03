defmodule KomplenWeb.ComplaintControllerTest do
  use KomplenWeb.ConnCase

  alias Komplen.{Accounts, Complaints}

  @create_user_attrs %{"name" => "some name", "username" => "some username"}
  @create_attrs %{"body" => "some body", "title" => "some title"}
  @update_attrs %{"body" => "some updated body", "title" => "some updated title"}
  @invalid_attrs %{"body" => nil, "title" => nil}

  @moduletag :ComplaintController

  def fixture(:complaint) do
    {:ok, complaint} = Complaints.create_complaint(@create_attrs)

    complaint
  end

  def fixture(:user) do
    {:ok, user} = Accounts.create_user(@create_user_attrs)
    user
  end

  # we need to pass a user to create a complaint because it needs a user to create one
  def fixture(:user_complaint) do
    {:ok, user} = Accounts.create_user(@create_user_attrs)

    {:ok, complaint} =
      @create_attrs
      |> Map.put("user", user)
      |> Complaints.create_complaint()

    {user, complaint}
  end

  describe "index" do
    test "lists all complaints", %{conn: conn} do
      conn = get(conn, Routes.complaint_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Complaints"
    end
  end

  describe "new complaint" do
    setup [:create_user]

    test "renders form", %{conn: conn, user: user} do
      conn =
        conn
        |> init_test_session(user_id: user.id)
        |> get(Routes.complaint_path(conn, :new))

      assert html_response(conn, 200) =~ "New Complaint"
    end

    test "redirects to login page when there is no user", %{conn: conn} do
      conn = get(conn, Routes.complaint_path(conn, :new))
      assert redirected_to(conn) == Routes.session_path(conn, :new)
    end
  end

  describe "create complaint" do
    setup [:create_user_complaint]

    test "redirects to show when data is valid", %{conn: conn, user: user} do
      conn =
        conn
        |> init_test_session(user_id: user.id)
        |> post(Routes.complaint_path(conn, :create), complaint: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.complaint_path(conn, :show, id)

      conn = get(conn, Routes.complaint_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Complaint"
    end

    test "renders errors when data is invalid", %{conn: conn, user: user} do
      conn =
        conn
        |> init_test_session(user_id: user.id)
        |> post(Routes.complaint_path(conn, :create), complaint: @invalid_attrs)

      assert html_response(conn, 200) =~ "New Complaint"
    end
  end

  describe "edit complaint" do
    setup [:create_user_complaint]

    test "renders form for editing chosen complaint", %{
      conn: conn,
      user: user,
      complaint: complaint
    } do
      conn =
        conn
        |> init_test_session(user_id: user.id)
        |> get(Routes.complaint_path(conn, :edit, complaint))

      assert html_response(conn, 200) =~ "Edit Complaint"
    end
  end

  describe "update complaint" do
    setup [:create_user_complaint]

    test "redirects when data is valid", %{conn: conn, user: user, complaint: complaint} do
      conn =
        conn
        |> init_test_session(user_id: user.id)
        |> put(Routes.complaint_path(conn, :update, complaint), complaint: @update_attrs)

      assert redirected_to(conn) == Routes.complaint_path(conn, :show, complaint)

      conn = get(conn, Routes.complaint_path(conn, :show, complaint))
      assert html_response(conn, 200) =~ "some updated body"
    end

    test "renders errors when data is invalid", %{conn: conn, complaint: complaint} do
      conn = put(conn, Routes.complaint_path(conn, :update, complaint), complaint: @invalid_attrs)
      assert redirected_to(conn) == Routes.session_path(conn, :new)
    end
  end

  describe "delete complaint" do
    setup [:create_user_complaint]

    test "deletes chosen complaint when authenticated", %{conn: conn, user: user, complaint: complaint} do
      conn =
        conn
        |> init_test_session(user_id: user.id)
        |> delete(Routes.complaint_path(conn, :delete, complaint))
      assert redirected_to(conn) == Routes.complaint_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.complaint_path(conn, :show, complaint))
      end
    end

    test "redirected when not authenticated", %{conn: conn, complaint: complaint} do
      conn = delete(conn, Routes.complaint_path(conn, :delete, complaint))
      assert redirected_to(conn) == Routes.session_path(conn, :new)
    end
  end

  defp create_complaint(_) do
    complaint = fixture(:complaint)
    %{complaint: complaint}
  end

  defp create_user_complaint(_) do
    {user, complaint} = fixture(:user_complaint)
    %{user: user, complaint: complaint}
  end

  defp create_user(_) do
    user = fixture(:user)
    %{user: user}
  end
end
