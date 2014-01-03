
require 'mongoboard/domain'
require 'pry'

describe Mongoboard::Release do

	before :all do
		Mongoid.load!('../etc/mongoid.yml', :development)
	end

	before :each do
		Mongoid.purge!
	end

	it "can find a step by id" do

		Mongoboard::Release.count.should eq 0
		createReleaseFactoryConfiguration

		factory = Mongoboard::ReleaseFactory.new
		object = factory.create 'sample-1', '12345'
		object.save!
		Mongoboard::Release.count.should eq 2

		object = Mongoboard::Release.find_by({name: 'sample-1', version: '12345'})
		releaseId = object._id.to_s
		releaseId.length.should >= 0
		
		stepId = object.steps[0]._id
		step = object.steps.find(stepId)

		step.should_not eq nil
		step.class.to_s.should eq 'Mongoboard::Step'
		
	end

	it "can add a comment to an already existing step" do

		# setup data
		createReleaseFactoryConfiguration
		factory = Mongoboard::ReleaseFactory.new
		release = factory.create 'sample-1', '12345'
		release.save!
		releaseId = release._id

		stepId = release.steps[0]._id
		step = release.steps.find(stepId)

		Mongoboard::Release.count.should eq 2 # it is not saved in root scope
		comment = Mongoboard::Comment.new
		comment.author = 'Me'
		comment.text = 'Sample text'

		# execute it
		step.comments.push comment
		step.save!
		Mongoboard::Release.count.should eq 2 # it is not saved in root scope
		
		step.comments.length.should eq 1
		comment = step.comments.last
		commentId = comment._id.to_s

		comment.author.should eq 'Me'
		comment.text.should eq 'Sample text'

		# verify comment has been saved
		release = Mongoboard::Release.find(releaseId)
		step = release.steps.find(stepId)
		comment = step.comments.find(commentId)

		comment.class.to_s.should eq 'Mongoboard::Comment'
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
		criteria = Mongoboard::Release.where(name: 'sample-1')
		criteria.count.should eq 1
		criteria.delete

		Mongoboard::Release.count.should eq 0
	end

	it "loads default steps based on a configuration" do
		
		createReleaseFactoryConfiguration

		factory = Mongoboard::ReleaseFactory.new
		object = factory.create 'sample-1', '123456'

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
		template.name = 'sample-1'
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
		r.version = '2014-02'
		r.name = name.to_s
		r
	end

end
