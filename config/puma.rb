$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'line_server'

root = "#{Dir.getwd}"

rackup "#{root}/config.ru"

workers 2


fp = LineServer::FileProcessor.new(ENV['LINE_SERVER_FILE'])
chunked_file = fp.process
line_count = chunked_file.line_count

on_worker_boot do
  LineServer::ChunkedFile.instance.set_chunks chunked_file.chunks
  LineServer::ChunkedFile.instance.set_line_count line_count
end
