# Task Manager
This project is a real-time task management application built with Phoenix LiveView. Users can create, update, delete, and track tasks collaboratively, with updates reflected instantly across all connected users.

## Features
* **Real-time Updates:** All changes to tasks (creation, update, deletion) are instantly reflected for all users without page reloads.

* **Task Management:**

  * Create new tasks with a title and optional description.
  
  * Mark tasks as completed.
  
  * Delete tasks with a confirmation dialog.
  
  * Edit tasks without reloading the page.

* **Persistent Storage:** Uses PostgreSQL with Ecto for task storage.

* **Filtering:** View tasks by status: "All Tasks," "Pending Tasks," and "Completed Tasks."

* **User Presence Tracking:** Displays the number of users currently viewing the task manager.

* **Authentication:** Uses Phoenix's built-in authentication system.

* **Responsive UI:** Designed with mobile-first principles using Tailwind CSS.

## Installation and Setup

1. **Clone the Repository**
2. **Run** `docker compose up -d` This will start the necessary database containers in the background.
3. **Run `mix setup` to install and setup dependencies**
4. **Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`**
5. **Use application through browser (use http://localhost:4000 endpoint)**
6. **Run `mix test` to run integration tests**

## Deployment

The application is deployed and accessible online at: https://task-manager-pariy.fly.dev/

## Preview

[task_manager_pariy.webm](https://github.com/user-attachments/assets/5e3d4a12-f554-487d-b8c7-e423f8af16b7)


## Notes

* Uses Phoenix Presence to track connected users.

* Implements LiveView hooks for interactive UI elements.

