defmodule TaskManager.Tasks.Task do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tasks" do
    field :title, :string
    field :description, :string
    field :status, StatusEnum, default: :pending

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(task, attrs) do
    task
    |> cast(attrs, [:title, :description, :status])
    |> validate_required([:title])
    |> unique_constraint(:title)
    |> put_default_status()
  end

  defp put_default_status(changeset) do
    case get_change(changeset, :status) do
      nil -> put_change(changeset, :status, :pending)
      _ -> changeset
    end
  end
end
