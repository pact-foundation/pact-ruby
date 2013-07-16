namespace :pact do
	desc "Runs all the tasks prefixed with pact:verify in this project"
  task :verify do
    Rake::Task.tasks.find_all{ | task| task.name.start_with? "pact:verify:"}.map(&:invoke)
  end
end
