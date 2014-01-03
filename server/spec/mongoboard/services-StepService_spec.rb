require 'mongoid'
require 'mongoboard/domain'
require 'mongoboard/data_provider_helper'

describe Mongoboard::StepService do

	include Mongoboard::Spec::Testdata

	before :all do
		configureMongoDb	
	end

	before :each do
		initEmptyDefaults
	end

	it "raise error if release not found" do
		expect {
			Mongoboard::StepService.instance.find('xxx', 'xxx')
		}.to raise_error(Mongoid::Errors::DocumentNotFound)
	end

	it "raise error if step not found" do

		release = findRelease 'sample-1', 2

		expect {
			Mongoboard::StepService.instance.find(release._id, 'xxx')
		}.to raise_error(Mongoid::Errors::DocumentNotFound)
		
	end

	it "find step by id" do

		release = findRelease 'sample-1', 2
		stepId = release.steps[1]._id
		stepId.should_not eq nil

		step = Mongoboard::StepService.instance.find(release._id, stepId)
		step._id.should eq stepId
		
	end
end
