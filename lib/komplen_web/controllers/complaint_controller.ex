defmodule KomplenWeb.ComplaintController do
  use KomplenWeb, :controller

  alias Komplen.Accounts
  alias Komplen.Complaints
  alias Komplen.Complaints.Complaint

  def index(conn, _params) do
    complaints = Complaints.list_complaints()
    render(conn, "index.html", complaints: complaints)
  end

  def new(conn, _params) do
    name =
      conn
      |> get_session("name")

    case Accounts.authenticate_by_name(name) do
      {:ok, _} ->
        changeset = Complaints.change_complaint(%Complaint{})
        render(conn, "new.html", changeset: changeset)

      {:error, _} ->
        conn
        |> put_flash(:error, "Unauthorized")
        |> redirect(to: Routes.session_path(conn, :new))
    end
  end

  def create(conn, %{"complaint" => complaint_params}) do
    case Complaints.create_complaint(complaint_params) do
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
    render(conn, "show.html", complaint: complaint)
  end

  def edit(conn, %{"id" => id}) do
    complaint = Complaints.get_complaint!(id)
    changeset = Complaints.change_complaint(complaint)
    render(conn, "edit.html", complaint: complaint, changeset: changeset)
  end

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

  def delete(conn, %{"id" => id}) do
    complaint = Complaints.get_complaint!(id)
    {:ok, _complaint} = Complaints.delete_complaint(complaint)

    conn
    |> put_flash(:info, "Complaint deleted successfully.")
    |> redirect(to: Routes.complaint_path(conn, :index))
  end
end
