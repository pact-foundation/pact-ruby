require 'json'

class AllTheZebras

  def set_up
    #Simulate loading data into a database
    some_data = [{'name' => 'Jason'},{'name' => 'Sarah'}]
    File.open("tmp/a_mock_database.json", "w") { |file| file << some_data.to_json }
  end

  def tear_down
    #simulate cleaning up database
    FileUtils::rm('tmp/a_mock_database.json')
  end
end

# pact_fixture do
#   before do
#     #Simulate loading data into a database
#     some_data = [{'name' => 'Jason'},{'name' => 'Sarah'}]
#     File.open("tmp/a_mock_database.json", "w") { |file| file << some_data.to_json }
#   end

#   after do
#     #simulate cleaning up database
#     FileUtils::rm('tmp/a_mock_database.json')
#   end
# end
