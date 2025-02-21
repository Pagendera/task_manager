defmodule TaskManager.TasksTest do
  use TaskManager.DataCase

  alias TaskManager.Tasks
  import TaskManager.TasksFixtures

  describe "list_tasks/1" do
    test "returns all tasks" do
      task = task_fixture()
      assert [task] == Tasks.list_tasks()
    end

    test "filters tasks by status" do
      task_fixture(%{status: "pending"})
      task_fixture(%{status: "completed"})
      assert [%{status: :pending}] = Tasks.list_tasks(%{"status" => "pending"})
    end
  end

  describe "get_task/1" do
    test "returns the task if it exists" do
      task = task_fixture()
      assert Tasks.get_task(task.id) == task
    end

    test "returns nil if task does not exist" do
      assert Tasks.get_task(-1) == nil
    end
  end

  describe "create_task/1" do
    test "creates a task with valid attributes" do
      assert {:ok, task} = Tasks.create_task(%{title: "New Task", description: "Task desc"})
      assert task.title == "New Task"
    end

    test "returns error changeset with invalid attributes" do
      assert {:error, _changeset} = Tasks.create_task(%{title: nil})
    end
  end

  describe "update_task/2" do
    test "updates the task with valid attributes" do
      task = task_fixture()
      assert {:ok, updated_task} = Tasks.update_task(task, %{title: "Updated Task"})
      assert updated_task.title == "Updated Task"
    end
  end

  describe "delete_task/1" do
    test "deletes the task if it exists" do
      task = task_fixture()
      assert {:ok, _} = Tasks.delete_task(task.id)
      assert Tasks.get_task(task.id) == nil
    end

    test "returns error if task does not exist" do
      assert {:error, :not_found} = Tasks.delete_task(-1)
    end
  end
end
