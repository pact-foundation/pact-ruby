RSpec.configure do |c|
  c.before(:all, :type => :feature) do
    Pact::Consumption::AppManager.instance.spawn_all
  end
end

RSpec.configure do |c|
  # After the tests run, kill the spawned apps
  c.after(:all, :type => :feature) do
    Pact::Consumption::AppManager.instance.kill_all
  end
end
