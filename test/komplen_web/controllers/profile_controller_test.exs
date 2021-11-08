defmodule KomplenWeb.ProfileControllerTest do
  use KomplenWeb.ConnCase

  alias Komplen.Accounts

  @create_attrs %{
    name: "some name",
    phone: "some phone",
    email: "some email",
    ic_number: "some ic_number"
  }
  @update_attrs %{name: "updated name"}
  @invalid_attrs %{name: ""}
  @valid_user_attrs %{username: "some username"}

  def fixture(:user, attrs \\ %{}) do
    {:ok, user} = Accounts.create_user(@valid_user_attrs)
    user
  end

  def fixture(:profile, user_id) do
    {:ok, profile} =
      @create_attrs
      |> Map.put(:user_id, user_id)
      |> Accounts.create_profile()

    profile
  end

  describe "edit profile" do
    setup [:create_profile]

    test "renders form for editing chosen profile", %{conn: conn, profile: profile} do
      conn =
        conn
        |> init_test_session(user_id: profile.user_id)
        |> get(Routes.profile_path(conn, :edit))

      assert html_response(conn, 200) =~ "Edit Profile"
    end
  end

  describe "update profile" do
    setup [:create_profile]

    test "redirects when data is valid", %{conn: conn, profile: profile} do
      conn =
        conn
        |> init_test_session(user_id: profile.user_id)
        |> put(Routes.profile_path(conn, :update), profile: @update_attrs)

      assert redirected_to(conn) == Routes.profile_path(conn, :show)

      conn = get(conn, Routes.profile_path(conn, :show))
      assert html_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, profile: profile} do
      conn =
        conn
        |> init_test_session(user_id: profile.user_id)
        |> put(Routes.profile_path(conn, :update), profile: @invalid_attrs)

      assert html_response(conn, 200) =~ "Edit Profile"
    end
  end

  defp create_profile(_) do
    user = fixture(:user)
    profile = fixture(:profile, user.id)
    %{profile: profile}
  end
end
