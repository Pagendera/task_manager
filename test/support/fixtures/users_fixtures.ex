defmodule TaskManager.UsersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TaskManager.Users` context.
  """

  @doc """
  Generate a user with given attributes.
  """
  def user_fixture(attrs \\ %{}) do
    email = Map.get(attrs, :email) || "test@example.com"
    password = Map.get(attrs, :password) || "password123"

    {:ok, user} =
      attrs
      |> Enum.into(%{
        email: email,
        password: password,
        password_confirmation: password
      })
      |> TaskManager.Users.register_user()

    user
  end

  def unique_user_email, do: "user#{System.unique_integer()}@example.com"
  def valid_user_password, do: "hello world!"
  
  def valid_user_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      email: unique_user_email(),
      password: valid_user_password()
    })
  end
end
