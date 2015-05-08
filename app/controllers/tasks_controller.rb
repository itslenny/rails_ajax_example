class TasksController < ApplicationController

  #### standard CRUD actions

  def index
    @tasks = Task.all.order(sort: :asc)
  end

  def new
    @task = Task.new
    render layout: false
  end

  def create
    tasks = Task.all.order(sort: :asc)
    new_sort = tasks.length > 0 ?  tasks.last.sort + 1 : 0;
    Task.create title:params[:task][:title],sort: new_sort
    # redirect_to :tasks
    @tasks = Task.all.order(sort: :asc)
    render partial: 'tasks'
  end

  def edit
    @task = Task.find_by_id params[:id]
    render layout: false
  end

  def update
    Task.update params[:id], title: params[:task][:title]
    # redirect_to :tasks
    @tasks = Task.all.order(sort: :asc)
    render partial: 'tasks'
  end


  def destroy
    result = Task.destroy params[:id]

    respond_to do |format|
      format.html {redirect_to :tasks}
      format.json {render json: result}
    end
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
    # redirect_to :tasks
    @tasks = Task.all.order(sort: :asc)
    render partial: 'tasks'
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
    # redirect_to :tasks
    @tasks = Task.all.order(sort: :asc)
    render partial: 'tasks'
  end

end
