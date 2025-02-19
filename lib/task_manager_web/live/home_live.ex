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
    Modal
  }

  alias TaskManager.Tasks

  data(create_modal_open, :boolean, default: false)
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

  defp validate_form(task_attrs) do
    Tasks.change_task(task_attrs)
    |> Map.put(:action, :insert)
    |> to_form()
  end
end
