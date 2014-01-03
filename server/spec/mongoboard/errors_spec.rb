
require 'mongoboard/domain'

describe Mongoboard::Errors do

	it "is throwable with correct parameters" do
	
		begin
			raise Mongoboard::Errors::WrongResultCount.new(3), "0..1 items expected"
		rescue Mongoboard::Errors::WrongResultCount => e
			e.message.should eq "got 3 results, 0..1 items expected"
		end

	end

	it "is throwable with correct parameters, no message" do
	
		begin
			raise Mongoboard::Errors::WrongResultCount.new(3)
		rescue Mongoboard::Errors::WrongResultCount => e
			e.message.should eq "got 3 results, Mongoboard::Errors::WrongResultCount"
		end

	end

end
