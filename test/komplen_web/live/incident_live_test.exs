defmodule KomplenWeb.IncidentLiveTest do
  use KomplenWeb.ConnCase

  import Phoenix.LiveViewTest
  import Komplen.ComplaintsFixtures

  @create_attrs %{title: "some title"}
  @update_attrs %{title: "some updated title"}
  @invalid_attrs %{title: nil}

  defp create_incident(_) do
    incident = incident_fixture()
    %{incident: incident}
  end

  describe "Index" do
    setup [:create_incident]

    test "lists all incidents", %{conn: conn, incident: incident} do
      {:ok, _index_live, html} = live(conn, Routes.incident_index_path(conn, :index))

      assert html =~ "Listing Incidents"
      assert html =~ incident.title
    end

    test "saves new incident", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.incident_index_path(conn, :index))

      assert index_live |> element("a", "New Incident") |> render_click() =~
               "New Incident"

      assert_patch(index_live, Routes.incident_index_path(conn, :new))

      assert index_live
             |> form("#incident-form", incident: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#incident-form", incident: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.incident_index_path(conn, :index))

      assert html =~ "Incident created successfully"
      assert html =~ "some title"
    end

    test "updates incident in listing", %{conn: conn, incident: incident} do
      {:ok, index_live, _html} = live(conn, Routes.incident_index_path(conn, :index))

      assert index_live |> element("#incident-#{incident.id} a", "Edit") |> render_click() =~
               "Edit Incident"

      assert_patch(index_live, Routes.incident_index_path(conn, :edit, incident))

      assert index_live
             |> form("#incident-form", incident: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#incident-form", incident: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.incident_index_path(conn, :index))

      assert html =~ "Incident updated successfully"
      assert html =~ "some updated title"
    end

    test "deletes incident in listing", %{conn: conn, incident: incident} do
      {:ok, index_live, _html} = live(conn, Routes.incident_index_path(conn, :index))

      assert index_live |> element("#incident-#{incident.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#incident-#{incident.id}")
    end
  end

  describe "Show" do
    setup [:create_incident]

    test "displays incident", %{conn: conn, incident: incident} do
      {:ok, _show_live, html} = live(conn, Routes.incident_show_path(conn, :show, incident))

      assert html =~ "Show Incident"
      assert html =~ incident.title
    end

    test "updates incident within modal", %{conn: conn, incident: incident} do
      {:ok, show_live, _html} = live(conn, Routes.incident_show_path(conn, :show, incident))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Incident"

      assert_patch(show_live, Routes.incident_show_path(conn, :edit, incident))

      assert show_live
             |> form("#incident-form", incident: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#incident-form", incident: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.incident_show_path(conn, :show, incident))

      assert html =~ "Incident updated successfully"
      assert html =~ "some updated title"
    end
  end
end
