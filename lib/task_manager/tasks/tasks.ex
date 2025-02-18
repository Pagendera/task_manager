defmodule TaskManager.Tasks do

  import Ecto.Query, warn: false
  alias TaskManager.Repo

  alias TaskManager.Tasks.Task

  def list_tasks(filters \\ %{}) do
    Task
    |> filter_by_status(filters["status"])
    |> Repo.all()
  end

  defp filter_by_status(query, nil), do: query
  defp filter_by_status(query, status), do: query |> where([t], t.status == ^status)
end
