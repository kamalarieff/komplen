defmodule Komplen.Complaints do
  @moduledoc """
  The Complaints context.
  """
  require Logger

  import Ecto.Query, warn: false
  alias Komplen.Repo

  alias Komplen.Complaints.Complaint

  @doc """
  Returns the list of complaints.

  ## Examples

      iex> list_complaints()
      [%Complaint{}, ...]

  """
  def list_complaints do
    Complaint
    |> Repo.all()
    |> Repo.preload(:user)
  end

  @doc """
  Gets a single complaint.

  Raises `Ecto.NoResultsError` if the Complaint does not exist.

  ## Examples

      iex> get_complaint!(123)
      %Complaint{}

      iex> get_complaint!(456)
      ** (Ecto.NoResultsError)

  """
  def get_complaint!(id) do
    Complaint
    |> Repo.get!(id)
    |> Repo.preload(:user)
    |> Repo.preload(:room)
  end

  @doc """
  Creates a complaint.

  ## Examples

      iex> create_complaint(%{field: value})
      {:ok, %Complaint{}}

      iex> create_complaint(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  # Pattern matching in a function definition
  # https://elixirforum.com/t/get-specific-key-and-the-rest-of-map-with-pattern-matching-in-elixir/14553/4
  # Note that this is a different way to pass the user to the complaint changeset
  # See the different way used in admin. admin accepts two params
  # I still can't get the hang of pattern matching. Need more time to understand this
  # The tests are the only one that is failing. Otherwise, it is perfect
  # Maybe you can check out the Elixir in action book
  # The code was sending the keys as strings but the test was sending it as atoms
  # I think you can delete this default params because it doesn't make sense
  def create_complaint(attrs = %{"user_id" => user_id} \\ %{}) do
    # def create_complaint(attrs \\ %{}) do
    # %Complaint{}
    %Complaint{user_id: user_id}
    |> Complaint.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a complaint.

  ## Examples

      iex> update_complaint(complaint, %{field: new_value})
      {:ok, %Complaint{}}

      iex> update_complaint(complaint, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_complaint(%Complaint{} = complaint, attrs) do
    complaint
    |> Complaint.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a complaint.

  ## Examples

      iex> delete_complaint(complaint)
      {:ok, %Complaint{}}

      iex> delete_complaint(complaint)
      {:error, %Ecto.Changeset{}}

  """
  def delete_complaint(%Complaint{} = complaint) do
    Repo.delete(complaint)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking complaint changes.

  ## Examples

      iex> change_complaint(complaint)
      %Ecto.Changeset{data: %Complaint{}}

  """
  def change_complaint(%Complaint{} = complaint, attrs \\ %{}) do
    Complaint.changeset(complaint, attrs)
  end

  @doc """
  Search for complaints based on search term

  ## Examples

      iex> search_complaints("test")
      [%Complaint{}, %Complaint{}, ...]

      iex> search_complaints("not existing")
      []

  """
  def search_complaints(term) do
    query = from c in Complaint, where: c.title == ^term
    Repo.all(query)
    |> Repo.preload(:user)
  end

  alias Komplen.Complaints.Vouch

  @doc """
  Gets a single vouch.

  Raises `Ecto.NoResultsError` if the Vouch does not exist.

  ## Examples

      iex> get_vouch!(123)
      %Vouch{}

      iex> get_vouch!(456)
      ** (Ecto.NoResultsError)

  """
  def get_vouch!(id), do: Repo.get!(Vouch, id)

  @doc """
  Gets a single vouch via complaint id and user_id.

  ## Examples

      iex> get_vouch([{:complaint_id, 1}, {:user_id, 1}])
      %Vouch{}

      iex> get_vouch([{:complaint_id, -1}, {:user_id, -1}])
      nil

  Gets a single vouch via user_id.

  ## Examples

      iex> get_vouch({:user_id, 1})
      %Vouch{}

      iex> get_vouch({:user_id, -1})
      nil

  """
  def get_vouch([{:complaint_id, complaint_id = complaint_id}, {:user_id, user_id = user_id}]) do
    query = from v in Vouch, where: v.complaint_id == ^complaint_id and v.user_id == ^user_id
    Repo.one(query)
  end

  def get_vouch({:user_id, id = id}) do
    Repo.get_by(Vouch, user_id: id)
  end

  @doc """
  Returns the list of vouches via complaint_id.

  ## Examples

      iex> list_vouches1({:complaint_id, 1})
      [%Vouch{}, ...]

  Returns the list of vouches.

  ## Examples

      iex> list_vouches()
      [%Vouch{}, ...]

  """
  def list_vouches({:complaint_id, id = id}) do
    query = from v in Vouch, where: v.complaint_id == ^id
    Repo.all(query)
  end

  def list_vouches do
    Repo.all(Vouch)
  end

  @doc """
  Creates a vouch.

  ## Examples

      iex> add_vouch(%{field: value})
      {:ok, %Vouch{}}

      iex> add_vouch(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def add_vouch(attrs \\ %{}) do
    try do
      %Vouch{}
      |> Vouch.changeset(attrs)
      |> Repo.insert()
    rescue
      e ->
        Logger.error(Exception.format(:error, e, __STACKTRACE__))
        {:error, %Ecto.Changeset{}}
    end
  end

  @doc """
  Deletes a vouch.

  ## Examples

      iex> remove_vouch(vouch)
      {:ok, %Vouch{}}

      iex> remove_vouch(vouch)
      {:error, %Ecto.Changeset{}}

  """
  def remove_vouch(%Vouch{} = vouch) do
    Repo.delete(vouch)
  end
end
