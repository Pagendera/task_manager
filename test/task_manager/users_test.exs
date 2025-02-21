defmodule TaskManager.UsersTest do
  use TaskManager.DataCase
  import TaskManager.UsersFixtures

  alias TaskManager.Users
  alias TaskManager.Users.User

  describe "get_user_by_email/1" do
    test "returns the user by email" do
      user = user_fixture()
      assert Users.get_user_by_email(user.email) == user
    end

    test "returns nil if user with email does not exist" do
      assert Users.get_user_by_email("nonexistent@example.com") == nil
    end
  end

  describe "get_user_by_email_and_password/2" do
    test "returns the user when email and password match" do
      user = user_fixture(%{password: "password123"})
      assert Users.get_user_by_email_and_password(user.email, "password123") == user
    end

    test "returns nil when password is incorrect" do
      user = user_fixture(%{password: "password123"})
      assert Users.get_user_by_email_and_password(user.email, "wrongpassword") == nil
    end
  end

  describe "register_user/1" do
    test "creates a user with valid attributes" do
      assert {:ok, %User{} = user} = Users.register_user(%{email: "new@example.com", password: "password123", password_confirmation: "password123"})
      assert user.email == "new@example.com"
    end

    test "returns error with invalid attributes" do
      assert {:error, changeset} = Users.register_user(%{email: nil, password: "password123"})
      assert changeset.errors[:email]
    end
  end

  describe "generate_user_session_token/1" do
    test "generates a valid session token for the user" do
      user = user_fixture()
      token = Users.generate_user_session_token(user)
      assert is_binary(token)
    end
  end

  describe "get_user_by_session_token/1" do
    test "returns the user for a valid session token" do
      user = user_fixture()
      token = Users.generate_user_session_token(user)
      assert Users.get_user_by_session_token(token).id == user.id
    end

    test "returns nil for an invalid session token" do
      assert Users.get_user_by_session_token("invalid_token") == nil
    end
  end

  describe "delete_user_session_token/1" do
    test "deletes the user's session token" do
      user = user_fixture()
      token = Users.generate_user_session_token(user)
      assert :ok = Users.delete_user_session_token(token)
      assert Users.get_user_by_session_token(token) == nil
    end
  end
end
