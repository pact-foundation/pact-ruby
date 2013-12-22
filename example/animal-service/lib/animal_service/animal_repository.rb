require 'sequel'
require_relative 'db'

module AnimalService
  class AnimalRepository


    def self.find_alligators
      DATABASE[:animals].find_all
    end

    def self.find_alligator_by_name name
      DATABASE[:animals].where(name: name).single_record
    end
  end
end
