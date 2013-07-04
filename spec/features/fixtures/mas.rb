require 'pact/producer/interaction_fixture'

interaction_fixture :all_the_zebras do
  set_up do
    some_data = [{'name' => 'Jason'},{'name' => 'Sarah'}]
    File.open("tmp/a_mock_database.json", "w") { |file| file << some_data.to_json }
  end

  tear_down do
    some_data = [{'name' => 'Jason'},{'name' => 'Sarah'}]
    File.open("tmp/a_mock_database.json", "w") { |file| file << some_data.to_json }
  end
end