$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'line_server'
require 'rack/test'

module RSpecMixin
  include Rack::Test::Methods
  def app() LineServer::Api end
end

RSpec.configure { |c| c.include RSpecMixin }

