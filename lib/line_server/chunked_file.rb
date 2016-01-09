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
			chunks.bsearch do |x|
				x.compare_line line_number
			end
		end

		def empty?
			 chunks.size == 0 
		end

		def set_chunks(chunks_arry)
			@chunks = chunks_arry
		end

		def set_line_count(count)
			@line_count = count
		end

		def chunks
			@chunks ||= []
		end

		private

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