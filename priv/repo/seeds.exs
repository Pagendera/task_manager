alias TaskManager.Repo
alias TaskManager.Tasks.Task

for num <- 1..7 do
  title = "Task#{num}"

  unless Repo.get_by(Task, title: title) do
    Repo.insert!(%Task{
      title: title,
      description: title
    })
  end
end
