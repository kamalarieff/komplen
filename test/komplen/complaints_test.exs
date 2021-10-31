defmodule Komplen.ComplaintsTest do
  use Komplen.DataCase

  alias Komplen.Accounts
  # alias Komplen.Accounts.User
  alias Komplen.Complaints

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
        |> Map.put("user", user)
        |> Complaints.create_complaint()

      complaint
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
      complaint_with_user = Map.put(@valid_attrs, "user", user)
      assert {:ok, %Complaint{} = complaint} = Complaints.create_complaint(complaint_with_user)
      assert complaint.body == "some body"
      assert complaint.title == "some title"
    end
    
    test "create_complaint/1 with valid data but invalid user returns error changeset" do
      complaint_with_invalid_user = Map.put(@valid_attrs, "user", %{id: 1})
      assert {:error, %Ecto.Changeset{}} = Complaints.create_complaint(complaint_with_invalid_user)
    end

    test "create_complaint/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Complaints.create_complaint(@invalid_attrs)
    end

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
      assert complaint == Complaints.get_complaint!(complaint.id)
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
  end
end
