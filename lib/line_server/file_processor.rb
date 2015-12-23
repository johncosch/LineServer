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
			stream = IO.sysopen @file_location
			io = IO.new stream
			begin
				@chunked_file.add_chunk chunk_from_io(io)
			end while @finished_processing == false
			io.close
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
				line = io.gets
				if line == nil && io.eof? 
					@finished_processing = true
				else
					tempfile.write(line)
					line_count += 1
				end
			end while (line_count <= CHUNK_LIMIT) && (@finished_processing == false)
			@current_line += line_count
			tempfile.close
			ending_line = @current_line
			return Chunk.new(tempfile, starting_line, ending_line)
		end

	end
end