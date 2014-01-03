#!/usr/bin/env ruby

$:.unshift File.dirname(__FILE__) + '/../lib'

require 'mongoboard/domain'
require 'optparse'


def createOptionsOrUsage

	options = {}
	options[:configFile] = '../etc/mongoid.yml'

	parser = OptionParser.new do |opts|
	  opts.banner = "Usage: setup-templates.rb [options]"

	  opts.on("-c", "--configfile [FILE]", "Use this configuration to connect to MongoDB. Default is " + options[:configFile]) do |file|
	    options[:configFile] = file
	  end

	  opts.on("-m", "--create-mockdata", "Create a a set of mockdata in current $MONGO_DEV") do |v|
	    options[:create_mockdata] = v
	  end

	end

	raise OptionParser::MissingArgument if ARGV.length == 0
	parser.parse!
	options
end

def createTemplateReleaseConfiguration(name, steps)
	template = Mongoboard::Release.new

	template.created = DateTime.now
	template.name = name
	template.steps = steps
	template.system = 'unknown'
	template.type = 'template'
	template.version = 'unknown'

	template
end

def createStep(label, types)

	comment = Mongoboard::Comment.new
	comment.author = 'setup-template.sh'
	comment.text = 'Testdata inserted'

	step = Mongoboard::Step.new
	step.label = label
	step.status = 'open'
	step.types = types
	step.comments.push comment
	step
end

def connectToMongoInstance configFile
	Mongoid.load!(configFile)
	puts "Connection to mongodb [" + configFile + "] establidhed"
end

def createTemplates

	steps = Array.new
	steps.push createStep('compile source code', [ 'automated', "maven-build" ])
	steps.push createStep('unit testing', [ 'automated', "maven-build" ])
	steps.push createStep('jmeter tests', [ 'automated', "maven-build" ])
	steps.push createStep('deploy on pre production', [ 'manual', "shellscript" ])
	steps.push createStep('switch production clusters', [ 'manual', "shellscript" ])

	template = createTemplateReleaseConfiguration('Shop', steps)
	template.save

	steps = Array.new
	steps.push createStep('compile source code', [ 'automated', "maven-build" ])
	steps.push createStep('unit testing', [ 'automated', "maven-build" ])
	steps.push createStep('jmeter tests', [ 'automated', "maven-build" ])
	steps.push createStep('deploy on pre production', [ 'manual', "shellscript" ])
	steps.push createStep('switch production clusters', [ 'manual', "shellscript" ])

	template = createTemplateReleaseConfiguration('Admintool', steps)
	template.save
end

def createMetrics(release, offset)

	createAndSaveMetric release, 'changelog', 20, offset
	createAndSaveMetric release, 'code-size', 20000, offset
	createAndSaveMetric release, 'code-complexity', 30, offset
	createAndSaveMetric release, [ 'reported-defects', 'important' ], 10, offset
	createAndSaveMetric release, 'time-before-last-commit', 3, offset

end

def createAndSaveMetric(release, types, value, offset)
	offset = 0 if offset.nil?

	name = nil
	label = nil
	if types.kind_of? Array
		name = types
		label = types[0].to_s.capitalize.sub /[-_]/, ' '
	else
		name = [ types.to_s ]
		label = types.to_s.capitalize.sub /[-_]/, ' '
	end

	metric = Mongoboard::Metric.new
	metric.types = name
	metric.label = label

	metric.value = value + (offset * 1000) if value > 1000
	metric.value = value + (offset * 100) if value > 100 and value <= 1000 
	metric.value = value + (offset * 20) if value > 50  and value <= 100 
	metric.value = value + (offset * 4) if value > 20  and value <= 50 
	metric.value = value + offset if value <= 20 

	metric.release = release._id

	metric.save!
	metric
end

options = createOptionsOrUsage

if options[:create_mockdata]

	connectToMongoInstance options[:configFile]
	Mongoid.purge!

	createTemplates
	factory = Mongoboard::ReleaseFactory.new

	release = factory.create('Shop', '2013-023')
	release.system = 'Eastern Europe Production'
	release.save
	createMetrics(release, 2)

	release = factory.create('Shop', '2013-023')
	release.system = 'Western Europe Production'
	release.save
	createMetrics(release, 3)

	release = factory.create('Shop', '2013-024')
	release.system = 'Eastern Europe Production'
	release.save
	createMetrics(release, 0)

	release = factory.create('Shop', '2013-024')
	release.system = 'Western Europe Production'
	release.save
	createMetrics(release, 5)

	release = factory.create('Shop', '2013-025')
	release.system = 'Eastern Europe Production'
	release.save
	createMetrics(release, 1)

	release = factory.create('Shop', '2013-025')
	release.system = 'Western Europe Production'
	release.save

	release = factory.create('Admintool', '2013-023')
	release.system = 'Eastern Europe Production'
	release.save

	release = factory.create('Admintool', '2013-025')
	release.system = 'Western Europe Production'
	release.save

end
