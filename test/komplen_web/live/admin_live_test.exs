defmodule KomplenWeb.AdminLiveTest do
  use KomplenWeb.ConnCase

  import Phoenix.LiveViewTest
  import Komplen.AccountsFixtures

  @create_attrs %{}
  @update_attrs %{}
  @invalid_attrs %{}

  defp create_admin(_) do
    admin = admin_fixture()
    %{admin: admin}
  end

  describe "Index" do
    setup [:create_admin]

    test "lists all admins", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, Routes.admin_index_path(conn, :index))

      assert html =~ "Listing Admins"
    end

    test "saves new admin", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.admin_index_path(conn, :index))

      assert index_live |> element("a", "New Admin") |> render_click() =~
               "New Admin"

      assert_patch(index_live, Routes.admin_index_path(conn, :new))

      assert index_live
             |> form("#admin-form", admin: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#admin-form", admin: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.admin_index_path(conn, :index))

      assert html =~ "Admin created successfully"
    end

    test "updates admin in listing", %{conn: conn, admin: admin} do
      {:ok, index_live, _html} = live(conn, Routes.admin_index_path(conn, :index))

      assert index_live |> element("#admin-#{admin.id} a", "Edit") |> render_click() =~
               "Edit Admin"

      assert_patch(index_live, Routes.admin_index_path(conn, :edit, admin))

      assert index_live
             |> form("#admin-form", admin: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#admin-form", admin: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.admin_index_path(conn, :index))

      assert html =~ "Admin updated successfully"
    end

    test "deletes admin in listing", %{conn: conn, admin: admin} do
      {:ok, index_live, _html} = live(conn, Routes.admin_index_path(conn, :index))

      assert index_live |> element("#admin-#{admin.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#admin-#{admin.id}")
    end
  end

  describe "Show" do
    setup [:create_admin]

    test "displays admin", %{conn: conn, admin: admin} do
      {:ok, _show_live, html} = live(conn, Routes.admin_show_path(conn, :show, admin))

      assert html =~ "Show Admin"
    end

    test "updates admin within modal", %{conn: conn, admin: admin} do
      {:ok, show_live, _html} = live(conn, Routes.admin_show_path(conn, :show, admin))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Admin"

      assert_patch(show_live, Routes.admin_show_path(conn, :edit, admin))

      assert show_live
             |> form("#admin-form", admin: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#admin-form", admin: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.admin_show_path(conn, :show, admin))

      assert html =~ "Admin updated successfully"
    end
  end
end
