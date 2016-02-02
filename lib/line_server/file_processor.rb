module LineServer
	class FileProcessor
		attr_accessor :file_location

		CHUNK_LIMIT = 1000

		def initialize(file_location)
			@file_location = Pathname.new file_location
			@chunked_file = ChunkedFile.instance 
			@current_line = 1
			@finished_processing = false
		end

		def process
			clear_chunked_file

			File.open(@file_location) do |io|
				begin
					@chunked_file.add_chunk chunk_from_io(io)
				end while @finished_processing == false
			end
		end

		private

		def clear_chunked_file
				@chunked_file.delete_chunks if !@chunked_file.empty?
		end

		def chunk_from_io(io) 
			tempfile = Tempfile.new(@file_location.basename.to_s + @current_line.to_s)
			starting_line = @current_line
			line_count = 0
			begin
				begin
					line = io.gets
					if io.eof? 
						@finished_processing = true
					else
						tempfile.write(line)
						line_count += 1
					end
				end while (line_count <= CHUNK_LIMIT) && (@finished_processing == false)
			ensure
				tempfile.close
			end
			@current_line += line_count
			ending_line = @current_line
			Chunk.new(tempfile, starting_line, ending_line)
		end

	end
end