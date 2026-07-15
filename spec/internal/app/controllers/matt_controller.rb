# frozen_string_literal: true

class MattController < ApplicationController
  def create
    render plain: 'MATTworldMATT', content_type: 'application/matt'
  end
end
