defmodule Komplen.ComplaintsTest do
  use Komplen.DataCase

  alias Komplen.Accounts
  # alias Komplen.Accounts.User
  alias Komplen.Complaints

  # TODO: use the generated fixtures module

  describe "complaints" do
    alias Komplen.Complaints.Complaint

    @valid_user_attrs %{name: "some name", username: "some username"}
    @valid_attrs %{"body" => "some body", "title" => "some title"}
    @update_attrs %{"body" => "some updated body", "title" => "some updated title"}
    @invalid_attrs %{"body" => nil, "title" => nil, "user" => %{id: nil}}

    def complaint_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_user_attrs)
        |> Accounts.create_user()

      {:ok, complaint} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Map.put("user_id", user.id)
        |> Complaints.create_complaint()

      complaint
      |> Map.put(:user, user)
    end

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_user_attrs)
        |> Accounts.create_user()

      user
    end

    test "list_complaints/0 returns all complaints" do
      complaint = complaint_fixture()

      assert Complaints.list_complaints() == [complaint]
    end

    test "get_complaint!/1 returns the complaint with given id" do
      complaint = complaint_fixture()
      assert Complaints.get_complaint!(complaint.id) == complaint
    end

    test "create_complaint/1 with valid data and user creates a complaint" do
      # not sure if this is the best way to test this
      user = user_fixture()
      complaint_with_user = Map.put(@valid_attrs, "user_id", user.id)
      assert {:ok, %Complaint{} = complaint} = Complaints.create_complaint(complaint_with_user)
      assert complaint.body == "some body"
      assert complaint.title == "some title"
    end

    test "create_complaint/1 with valid data but invalid user returns error changeset" do
      complaint_with_invalid_user = Map.put(@valid_attrs, "user_id", 1)

      assert {:error, %Ecto.Changeset{}} =
               Complaints.create_complaint(complaint_with_invalid_user)
    end

    test "create_complaint/1 with invalid data returns error changeset" do
      complaint_with_invalid_data = Map.put(@invalid_attrs, "user_id", 1)

      assert {:error, %Ecto.Changeset{}} =
               Complaints.create_complaint(complaint_with_invalid_data)
    end

    @tag :individual_test
    test "update_complaint/2 with valid data updates the complaint" do
      complaint = complaint_fixture()

      assert {:ok, %Complaint{} = complaint} =
               Complaints.update_complaint(complaint, @update_attrs)

      assert complaint.body == "some updated body"
      assert complaint.title == "some updated title"
    end

    test "update_complaint/2 with invalid data returns error changeset" do
      complaint = complaint_fixture()
      assert {:error, %Ecto.Changeset{}} = Complaints.update_complaint(complaint, @invalid_attrs)
    end

    test "delete_complaint/1 deletes the complaint" do
      complaint = complaint_fixture()
      assert {:ok, %Complaint{}} = Complaints.delete_complaint(complaint)
      assert_raise Ecto.NoResultsError, fn -> Complaints.get_complaint!(complaint.id) end
    end

    test "change_complaint/1 returns a complaint changeset" do
      complaint = complaint_fixture()
      assert %Ecto.Changeset{} = Complaints.change_complaint(complaint)
    end

    test "search_complaints/1 returns a complaint when given the exact term" do
      complaint = complaint_fixture()
      assert Complaints.search_complaints("some title") == [complaint]
    end
  end

  describe "vouches" do
    alias Komplen.Complaints.Vouch

    @invalid_attrs %{}

    def vouch_fixture() do
      complaint = complaint_fixture()

      {:ok, vouch} =
        %{user_id: complaint.user_id, complaint_id: complaint.id}
        |> Complaints.add_vouch()

      vouch
    end

    test "list_vouches/0 returns all vouches" do
      vouch = vouch_fixture()
      assert Complaints.list_vouches() == [vouch]
    end

    test "list_vouches/1 returns all vouches based on the complaint_id" do
      vouch = vouch_fixture()
      assert Complaints.list_vouches({:complaint_id, vouch.complaint_id}) == [vouch]
    end

    test "get_vouch!/1 returns the vouch with given id" do
      vouch = vouch_fixture()
      assert Complaints.get_vouch!(vouch.id) == vouch
    end

    test "get_vouch/1 returns the vouch with given complaint id and user id" do
      vouch = vouch_fixture()

      assert Complaints.get_vouch([{:complaint_id, vouch.complaint_id}, {:user_id, vouch.user_id}]) ==
               vouch
    end

    test "add_vouch/1 with valid data creates a vouch" do
      complaint = complaint_fixture()

      assert {:ok, %Vouch{} = _vouch} =
               %{user_id: complaint.user_id, complaint_id: complaint.id}
               |> Complaints.add_vouch()
    end

    test "add_vouch/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Complaints.add_vouch(@invalid_attrs)
    end

    test "remove_vouch/1 deletes the vouch" do
      vouch = vouch_fixture()
      assert {:ok, %Vouch{}} = Complaints.remove_vouch(vouch)
      assert_raise Ecto.NoResultsError, fn -> Complaints.get_vouch!(vouch.id) end
    end
  end
end
