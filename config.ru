$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)

require 'line_server'

# Initialize file processor with environment variable from run.sh
fp = LineServer::FileProcessor.new(ENV['LINE_SERVER_FILE'])
fp.process

run LineServer::Api