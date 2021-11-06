defmodule KomplenWeb.ComplaintController do
  use KomplenWeb, :controller

  alias Komplen.Complaints
  alias Komplen.Complaints.Complaint

  def index(conn, _params) do
    complaints = Complaints.list_complaints()
    render(conn, "index.html", complaints: complaints)
  end

  def new(conn, _params) do
    changeset = Complaints.change_complaint(%Complaint{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"complaint" => complaint_params}) do
    user =
      conn
      |> get_session("user")

    case Complaints.create_complaint(Map.put(complaint_params, "user", user)) do
      {:ok, complaint} ->
        conn
        |> put_flash(:info, "Complaint created successfully.")
        |> redirect(to: Routes.complaint_path(conn, :show, complaint))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    complaint = Complaints.get_complaint!(id)
    vouch = Complaints.get_vouch_by_complaint_id(complaint.id)

    case vouch do
      nil ->
        render(conn, "show.html", complaint: complaint, vouch_id: nil)

      vouch = vouch ->
        render(conn, "show.html", complaint: complaint, vouch_id: vouch.id)
    end
  end

  # I think it's safe to not check for user id here
  # because it is only available from the session
  def edit(conn, %{"id" => id}) do
    complaint = Complaints.get_complaint!(id)
    changeset = Complaints.change_complaint(complaint)
    render(conn, "edit.html", complaint: complaint, changeset: changeset)
  end

  # I think it's safe to not check for user id here
  # because it is only available from the session
  def update(conn, %{"id" => id, "complaint" => complaint_params}) do
    complaint = Complaints.get_complaint!(id)

    case Complaints.update_complaint(complaint, complaint_params) do
      {:ok, complaint} ->
        conn
        |> put_flash(:info, "Complaint updated successfully.")
        |> redirect(to: Routes.complaint_path(conn, :show, complaint))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", complaint: complaint, changeset: changeset)
    end
  end

  # I think it's safe to not check for user id here
  # because it is only available from the session
  def delete(conn, %{"id" => id}) do
    complaint = Complaints.get_complaint!(id)
    {:ok, _complaint} = Complaints.delete_complaint(complaint)

    conn
    |> put_flash(:info, "Complaint deleted successfully.")
    |> redirect(to: Routes.complaint_path(conn, :index))
  end
end
