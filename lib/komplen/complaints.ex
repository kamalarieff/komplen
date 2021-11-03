defmodule Komplen.Complaints do
  @moduledoc """
  The Complaints context.
  """

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
  def create_complaint(attrs = %{"user" => user} \\ %{}) do
    # def create_complaint(attrs \\ %{}) do
    # %Complaint{}
    %Complaint{user_id: user.id}
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
end
