class TasksController < ApplicationController

  #### standard CRUD actions

  def index
    @tasks = Task.all.order(sort: :asc)
  end

  def new
    @task = Task.new
  end

  def create
    task_count = Task.all.length
    Task.create title:params[:task][:title],sort: task_count
    redirect_to :tasks
  end

  def destroy
    Task.destroy params[:id]
    redirect_to :tasks
  end

  ##Custom sorting actions

  def sort_up
    tasks = Task.all.order(sort: :asc)

    #loop through all items (skip first... first item cannot be sorted up)
    (1...tasks.length).each do |i|
      if(tasks[i].id == params[:id].to_i)
        #found the task swap it with the previous item
        tasks[i].sort,tasks[i-1].sort = tasks[i-1].sort,tasks[i].sort
        tasks[i].save
        tasks[i-1].save
      end
    end
    redirect_to :tasks
  end

  def sort_down
    tasks = Task.all.order(sort: :asc)

    #loop through all items (skip last... last item cannot be sorted down)
    (0...tasks.length-1).each do |i|
      if(tasks[i].id == params[:id].to_i)
        #found the task swap it with the next item
        tasks[i].sort,tasks[i+1].sort = tasks[i+1].sort,tasks[i].sort
        tasks[i].save
        tasks[i+1].save
      end
    end
    redirect_to :tasks
  end

end