defmodule TaskManagerWeb.HomeLive do
  use TaskManagerWeb, :surface_live_view
  require Logger

  alias Moon.Design.{
    Table,
    Table.Column,
    Button,
    Button.IconButton,
    Form,
    Form.Field,
    Form.Input,
    Form.TextArea,
    Modal,
    Drawer
  }

  alias TaskManager.Tasks

  data(create_modal_open, :boolean, default: false)
  data(del_modal_open, :boolean, default: false)
  data(drawer_info_open, :boolean, default: false)
  data(selected_task, :any, default: %{id: "", title: "", description: "", status: ""})
  data(form_create, :any, default: Tasks.change_task() |> to_form())
  def mount(_params, _session, socket) do

    {
      :ok,
      socket
      |> assign(
        tasks: Tasks.list_tasks() |> Enum.map(&(Map.from_struct(&1)))
      )
    }
  end

  def handle_info(:clear_flash, socket) do
    {:noreply, clear_flash(socket)}
  end

  def handle_event("do_nothing", _, socket) do
    {:noreply, socket}
  end

  def handle_event("modal_create_open", _, socket) do
    Modal.open("modal_create")

    {:noreply,
      socket
      |> assign(
        create_modal_open: true)
    }
  end

  def handle_event("modal_create_close", _, socket) do
    Modal.close("modal_create")

    {:noreply,
      socket
      |> assign(
        create_modal_open: false)
    }
  end

  def handle_event("create", %{"task" => task_params}, socket) do
    case Tasks.create_task(task_params) do
      {:ok, _task} ->
        Modal.close("modal_create")
        Process.send_after(self(), :clear_flash, 3000)

        {:noreply,
         socket
         |> assign(
            tasks: Tasks.list_tasks() |> Enum.map(&Map.from_struct(&1)),
            create_modal_open: false)
         |> put_flash(:info, "Task Created!")
        }

      {:error, changeset} ->
        {:noreply, socket |> assign(form_create: to_form(changeset))}
    end
  end

  def handle_event("validate_create", %{"task" => task_attrs}, socket) do
    form = validate_form(task_attrs)

    {:noreply,
     assign(socket,
       form_create: form
     )}
  end

  def handle_event("drawer_info_open", %{"value" => selected}, socket) do
    Drawer.open("drawer_info")

    {:noreply,
     assign(socket,
       selected_task: Tasks.get_task(selected) |> Map.from_struct(),
       drawer_info_open: true
     )}
  end

  def handle_event("drawer_info_close", _, socket) do
    Drawer.close("drawer_info")
    {:noreply,
      assign(socket,
        drawer_info_open: false,
        selected_task: %{id: "", title: "", description: "", status: ""}
      )}
  end

  def handle_event("modal_del_open", %{"value" => task_id}, socket) do
    Modal.open("modal_delete")

    {:noreply,
      socket
      |> assign(
        del_modal_open: true,
        selected_task: Tasks.get_task(task_id) |> Map.from_struct()
      )
    }
  end

  def handle_event("modal_del_close", _, socket) do
    Modal.close("modal_delete")

    {:noreply,
      socket
      |> assign(
        del_modal_open: false,
        selected_task: %{id: "", title: "", description: "", status: ""}
      )
    }
  end

  def handle_event("delete", %{"value" => task_id}, socket) do
    Process.send_after(self(), :clear_flash, 3000)
    Modal.close("modal_delete")

    case Tasks.delete_task(task_id) do
      {:ok, _} ->
        {:noreply,
          assign(socket,
            tasks: Tasks.list_tasks() |> Enum.map(&Map.from_struct(&1)),
            del_modal_open: false
          ) |> put_flash(:info, "Task Deleted!")
        }
      {:error, :not_found} ->
        {:noreply, put_flash(socket, :error, "Task not found")}
    end
  end

  defp validate_form(task_attrs) do
    Tasks.change_task(task_attrs)
    |> Map.put(:action, :insert)
    |> to_form()
  end
end
