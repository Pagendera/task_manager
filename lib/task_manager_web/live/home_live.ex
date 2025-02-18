defmodule TaskManagerWeb.HomeLive do
  use TaskManagerWeb, :surface_live_view
  require Logger

  alias Moon.Design.{
    Table,
    Table.Column,
  }

  alias TaskManager.Tasks

  def mount(_params, _session, socket) do

    {
      :ok,
      socket
      |> assign(
        tasks: Tasks.list_tasks() |> Enum.map(&(Map.from_struct(&1)))
      )
    }
  end
end
