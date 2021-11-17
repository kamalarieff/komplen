defmodule KomplenWeb.ComplaintLiveTest do
  use KomplenWeb.ConnCase

  import Phoenix.LiveViewTest
  import Komplen.{ComplaintsFixtures, AccountsFixtures}

  @create_user_attrs %{"username" => "some username"}
  @create_attrs %{"body" => "some body", "title" => "some title"}
  @update_attrs %{"body" => "updated body"}
  @invalid_attrs %{"body" => ""}

  defp create_complaint(_) do
    user = user_fixture(@create_user_attrs)
    complaint = complaint_fixture(Map.put(@create_attrs, "user_id", user.id))
    %{complaint: complaint}
  end

  describe "Index" do
    setup [:create_complaint]

    test "lists all complaints", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, Routes.complaint_index_path(conn, :index))

      assert html =~ "Listing Complaints"
    end

    test "saves new complaint", %{conn: conn, complaint: complaint} do
      conn =
        conn
        |> init_test_session(user_id: complaint.user_id)

      {:ok, index_live, _html} = live(conn, Routes.complaint_index_path(conn, :index))

      assert index_live |> element("a", "New Complaint") |> render_click() =~
               "New Complaint"

      assert_patch(index_live, Routes.complaint_index_path(conn, :new))

      assert index_live
             |> form("#complaint-form", complaint: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#complaint-form", complaint: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.complaint_index_path(conn, :index))

      assert html =~ "Complaint created successfully"
    end

    test "updates complaint in listing", %{conn: conn, complaint: complaint} do
      {:ok, index_live, _html} = live(conn, Routes.complaint_index_path(conn, :index))

      assert index_live |> element("#complaint-#{complaint.id} a", "Edit") |> render_click() =~
               "Edit Complaint"

      assert_patch(index_live, Routes.complaint_index_path(conn, :edit, complaint))

      assert index_live
             |> form("#complaint-form", complaint: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#complaint-form", complaint: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.complaint_index_path(conn, :index))

      assert html =~ "Complaint updated successfully"
    end

    test "deletes complaint in listing", %{conn: conn, complaint: complaint} do
      {:ok, index_live, _html} = live(conn, Routes.complaint_index_path(conn, :index))

      assert index_live |> element("#complaint-#{complaint.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#complaint-#{complaint.id}")
    end
  end

  describe "Show" do
    setup [:create_complaint]

    test "displays complaint", %{conn: conn, complaint: complaint} do
      {:ok, _show_live, html} = live(conn, Routes.complaint_show_path(conn, :show, complaint))

      assert html =~ "Show Complaint"
    end

    test "updates complaint within modal", %{conn: conn, complaint: complaint} do
      {:ok, show_live, _html} = live(conn, Routes.complaint_show_path(conn, :show, complaint))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Complaint"

      assert_patch(show_live, Routes.complaint_show_path(conn, :edit, complaint))

      assert show_live
             |> form("#complaint-form", complaint: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#complaint-form", complaint: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.complaint_show_path(conn, :show, complaint))

      assert html =~ "Complaint updated successfully"
    end
  end
end
