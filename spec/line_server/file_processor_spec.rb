require 'spec_helper'

describe LineServer::FileProcessor do 

	let(:file_name) { "#{Dir.pwd}/spec/fixtures/aesops_fables.txt" }
	let(:chunk_amount) { (get_file_lines.count.to_f / LineServer::FileProcessor::CHUNK_LIMIT).ceil }

	describe "#initialize" do 
		it "will create a new file processor" do
			fp = LineServer::FileProcessor.new(FILE_NAME)
			fp.process
			expect(LineServer::ChunkedFile.instance.chunks.size).to eq(chunk_amount)
		end
	end

	after(:each) do
    	LineServer::ChunkedFile.instance.delete_chunks
  	end

  	def get_file_lines
		IO.readlines(file_name)
	end

end