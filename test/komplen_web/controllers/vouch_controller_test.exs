defmodule KomplenWeb.VouchControllerTest do
  use KomplenWeb.ConnCase

  alias Komplen.{Accounts, Complaints}

  @create_user_attrs %{"username" => "some username"}
  @create_complaint_attrs %{"body" => "some body", "title" => "some title"}
  @create_profile_attrs %{
    name: "some name",
    phone: "some phone",
    email: "some email",
    ic_number: "some ic_number"
  }

  def fixture(:user) do
    {:ok, user} = Accounts.create_user(@create_user_attrs)
    user
  end

  def fixture(:user_complaint) do
    {:ok, user} = Accounts.create_user(@create_user_attrs)

    {:ok, complaint} =
      @create_complaint_attrs
      |> Map.put("user", user)
      |> Complaints.create_complaint()

    {user, complaint}
  end

  def fixture(:complaint, user) do
    {:ok, complaint} =
      @create_complaint_attrs
      |> Map.put("user", user)
      |> Complaints.create_complaint()

    complaint
  end

  def fixture(:vouch, attrs) do
    %{user: user, complaint: complaint} = attrs
    {:ok, vouch} = Complaints.add_vouch(%{user_id: user.id, complaint_id: complaint.id})
    vouch
  end

  def fixture(:profile, user_id) do
    {:ok, profile} =
      @create_profile_attrs
      |> Map.put(:user_id, user_id)
      |> Accounts.create_profile()

    profile
  end

  describe "create vouch when user doesn't have a profile" do
    setup do
      user = fixture(:user)
      complaint = fixture(:complaint, user)
      %{user: user, complaint: complaint}
    end

    test "redirects to profile when vouching", %{conn: conn, user: user, complaint: complaint} do
      conn =
        conn
        |> init_test_session(user_id: user.id)
        |> post(Routes.vouch_path(conn, :create), %{"complaint_id" => complaint.id})

      assert redirected_to(conn) == Routes.profile_path(conn, :edit)
    end
  end

  describe "create vouch when user have a profile" do
    setup do
      user = fixture(:user)
      complaint = fixture(:complaint, user)
      profile = fixture(:profile, user.id)
      %{user: user, complaint: complaint, profile: profile}
    end

    test "renders vouch when data is valid", %{conn: conn, user: user, complaint: complaint} do
      conn =
        conn
        |> init_test_session(user_id: user.id)
        |> post(Routes.vouch_path(conn, :create), %{"complaint_id" => complaint.id})

      assert redirected_to(conn) == Routes.complaint_path(conn, :show, complaint.id)
    end

    test "renders errors when user is not logged in", %{conn: conn, complaint: complaint} do
      conn =
        conn
        |> init_test_session(%{})
        |> fetch_flash()
        |> post(Routes.vouch_path(conn, :create), %{"complaint_id" => complaint.id})

      assert redirected_to(conn) == Routes.session_path(conn, :new)
    end

    @tag :individual_test
    test "renders errors when data is invalid", %{conn: conn, user: user} do
      conn =
        conn
        |> init_test_session(user_id: user.id)
        |> post(Routes.vouch_path(conn, :create), %{"complaint_id" => -1})

      # TODO: this is some remnants of when the vouch controller was an API
      assert %{
               "complaint_id" => ["does not exist"]
             } = json_response(conn, 422)["errors"]
    end
  end

  describe "delete vouch" do
    setup do
      user = fixture(:user)
      complaint = fixture(:complaint, user)
      vouch = fixture(:vouch, %{user: user, complaint: complaint})
      %{user: user, vouch: vouch}
    end

    test "deletes chosen vouch", %{conn: conn, user: user, vouch: vouch} do
      conn =
        conn
        |> init_test_session(user_id: user.id)
        |> delete(Routes.vouch_path(conn, :delete, vouch.id))

      assert redirected_to(conn) == Routes.complaint_path(conn, :show, vouch.complaint_id)
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
end
