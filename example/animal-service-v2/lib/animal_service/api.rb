require 'sinatra/base'
require_relative 'animal_repository'
require 'json'

module AnimalService

  class Api < Sinatra::Base

    set :raise_errors, false
    set :show_exceptions, false

    error do
      e = env['sinatra.error']
      content_type :json, :charset => 'utf-8'
      status 500
      {error: e.message, backtrace: e.backtrace}.to_json
    end

    get '/alligators/:name' do
      if (alligator = AnimalRepository.find_alligator_by_name(params[:name]))
        content_type :json, :charset => 'utf-8'
        alligator.to_json
      else
        status 404
      end
    end

  end
end
