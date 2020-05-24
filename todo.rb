require "sinatra"
require "sinatra/reloader" if development?
require "tilt/erubis"
require "sinatra/content_for"
require_relative "helpers"

configure do
  enable :sessions
  set :session_secret, 'secret'
end

before do
  session[:lists] ||= []
end

def error_for_listname(name)
  if !(1..100).cover?(name.size)
    "The list name must be between 1 and 100 characters long."
  elsif session[:lists].any? {|list| list[:name] == name}
    "The list name must be unique."
  end
end


def error_for_taskname(task)
  if !(1..100).cover?(task.size)
    "The task name must be between 1 and 100 characters long."
  end
end

# Redirect to /lists
get "/" do
  redirect "/lists"
end

# Lists all todo lists
get "/lists" do
  @lists = session[:lists]
  erb :lists, layout: :layout
end

# Lets us create a new todo list, renders form
get "/lists/new" do
  erb :new_list
end

# Lets us create a new todo list, takes response of form
post '/lists' do
  list_name = params[:list_name].strip
  error = error_for_listname(list_name)
  if error
    session[:error] = error
    erb :new_list
  else
    session[:lists] << {"name": list_name, "todos": []}
    session[:success] = "The list has been created."
    redirect "/lists"
  end
end

# Displays a todo list with id
get "/lists/:list_id" do |list_id|
  @list = session[:lists][list_id.to_i]
  @list_id = list_id
  erb :list
end

# Handles the response of adding a new task
post "/lists/:list_id/todos/" do |list_id|
  task_name = params[:task_name].strip
  @list = session[:lists][list_id.to_i]
  error = error_for_taskname(task_name)
  @list_id = list_id
  if error
    session[:error] = error
    erb :list
  else
    p "valid"
    @list[:todos] << {"name": task_name, "done": false}
    session[:success] = "The task was added."
    redirect "/lists/" + list_id.to_s
  end
end

# Lets us edit a list name or delete it
get "/lists/:id/edit/" do |id|
  @id = id
  @list = session[:lists][id.to_i]
  erb :edit_list
end

# Handles the response of the edit_list form
post "/lists/:id/edit/" do |id|
  list_name = params[:list_name].strip
  error = error_for_listname(list_name)
  @list = session[:lists][id.to_i]
  if error
    session[:error] = error
    erb :edit_list
  else
    @list[:name] = list_name
    session[:success] = "The list name has been updated."
    redirect "/lists/" + id.to_s
  end
end

# Handles the response of the delete list button
post "/lists/:id/delete/" do |id|
  session[:lists].delete_at(id.to_i)
  session[:success] = "The list has been deleted."
  redirect "/lists"
end

# Handles the response of the delete task button
post "/lists/:list_id/todos/:task_id/delete/" do |list_id, task_id|
  @list = session[:lists][list_id.to_i]
  @list[:todos].delete_at(task_id.to_i)
  session[:success] = "The task has been deleted."
  redirect "/lists/" + list_id.to_s
end

# Toggle task status
post "/lists/:list_id/todos/:task_id/status/" do |list_id, task_id|
  @list = session[:lists][list_id.to_i]
  task = @list[:todos][task_id.to_i]
  params[:completed] == "false" ? bool = false : bool = true
  task[:done] = bool
  redirect "/lists/" + list_id.to_s
end

post "/lists/:list_id/complete-all/" do |list_id|
  @list = session[:lists][list_id.to_i]
  @list[:todos].each {|todo| todo[:done] = true }
  session[:success] = "All tasks have been marked completed."
  redirect "/lists/" + list_id.to_s
end
