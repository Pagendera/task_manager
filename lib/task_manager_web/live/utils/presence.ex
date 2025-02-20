defmodule TaskManagerWeb.Utils.Presence do
  use Phoenix.Presence,
    otp_app: :task_manager,
    pubsub_server: TaskManager.PubSub
end
