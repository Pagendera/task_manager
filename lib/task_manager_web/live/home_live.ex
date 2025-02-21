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
    Drawer,
    Dropdown
  }

  alias TaskManager.{Tasks, Users}
  alias TaskManagerWeb.Utils.Presence

  data(create_modal_open, :boolean, default: false)
  data(upd_modal_open, :boolean, default: false)
  data(del_modal_open, :boolean, default: false)
  data(drawer_info_open, :boolean, default: false)
  data(status_filter, :string, default: "All")
  data(selected_task, :any, default: %{id: "", title: "", description: "", status: ""})
  data(form_create, :any, default: Tasks.change_task() |> to_form())
  data(form_update, :any, default: Tasks.change_task() |> to_form())
  def mount(_params, session, socket) do

    if connected?(socket) do
      user = Users.get_user_by_session_token(session["user_token"])
      Presence.track(self(), "users", user.id, %{})
      Phoenix.PubSub.subscribe(TaskManager.PubSub, "tasks")
      Phoenix.PubSub.subscribe(TaskManager.PubSub, "users")
    end

    users_online = Presence.list("users") |> map_size()

    {
      :ok,
      socket
      |> assign(
        tasks: Tasks.list_tasks() |> Enum.map(&(Map.from_struct(&1))),
        current_user: Users.get_user_by_session_token(session["user_token"]),
        users_online: users_online
      )
    }
  end

  def handle_info({:task_list_changed}, socket) do
    {:noreply, assign(socket, tasks: Tasks.list_tasks(%{"status" => socket.assigns.status_filter}) |> Enum.map(&Map.from_struct(&1)))}
  end

  def handle_info(%{event: "presence_diff", topic: topic}, socket) do
    users_online = Presence.list(topic) |> map_size()
    {:noreply, assign(socket, users_online: users_online)}
  end

  def handle_info(:clear_flash, socket) do
    {:noreply, clear_flash(socket)}
  end

  def handle_event("do_nothing", _, socket) do
    {:noreply, socket}
  end

  def handle_event("on_change_status_filter", %{"value" => status_filter}, socket) do
    Dropdown.close("status_dropdown")

    tasks = Tasks.list_tasks(%{"status" => status_filter})

    {:noreply,
      socket
      |> assign(
        status_filter: status_filter,
        tasks: tasks |> Enum.map(&Map.from_struct(&1))
        )
    }
  end

  def handle_event("modal_create_open", _, socket) do
    Modal.open("modal_create")

    {:noreply,
      socket
      |> assign(
        create_modal_open: true
        )
    }
  end

  def handle_event("modal_create_close", _, socket) do
    Modal.close("modal_create")

    {:noreply,
      socket
      |> assign(
        create_modal_open: false,
        form_create: Tasks.change_task() |> to_form()
      )
    }
  end

  def handle_event("create", %{"task" => task_params}, socket) do
    case Tasks.create_task(task_params) do
      {:ok, _task} ->
        Phoenix.PubSub.broadcast(TaskManager.PubSub, "tasks", {:task_list_changed})
        Modal.close("modal_create")
        Process.send_after(self(), :clear_flash, 3000)

        {:noreply,
         socket
         |> assign(
            tasks: Tasks.list_tasks(%{"status" => socket.assigns.status_filter}) |> Enum.map(&Map.from_struct(&1)),
            create_modal_open: false,
            form_create: Tasks.change_task() |> to_form())
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
        Phoenix.PubSub.broadcast(TaskManager.PubSub, "tasks", {:task_list_changed})
        {:noreply,
          assign(socket,
            tasks: Tasks.list_tasks(%{"status" => socket.assigns.status_filter}) |> Enum.map(&Map.from_struct(&1)),
            del_modal_open: false
          ) |> put_flash(:info, "Task Deleted!")
        }
      {:error, :not_found} ->
        {:noreply, put_flash(socket, :error, "Task not found")}
    end
  end

  def handle_event("change_status", %{"id" => task_id, "status" => status}, socket) do
    new_status =
      if status == "pending" do
        "completed"
      else
        "pending"
      end

    task = Tasks.get_task(task_id)

    case Tasks.update_task(task, %{"status" => new_status}) do
      {:ok, _updated_task} ->
        Phoenix.PubSub.broadcast(TaskManager.PubSub, "tasks", {:task_list_changed})
        {:noreply, assign(socket, tasks: Tasks.list_tasks(%{"status" => socket.assigns.status_filter}) |> Enum.map(&Map.from_struct/1))}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Error updating task status")}
    end
  end

  def handle_event("modal_upd_open", _, socket) do
    Modal.open("modal_update")

    {:noreply,
      socket
      |> assign(
        upd_modal_open: true,
        form_update: Tasks.change_task(socket.assigns.selected_task) |> to_form
        )
    }
  end

  def handle_event("modal_upd_close", _, socket) do
    Modal.close("modal_update")

    {:noreply,
      socket
      |> assign(
        upd_modal_open: false,
        form_update: Tasks.change_task() |> to_form()
      )
    }
  end

  def handle_event("update", %{"task" => task_params}, socket) do
    task = Tasks.get_task(socket.assigns.selected_task.id)

    case Tasks.update_task(task, task_params) do
      {:ok, updated_task} ->
        Phoenix.PubSub.broadcast(TaskManager.PubSub, "tasks", {:task_list_changed})
        Modal.close("modal_update")
        Process.send_after(self(), :clear_flash, 3000)
        {:noreply,
         socket
         |> assign(
              tasks: Tasks.list_tasks(%{"status" => socket.assigns.status_filter}) |> Enum.map(&Map.from_struct/1),
              upd_modal_open: false,
              selected_task: updated_task |> Map.from_struct()
            )
         |> put_flash(:info, "Task Updated!")}

      {:error, changeset} ->
        {:noreply, assign(socket, form_update: to_form(changeset))}
    end
  end

  def handle_event("validate_update", %{"task" => task_attrs}, socket) do
    form = validate_form(task_attrs)

    {:noreply,
     assign(socket,
       form_update: form
     )}
  end

  defp validate_form(task_attrs) do
    Tasks.change_task(task_attrs)
    |> Map.put(:action, :insert)
    |> to_form()
  end
end
