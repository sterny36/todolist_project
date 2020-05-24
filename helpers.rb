helpers do
  def list_complete?(list)
    todos_count(list) > 0 && todos_remaining_count(list) == 0
  end

  def list_class(list)
    "complete" if list_complete?(list)
  end

  def todos_remaining_count(list)
    list[:todos].select {|todo| !todo[:done] }.size
  end

  def todos_count(list)
    list[:todos].size
  end

  def sort_lists(lists, &block)
    complete_lists, incomplete_lists  = lists.partition  {|list| list_complete?(list) }

    incomplete_lists.each {|list| yield list, lists.index(list) }
    complete_lists.each {|list| yield list, lists.index(list) }
  end

  def sort_todos(list, &block)
    complete_tasks, incomplete_tasks  = list.partition  {|task| task[:done] }

    incomplete_tasks.each {|task| yield task, list.index(task) }
    complete_tasks.each {|task| yield task, list.index(task) }
  end
end
