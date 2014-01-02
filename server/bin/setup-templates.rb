#!/usr/bin/env ruby

$:.unshift File.dirname(__FILE__) + '/../lib'

require 'mongoboard/domain'
require 'optparse'

class ImportApplication

	attr_accessor :name
	attr_accessor :steps

	def initialize(name)
		@name = name
		@steps = Array.new
	end
end

class ImportStep

	attr_accessor :label
	attr_accessor :types

	def initialize(label, types = Array.new)
		@label = label
		@types = types
	end
end

#
# change this method the way you like
#
#
def createTemplates

	app = ImportApplication.new 'Shop'
	app.steps.push ImportStep.new 'compile source code', [ 'automated', 'maven-build' ]
	app.steps.push ImportStep.new 'unit testing', [ 'automated', 'maven-build' ]
	app.steps.push ImportStep.new 'jmeter tests', [ 'automated', 'maven-build' ]
	app.steps.push ImportStep.new 'deploy on pre production', [ 'manual', 'shellscript' ]
	app.steps.push ImportStep.new 'switch production clusters', [ 'manual', 'shellscript' ]

	saveTemplateReleaseConfiguration(app)

	app = ImportApplication.new 'Admintool'
	app.steps.push ImportStep.new 'compile source code', [ 'automated', 'maven-build' ]
	app.steps.push ImportStep.new 'unit testing', [ 'automated', 'maven-build' ]
	app.steps.push ImportStep.new 'jmeter tests', [ 'automated', 'maven-build' ]
	app.steps.push ImportStep.new 'deploy on pre production', [ 'manual', 'shellscript' ]
	app.steps.push ImportStep.new 'switch production clusters', [ 'manual', 'shellscript' ]

	saveTemplateReleaseConfiguration(app)

end

def saveTemplateReleaseConfiguration(application)
	template = Mongoboard::Release.new

	template.created = DateTime.now
	template.name = application.name
	template.system = :unknown
	template.type = :template
	template.version = :unknown

	application.steps.each do |step|
		mongoStep = createStep step.label, step.types
		template.steps.push mongoStep
	end

	template.save
	puts "Template for application " + application.name + " created"
	template
end

def createStep(label, types)

	step = Mongoboard::Step.new
	step.label = label
	step.status = 'open'
	step.types = types

	comment = Mongoboard::Comment.new
	comment.author = 'setup-templates.sh'
	comment.text = 'Initial data inserted'
	step.comments.push comment

	step

end

##### no changes below here #####

def connectToMongoInstance configFile
	Mongoid.load!(configFile)
	puts "Connection to mongodb [" + configFile + "] established"
end

def createOptionsOrUsage


	options = {}
	options[:configFile] = '../etc/mongoid.yml'

	parser = OptionParser.new do |opts|
	  opts.banner = "Usage: setup-templates.rb [options]"

	  opts.on("-c", "--configfile [FILE]", "Use this configuration to connect to MongoDB. Default is " + options[:configFile]) do |file|
	    options[:configFile] = file
	  end

	  opts.on("-p", "--purge-database", "Remove all data from current database in $MONGO_DEV") do |v|
	    options[:purge] = v
	  end

	  opts.on("-t", "--create-templates", "Create a a set of template steps in current $MONGO_DEV") do |v|
	    options[:create_templates] = v
	  end

	end

	raise OptionParser::MissingArgument if ARGV.length == 0
	parser.parse!
	options
end

def purgeDatabase
	Mongoid.purge!
	puts "Database purged"
end

options = createOptionsOrUsage

connectToMongoInstance options[:configFile]

purgeDatabase if options[:purge]
createTemplates if options[:create_templates]

