defmodule TaskManager.TasksFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TaskManager.Tasks` context.
  """

  @doc """
  Generate a task.
  """
  def task_fixture(attrs \\ %{}) do
    title = Map.get(attrs, :title) || "some title #{System.unique_integer()}"

    {:ok, task} =
      attrs
      |> Enum.into(%{
        description: "some description",
        title: title
      })
      |> TaskManager.Tasks.create_task()

    task
  end

  def create_tasks_fixture(attrs \\ %{}) do
    number = Map.get(attrs, :number) || 10

    for i <- 1..number do
      task_fixture(%{title: "some title #{i}"})
    end
  end
end
