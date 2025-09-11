require 'sequel'

module AnimalService
  DATABASE ||= Sequel.connect(adapter: 'sqlite', database: './db/animal_db.sqlite3')
end