namespace :pact do
  task :verify do
    Rake::Task.tasks.find_all{ | task| task.name.start_with? "pact:verify:"}.map(&:invoke)
  end
end