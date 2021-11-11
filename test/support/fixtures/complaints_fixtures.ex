defmodule Komplen.ComplaintsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Komplen.Complaints` context.
  """

  @doc """
  Generate a complaint.
  """
  def complaint_fixture(attrs \\ %{}) do
    {:ok, complaint} =
      attrs
      |> Enum.into(%{

      })
      |> Komplen.Complaints.create_complaint()

    complaint
  end
end
