defmodule TaskManagerWeb.HomeLiveTest do
  use TaskManagerWeb.ConnCase
  import Phoenix.LiveViewTest

  setup :register_and_log_in_user

  describe "mount" do
    test "initializes with default values", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/")

      assert view |> element("h1", "Task Manager") |> has_element?()
      assert view |> element("button", "Add New Task") |> has_element?()
      assert view |> element("table") |> has_element?()
    end

    test "displays user email and online users count", %{conn: conn, user: user} do
      {:ok, view, _html} = live(conn, "/")

      assert view |> element("p", user.email) |> has_element?()
      assert view |> element("p", "Users online: 1") |> has_element?()
    end
  end

  describe "task creation" do
    test "can open and close create modal", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/")

      view |> element("button", "Add New Task") |> render_click()
      assert view |> element("#modal_create") |> has_element?()

      view |> element("button[phx-click='modal_create_close']", "Cancel") |> render_click()
      refute view |> element("#modal_create.open") |> has_element?()
    end

    test "creates a new task successfully", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/")

      view |> element("button", "Add New Task") |> render_click()

      create_form = view
      |> element("form[phx-submit='create']")

      attrs = %{title: "Test Task", description: "Test Description"}
      create_form
      |> render_submit(%{task: attrs})

      html = render(view)
      assert html =~ attrs.title
      assert view |> element("p", "Task Created!") |> has_element?()
    end

    test "shows error for invalid task", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/")

      view |> element("button", "Add New Task") |> render_click()

      view
      |> element("form[phx-submit='create']")
      |> render_submit(%{task: %{title: "", description: ""}})

      assert view |> element("span", "can't be blank") |> has_element?()
    end
  end

  describe "task update" do
    test "can view and update task details", %{conn: conn} do
      {:ok, _task} = TaskManager.Tasks.create_task(%{title: "Original Title", description: "Original Desc"})
      {:ok, view, _html} = live(conn, "/")

      view |> element("button[phx-click=\"drawer_info_open\"]") |> render_click()
      assert view |> element("#drawer_info") |> has_element?()

      view |> element("button[phx-click=\"modal_upd_open\"]", "Edit") |> render_click()
      assert view |> element("#modal_update") |> has_element?()

      updated_attrs = %{title: "Updated Title", description: "Updated Desc"}
      view
      |> element("form[phx-submit='update']")
      |> render_submit(%{task: updated_attrs})

      html = render(view)
      assert html =~ updated_attrs.title
      assert view |> element("p", "Task Updated!") |> has_element?()
      assert view |> element("td", "Updated Title") |> has_element?()
    end

    test "can close update modal", %{conn: conn} do
      {:ok, _task} = TaskManager.Tasks.create_task(%{title: "Test Task", description: "Test Description"})
      {:ok, view, _html} = live(conn, "/")

      assert view |> element("td", "Test Task") |> has_element?()
      view |> element("button[phx-click=\"drawer_info_open\"]") |> render_click()
      view |> element("button[phx-click=\"modal_upd_open\"]", "Edit") |> render_click()

      view |> element("button[phx-click='modal_upd_close']", "Cancel") |> render_click()
      assert view |> element("td", "Test Task") |> has_element?()
    end
  end

  describe "task deletion" do
    test "can delete a task", %{conn: conn} do
      {:ok, _task} = TaskManager.Tasks.create_task(%{title: "To Delete", description: "Will be deleted"})
      {:ok, view, _html} = live(conn, "/")

      view
      |> element("button[phx-click=\"modal_del_open\"]")
      |> render_click()

      assert view |> element("#modal_delete") |> has_element?()

      view
      |> element("button[phx-click=\"delete\"]")
      |> render_click()

      refute view |> element("td", "To Delete") |> has_element?()
      assert view |> element("p", "Task Deleted!") |> has_element?()
    end

    test "can close delete modal", %{conn: conn} do
      {:ok, _task} = TaskManager.Tasks.create_task(%{title: "Test Task", description: "Test Description"})
      {:ok, view, _html} = live(conn, "/")

      view
      |> element("button[phx-click=\"modal_del_open\"]")
      |> render_click()

      view |> element("button[phx-click='modal_del_close']", "Cancel") |> render_click()
      assert view |> element("td", "Test Task") |> has_element?()
    end
  end

  describe "presence tracking" do
    test "updates users count when users connect/disconnect", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/")
      assert render(view) =~ "Users online: 1"

      {:ok, user2} = TaskManager.Users.register_user(%{
        email: "user2@example.com",
        password: "password123",
        password_confirmation: "password123"
      })
      conn2 = build_conn() |> log_in_user(user2)
      {:ok, _view2, _html} = live(conn2, "/")

      assert render(view) =~ "Users online: 2"
    end
  end
end
