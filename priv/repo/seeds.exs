alias TaskManager.Repo
alias TaskManager.Tasks.Task

for num <- 1..7 do
  Repo.insert(%Task{
    title: "Task#{num}",
    description: "Task#{num}",
    status: "pending"
  })
end
