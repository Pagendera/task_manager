defmodule TaskManagerWeb.HomeLive do
  use TaskManagerWeb, :surface_live_view
  require Logger

  def mount(_params, _session, socket) do

    {:ok,socket}
  end
end
