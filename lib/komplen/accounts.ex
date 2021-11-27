defmodule Komplen.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Komplen.Repo

  alias Komplen.Accounts.User
  alias Komplen.Accounts

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
    |> Repo.preload(:admin)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id) |> Repo.preload(:admin)

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end

  alias Komplen.Accounts.Admin

  @doc """
  Returns the list of admins.

  ## Examples

      iex> list_admins()
      [%Admin{}, ...]

  """
  def list_admins do
    Admin
    |> Repo.all()
    |> Repo.preload(:user)
  end

  @doc """
  Gets a single admin.

  Raises `Ecto.NoResultsError` if the Admin does not exist.

  ## Examples

      iex> get_admin!(123)
      %Admin{}

      iex> get_admin!(456)
      ** (Ecto.NoResultsError)

  """
  def get_admin!(id) do
    Admin
    |> Repo.get!(id)
    |> Repo.preload(:user)
  end

  @doc """
  Creates a admin.

  ## Examples

      iex> create_admin(%Account.User{}, %{field: value})
      {:ok, %Admin{}}

      iex> create_admin(%Account.User{}, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_admin(%Accounts.User{} = user, attrs \\ %{}) do
    %Admin{user_id: user.id}
    |> Admin.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a admin.

  ## Examples

      iex> update_admin(admin, %{field: new_value})
      {:ok, %Admin{}}

      iex> update_admin(admin, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_admin(%Admin{} = admin, attrs) do
    admin
    |> Admin.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a admin.

  ## Examples

      iex> delete_admin(admin)
      {:ok, %Admin{}}

      iex> delete_admin(admin)
      {:error, %Ecto.Changeset{}}

  """
  def delete_admin(%Admin{} = admin) do
    Repo.delete(admin)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking admin changes.

  ## Examples

      iex> change_admin(admin)
      %Ecto.Changeset{data: %Admin{}}

  """
  def change_admin(%Admin{} = admin, attrs \\ %{}) do
    Admin.changeset(admin, attrs)
  end

  @doc """
  Check if user is an admin

  ## Examples

      iex> check_is_admin?(1) 
      true

      iex> check_is_admin?(2) 
      false

  """
  def check_is_admin?(user_id) do
    query = from a in Admin, where: a.user_id == ^user_id
    Repo.exists?(query)
  end

  @doc """
  Authenticate by username.

  ## Examples

      iex> authenticate_by_username("value") 
      {:ok, %User{}}

      iex> authenticate_by_username("bad value") 
      {:error, :unauthorized}

  """
  def authenticate_by_username(username) when is_nil(username) do
    {:error, :missing_name}
  end

  def authenticate_by_username(username) do
    query =
      from u in User,
        where: u.username == ^username

    case Repo.one(query) |> Repo.preload(:admin) do
      %User{} = user -> {:ok, user}
      nil -> {:error, :unauthorized}
    end
  end

  @doc """
  Authenticate by id.

  ## Examples

      iex> authenticate_by_id("value")
      {:ok, %User{}}

      iex> authenticate_by_id("bad value")
      {:error, :unauthorized}

  """
  def authenticate_by_id(id) when is_nil(id) do
    {:error, :missing_id}
  end

  def authenticate_by_id(id) do
    query =
      from u in User,
        where: u.id == ^id

    case Repo.one(query) do
      %User{} = user -> {:ok, user}
      nil -> {:error, :unauthorized}
    end
  end

  alias Komplen.Accounts.Profile

  @doc """
  Returns the list of profiles.

  ## Examples

      iex> list_profiles()
      [%Profile{}, ...]

  """
  def list_profiles do
    Repo.all(Profile)
  end

  @doc """
  Gets a single profile.

  ## Examples

      iex> get_profile(123)
      %Profile{}

      iex> get_profile(456)
      nil

  """
  def get_profile(%{user_id: user_id}), do: Repo.get_by(Profile, user_id: user_id)
  def get_profile(id), do: Repo.get(Profile, id)

  @doc """
  Creates a profile.

  ## Examples

      iex> create_profile(%{field: value})
      {:ok, %Profile{}}

      iex> create_profile(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_profile(attrs \\ %{}) do
    %Profile{}
    |> Profile.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a profile.

  ## Examples

      iex> update_profile(profile, %{field: new_value})
      {:ok, %Profile{}}

      iex> update_profile(profile, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_profile(%Profile{} = profile, attrs) do
    case Repo.get_by(Profile, user_id: profile.user_id) do
      # Profile not found, we build one
      nil -> %Profile{}
      # Profile exists, let's use it
      profile -> profile
    end
    |> Profile.changeset(attrs)
    |> Repo.insert_or_update()
  end

  @doc """
  Deletes a profile.

  ## Examples

      iex> delete_profile(profile)
      {:ok, %Profile{}}

      iex> delete_profile(profile)
      {:error, %Ecto.Changeset{}}

  """
  def delete_profile(%Profile{} = profile) do
    Repo.delete(profile)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking profile changes.

  ## Examples

      iex> change_profile(profile)
      %Ecto.Changeset{data: %Profile{}}

  """
  def change_profile(%Profile{} = profile, attrs \\ %{}) do
    Profile.changeset(profile, attrs)
  end
end
