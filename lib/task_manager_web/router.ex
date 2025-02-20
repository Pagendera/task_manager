defmodule TaskManagerWeb.Router do
  use TaskManagerWeb, :router

  import TaskManagerWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {TaskManagerWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  scope "/", TaskManagerWeb do
    pipe_through [:browser, :require_authenticated_user]

    live "/", HomeLive, :home
  end

  scope "/", TaskManagerWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{TaskManagerWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/users/register", UserRegistrationLive, :new
      live "/users/log_in", UserLoginLive, :new
    end

    post "/users/log_in", UserSessionController, :create
  end

  scope "/", TaskManagerWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete
  end
end
