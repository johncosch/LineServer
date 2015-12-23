require 'spec_helper'
require 'ruby-prof'

#
# Don't want to run with normal spec's
#
=begin
describe LineServer::Api do 

	let(:url) { "/lines/" }

	before(:all) do
		file_name = "#{Dir.pwd}/spec/fixtures/aesops_fables.txt"
		fp = LineServer::FileProcessor.new(file_name)
		fp.process
	end

	describe "#get /lines/:number" do 
		it "will return the specified line number" do
			RubyProf.start
			line_number = 1100
			full_url = url + line_number.to_s
			get full_url, nil
			result = RubyProf.stop
			printer = RubyProf::FlatPrinter.new(result)
			printer.print(STDOUT)
		end
	end

	after(:all) do
		LineServer::ChunkedFile.instance.delete_chunks
	end

end
=end
