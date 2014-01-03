
module Mongoboard
	module Spec
		module Testdata

			def initialize
				@releases = {}
			end

			def configureMongoDb
				Mongoid.load!('../etc/mongoid.yml', :development)
			end

			def initEmptyDefaults
				Mongoid.purge!

				saveTemplatesFor 'sample-1'
				saveTemplatesFor 'sample-2'

				saveNewRelease 'sample-1', 1
				saveNewRelease 'sample-1', 2
				saveNewRelease 'sample-2', 1
				saveNewRelease 'sample-2', 2
			end

			def findRelease(name, version)
				id = @releases[name.to_s + ' ' + version.to_s]
				Mongoboard::Release.find(id)
			end

			def saveNewRelease(name, version)
				factory = Mongoboard::ReleaseFactory.new
				object = factory.create name.to_s, version.to_s
				object.save!
				@releases[name.to_s + ' ' + version.to_s] = object._id
			end

			def saveNewMetric(release, metricName)
				metric = Mongoboard::Metric.new
				metric.label = metricName.capitalize.sub /[-_]/, ' '
				metric.types = Array.new
				metric.types.push metricName
				metric.release = release._id
				metric.save!
				metric
			end

			private

			def saveTemplatesFor(name)
				template = Mongoboard::Release.new
				template.type = 'template'
				template.name = name
				template.steps = Array.new

				template.steps.push createStep('compile source code', 'maven-result', false)
				template.steps.push createStep('unit testing', 'maven-result', false)
				template.steps.push createStep('jmeter tests', 'maven-result', true)
				template.steps.push createStep('deploy on pre production', 'maven-result', false)
				template.steps.push createStep('switch production clusters', 'maven-result', true)

				template.save!
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
		end
	end
end
