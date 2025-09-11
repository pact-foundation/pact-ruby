# frozen_string_literal: true

class PetsController < ApplicationController
  def show
    render json: {
      pet: {
        id: params[:id].to_i,
        bark: true,
        breed: "Husky"
      }
    }
  end

  def update
    response.set_header("TRACE_ID", "xxx-xxx")
    render json: {
      pet: {
        id: params[:id].to_i,
        bark: true,
        breed: params[:breed]
      }
    }
  end
end
