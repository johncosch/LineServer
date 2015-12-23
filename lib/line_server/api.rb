require 'sinatra'
require 'sinatra/json'

module LineServer
	class Api < Sinatra::Base

		get '/lines/:index' do
			@index = params['index'].to_i
			if @index <= chunked_file.line_count
				json :line => search_line_number
			else
				status 413
			end
		end

		private

		def chunked_file
			LineServer::ChunkedFile.instance
		end

		def search_line_number
			chunk = chunked_file.search_chunks(@index)
			chunk.get_line(@index)
		end

	end
end