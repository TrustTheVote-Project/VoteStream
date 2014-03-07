class Api::NotSupported < StandardError

  def initialize
    super "Not Supported"
  end

end

class Api::BaseController < ApplicationController

  rescue_from Api::NotSupported do |e|
    render json: { error: e.message }
  end

end
