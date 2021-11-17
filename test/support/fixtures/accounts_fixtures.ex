defmodule Komplen.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Komplen.Complaints` context.
  """

  @doc """
  Generate a user.
  """
  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{})
      |> Komplen.Accounts.create_user()

    user
  end

  @doc """
  Generate a admin.
  """
  def admin_fixture(attrs \\ %{}) do
    user = user_fixture(%{"username" => "some username"})
    {:ok, admin} =
      attrs
      |> Enum.into(%{})
      |> then(&Komplen.Accounts.create_admin(user, &1))

    admin
  end
end
