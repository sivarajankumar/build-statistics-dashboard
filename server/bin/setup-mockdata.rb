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

options = createOptionsOrUsage

if options[:create_mockdata]

	connectToMongoInstance options[:configFile]
	Mongoid.purge!

	createTemplates
	factory = Mongoboard::ReleaseFactory.new

	release = factory.create('Shop', '2013-023')
	release.system = 'Eastern Europe Production'
	release.save

	release = factory.create('Shop', '2013-023')
	release.system = 'Western Europe Production'
	release.save

	release = factory.create('Shop', '2013-024')
	release.system = 'Eastern Europe Production'
	release.save

	release = factory.create('Shop', '2013-024')
	release.system = 'Western Europe Production'
	release.save

	release = factory.create('Shop', '2013-025')
	release.system = 'Eastern Europe Production'
	release.save

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
