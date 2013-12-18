class Admin::BaseController < ApplicationController

  layout 'admin'

  before_filter :authenticate, :if => lambda { Rails.env.production? || Rails.env.staging? }

  private

  def authenticate
    authenticate_or_request_with_http_basic("ENRS Admin Console") do |user, password|
      a = AppConfig['admin']
      p = a['pass']
      p.present? && p == password && a['user'] == user
    end
  end

end
