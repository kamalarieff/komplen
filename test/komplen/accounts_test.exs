defmodule Komplen.AccountsTest do
  use Komplen.DataCase

  alias Komplen.Accounts

  describe "users" do
    alias Komplen.Accounts.User

    @valid_attrs %{username: "some username"}
    @update_attrs %{username: "some updated username"}
    @invalid_attrs %{username: nil}

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_user()

      user
    end

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Accounts.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Accounts.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Accounts.create_user(@valid_attrs)
      assert user.username == "some username"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      assert {:ok, %User{} = user} = Accounts.update_user(user, @update_attrs)
      assert user.username == "some updated username"
    end

    test "authenticate_by_username/1 and authenticate_by_id/1 with valid data returns user" do
      user = user_fixture()
      assert {:ok, %User{} = user} = Accounts.authenticate_by_username("some username")
      assert user.username == "some username"
      assert {:ok, %User{} = user} = Accounts.authenticate_by_id(user.id)
    end

    # this test can probably be deleted because it is testing for implementation details
    test "authenticate_by_username/1 with invalid data returns error" do
      assert {:error, :missing_name} = Accounts.authenticate_by_username(nil)
    end

    # this test can probably be deleted because it is testing for implementation details
    test "authenticate_by_id/1 with invalid data returns error" do
      assert {:error, :missing_id} = Accounts.authenticate_by_id(nil)
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
      assert user == Accounts.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end
  end

  describe "admins" do
    alias Komplen.Accounts.{User, Admin}

    @valid_user_attrs %{name: "some name", username: "some username"}
    @valid_attrs %{}
    @update_attrs %{}
    @invalid_attrs %{}

    def admin_fixture(attrs \\ %{}) do
      {:ok, %User{} = user} = Accounts.create_user(@valid_user_attrs)
      {:ok, admin} = Accounts.create_admin(user, attrs)

      Admin
      |> Repo.get!(admin.id)
      |> Repo.preload(:user)
    end

    test "list_admins/0 returns all admins" do
      admin = admin_fixture()
      assert Accounts.list_admins() == [admin]
    end

    test "get_admin!/1 returns the admin with given id" do
      admin = admin_fixture()
      assert Accounts.get_admin!(admin.id) == admin
    end

    test "create_admin/1 with valid user data creates a admin" do
      assert {:ok, %User{} = user} = Accounts.create_user(@valid_user_attrs)
      assert {:ok, %Admin{} = admin} = Accounts.create_admin(user, @valid_attrs)
    end

    test "create_admin/1 with invalid user data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_admin(%User{}, @valid_attrs)
    end

    test "create_admin/1 with duplicate user data returns error changeset" do
      assert {:ok, %User{} = user} = Accounts.create_user(@valid_user_attrs)
      assert {:ok, %Admin{} = _admin} = Accounts.create_admin(user, @valid_attrs)
      assert {:error, %Ecto.Changeset{}} = Accounts.create_admin(user, @valid_attrs)
    end

    test "create_admin/1 with invalid data returns error changeset" do
      assert {:ok, user} = Accounts.create_user(@valid_user_attrs)
      assert {:error, %Ecto.Changeset{}} = Accounts.create_admin(user, @invalid_attrs)
    end

    test "update_admin/2 with valid data updates the admin" do
      admin = admin_fixture()
      assert {:ok, %Admin{} = admin} = Accounts.update_admin(admin, @update_attrs)
    end

    test "update_admin/2 with invalid data returns error changeset" do
      admin = admin_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_admin(admin, @invalid_attrs)
      assert admin == Accounts.get_admin!(admin.id)
    end

    test "delete_admin/1 deletes the admin" do
      admin = admin_fixture()
      assert {:ok, %Admin{}} = Accounts.delete_admin(admin)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_admin!(admin.id) end
    end

    test "change_admin/1 returns a admin changeset" do
      admin = admin_fixture()
      assert %Ecto.Changeset{} = Accounts.change_admin(admin)
    end
  end

  describe "profiles" do
    alias Komplen.Accounts.{User, Profile}

    @valid_user_attrs %{username: "some username"}
    @valid_attrs %{
      "name" => "some name",
      "phone" => "some phone",
      "email" => "some email",
      "ic_number" => "some ic_number"
    }
    @update_attrs %{
      "name" => "updated name"
    }
    @invalid_attrs %{
      "name" => ""
    }

    def profile_fixture(attrs \\ %User{}) do
      %{id: user_id} = attrs

      {:ok, profile} =
        @valid_attrs
        |> Map.put("user_id", user_id)
        |> Accounts.create_profile()

      profile
    end

    test "list_profiles/0 returns all profiles" do
      user = user_fixture()
      profile = profile_fixture(user)
      assert Accounts.list_profiles() == [profile]
    end

    test "get_profile!/1 returns the profile with given id" do
      user = user_fixture()
      profile = profile_fixture(user)
      assert Accounts.get_profile!(profile.id) == profile
    end

    test "create_profile/1 with valid data creates a profile" do
      user = user_fixture()

      profile_attrs =
        @valid_attrs
        |> Map.put("user_id", user.id)

      assert {:ok, %Profile{} = profile} = Accounts.create_profile(profile_attrs)
    end

    test "create_profile/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_profile(@invalid_attrs)
    end

    test "update_profile/2 with valid data updates the profile" do
      user = user_fixture()
      profile = profile_fixture(user)
      assert {:ok, %Profile{} = profile} = Accounts.update_profile(profile, @update_attrs)
    end

    test "update_profile/2 with invalid data returns error changeset" do
      user = user_fixture()
      profile = profile_fixture(user)
      assert {:error, %Ecto.Changeset{}} = Accounts.update_profile(profile, @invalid_attrs)
      assert profile == Accounts.get_profile!(profile.id)
    end

    test "delete_profile/1 deletes the profile" do
      user = user_fixture()
      profile = profile_fixture(user)
      assert {:ok, %Profile{}} = Accounts.delete_profile(profile)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_profile!(profile.id) end
    end

    @tag :individual_test
    test "change_profile/1 returns a profile changeset" do
      user = user_fixture()
      profile = profile_fixture(user)
      assert %Ecto.Changeset{} = Accounts.change_profile(profile)
    end
  end
end
