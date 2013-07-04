require 'json'
#Simulate loading data into a database
some_data = [{'name' => 'Jason'},{'name' => 'Sarah'}]
File.open("tmp/a_mock_database.json", "w") { |file| file << some_data.to_json }
