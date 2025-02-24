defmodule TaskManager.Tasks do

  import Ecto.Query, warn: false
  alias TaskManager.Repo

  alias TaskManager.Tasks.Task

  def list_tasks(filters \\ %{}) do
    Task
    |> filter_by_status(filters["status"])
    |> order_by([t], desc: t.status)
    |> Repo.all()
  end

  def get_task(id) do
    Repo.get(Task, id)
  end

  def create_task(attrs) do
    %Task{}
    |> Task.changeset(attrs)
    |> Repo.insert()
  end

  def delete_task(id) do
    id
    |> get_task()
    |> case do
      nil -> {:error, :not_found}
      task -> Repo.delete(task)
    end
  end

  def update_task(%Task{} = task, attrs) do
    task
    |> Task.changeset(attrs)
    |> Repo.update()
  end

  def change_task(attrs \\ %{}) do
    %Task{}
    |> Task.changeset(attrs)
  end

  defp filter_by_status(query, nil), do: query
  defp filter_by_status(query, "All"), do: query
  defp filter_by_status(query, status), do: query |> where([t], t.status == ^status)
end
