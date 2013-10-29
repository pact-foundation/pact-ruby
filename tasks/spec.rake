task :set_active_support_on do
  ENV["LOAD_ACTIVE_SUPPORT"] = 'true'
end

desc "This is to ensure that the gem still works even when active support JSON is loaded."
task :spec_with_active_support => [:set_active_support_on] do
  Rake::Task['spec'].execute
end