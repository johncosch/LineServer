require 'spec_helper'

describe LineServer::Api do 

	FILE_NAME = "#{Dir.pwd}/spec/fixtures/aesops_fables.txt"

	let(:url) { "/lines/" }
	let(:file_lines) { get_file_lines }
	let(:valid_line_number) { random_line_number }

	before(:all) do
		fp = LineServer::FileProcessor.new(FILE_NAME)
		fp.process
	end

	describe "#get /lines/:number" do 
		it "will return the specified line number" do
			full_url = url + valid_line_number.to_s
			get full_url, nil
    	expect(last_response.status).to eq(200)
    	body = json(last_response.body)
    	expect(body[:line]).to eq(file_lines[valid_line_number - 1])
		end

		it "will return a 413 status if line is out of bounds" do
			line_number = file_lines.count + 10
			full_url = url + line_number.to_s
			get full_url, nil
    	expect(last_response.status).to eq(413)
		end
	end

	after(:all) do
		LineServer::ChunkedFile.instance.delete_chunks
	end

	def random_line_number
		1 + rand(get_file_lines.size - 1)
	end

	def get_file_lines
		IO.readlines(FILE_NAME)
	end

	def json(body)
    JSON.parse(body, symbolize_names: true)
  end

end