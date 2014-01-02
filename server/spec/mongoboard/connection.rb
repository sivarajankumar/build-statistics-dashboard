
require 'mongoboard/domain'

describe Mongoboard::Release do

	before :all do
		Mongoid.load!('../etc/mongoid.yml', :development)
	end

	before :each do
		Mongoid.purge!
	end

	it "can store releases" do

		Mongoboard::Release.count.should eq 0
		r = createRecord('sample-1')	
		r.save
		Mongoboard::Release.count.should eq 1
	end

	it "can delete releases" do

		Mongoboard::Release.count.should eq 0
		r = createRecord('sample-1')	
		r.save

		Mongoboard::Release.count.should eq 1
		criteria = Mongoboard::Release.where(software: 'sample-1')
		criteria.count.should eq 1
		criteria.delete

		Mongoboard::Release.count.should eq 0
	end

	it "loads default steps based on a configuration" do
		
		createReleaseFactoryConfiguration

		factory = Mongoboard::ReleaseFactory.new
		object = factory.create 'sample-1'

		object.steps.length.should eq 5
		object.steps[0].label.should eq 'compile source code'
		object.steps[0]._id.should_not eq nil

		# assert it is a real copy and no linked connection
		#step = object.steps[0]
		#step2 = Mongoboard::Step.where(label: step.label).first
		#step2.id.should_not eq step.id
	end

	def createReleaseFactoryConfiguration
		template = Mongoboard::Release.new
		template.type = 'template'
		template.software = 'sample-1'
		template.steps = Array.new

		template.steps.push createStep('compile source code', 'maven-result', false)
		template.steps.push createStep('unit testing', 'maven-result', false)
		template.steps.push createStep('jmeter tests', 'maven-result', true)
		template.steps.push createStep('deploy on pre production', 'maven-result', false)
		template.steps.push createStep('switch production clusters', 'maven-result', true)

		template.save
	end

	def createStep(label, type, isManual)

		if isManual
			manual = 'manual' 
		else
			manual = 'automatic' 
		end

		step = Mongoboard::Step.new
		step.label = label

		step.types = Array.new
		step.types.push manual
		step.types.push type

		step.status = 'open'
		step
	end
	def createRecord(name)
		r = Mongoboard::Release.new
		r.type = 'default'
		r.system = 'cluster 1'
		r.revision = '2014-02'
		r.software = name.to_s
		r
	end

end

