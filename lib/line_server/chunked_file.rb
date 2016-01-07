require "singleton"

module LineServer 
	class ChunkedFile
		include Singleton

		attr_reader :line_count

		def add_chunk(chunk)
			update_line_count chunk
			chunks.push chunk
		end

		def delete_chunks
			chunks.each do |chunk|
				chunk.unlink
			end
			@chunks = []
			@line_count = 0
		end

		def search_chunks(line_number)
			chunk_index = lower_bound(line_number)
			if line_number < chunks[chunk_index].starting_line
				chunk_index -= 1
			end
			chunks[chunk_index]
		end

		def empty?
			 chunks.size == 0 
		end

		def chunks
			@chunks ||= []
		end

		private

		def lower_bound(line_number)
			chunk_size = LineServer::FileProcessor::CHUNK_LIMIT
			(line_number / chunk_size).floor
		end

		def count
			@line_count ||= 0
		end

		def update_line_count(chunk)
			if chunk.ending_line > count
				@line_count = chunk.ending_line
			end
		end

	end
end