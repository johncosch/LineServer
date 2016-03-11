module LineServer 
  class Chunk

    attr_accessor :starting_line
    attr_accessor :ending_line
    
    def initialize(*args)
      @temp_file, @starting_line, @ending_line = args
    end

    def contains_line?(line_number)
      (@starting_line <= line_number) && (line_number <= @ending_line)
    end

    def unlink
      if @temp_file
        @temp_file.unlink
      end
    end

    def compare_line(line_number)
      if contains_line? line_number
        0
      elsif line_number < starting_line
        -1
      elsif line_number > ending_line
        1
      end
    end

    def get_line(line_number)
      raise "Line not in chunk" if !contains_line? line_number

      line_content = nil
      line_position = line_number - starting_line 

      File.open(@temp_file.path) do |io|
        (0..line_position).each do  
          line_content = io.gets
        end
      end

      line_content
    end

  end
end
