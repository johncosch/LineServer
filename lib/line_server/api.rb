require 'sinatra'
require 'sinatra/json'

module LineServer
  class Api < Sinatra::Base

    get '/lines/:index' do
      index = params['index'].to_i
      if index <= chunked_file.line_count
        json :line => retrieve_line_number(index)
      else
        status 413
      end
    end

    private

    def chunked_file
      LineServer::ChunkedFile.instance
    end

    def retrieve_line_number(index)
      chunk = chunked_file.search_chunks(index)
      chunk.get_line(index)
    end

  end
end