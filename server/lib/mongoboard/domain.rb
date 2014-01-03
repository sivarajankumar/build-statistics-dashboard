
require 'mongoid'
require 'singleton'

module Mongoboard

	module Errors
		class WrongResultCount < StandardError
			def initialize(actualCount)
				@actualCount = actualCount
			end

			def message
				message = super
				r = "got " + @actualCount.to_s + " results"
				r = r + ", " + message unless message.nil?
				r
			end
		end
	end

	class MetricService
		include Singleton

		#
		# either returns an existing metric or create a new record for 
		# this release and returns it
		#
		# @throws a WrongResultCount errors, if release cannot be found or more
		# metrics with given name exists
		#
		def findOrCreateMetric(software, version, metricName)
			queryRelease = Release.where({
				name: software, 
				type: 'release_candidate',
				version: version
			})

			count = queryRelease.count
			if count != 1
				raise Errors::WrongResultCount.new(count), "1 release expected"
			else
				release = queryRelease[0]
				queryMetric = release.metrics.where({
					name: metricName
				})

				count = queryMetric.count

				if count > 1
					raise Errors::WrongResultCount.new(count), "0..1 metrics expected"
				else 
					if count == 1
						metric = queryMetric[0]
					end

					if count == 0
						metric = Metric.new
						metric.name = metricName
						release.metrics.push metric
						release.save!
					end

				end
			end

			raise "Unexpected result: metric == nil" if metric.nil?
			metric


		end

	end

	class StepService

		include Singleton

		def find(releaseId, stepId)
			release = Release.find(releaseId)
			step = release.steps.find(stepId)
			step
		end
	end

	#
	# create a release based on a template and attach required steps
	#
	class ReleaseFactory
		def create(name, version)

			template = Release.where(name: name, type: 'template').first
			raise "No template found in db for '" + name.to_s + "'" if template == nil

			release = Release.new

			release.created = DateTime.now
			release.name = name
			release.system = template.system
			release.type = :release_candidate
			release.version = version

			template.steps.each do |step|
				release.steps.push step.clone
			end

			release
		end
	end

	class Release
		include Mongoid::Document

		field :created, type: DateTime
		field :name, type: String
		field :system, type: String
		field :type, type: String
		field :version, type: String

		embeds_many :steps, as: :stepable
		embeds_many :metrics, as: :metricable

	end

	class Step
		include Mongoid::Document

		field :label, type: String
		field :status, type: String
		field :types, type: Array

		embedded_in :stepable, polymorphic: false

		embeds_many :attachments, as: :attachmentable
		embeds_many :comments, as: :commentable
	end

	class Attachment
		include Mongoid::Document
		field :type, type: String

		embedded_in :attachmentable, polymorphic: true
		
		protected

		def initialize

		end
	end

	class LabelAttachment < Attachment
		field :label, type: String

		def initialize
			@type = 'label'
		end
	end
	
	class HrefAttachment < LabelAttachment
		field :href, type: String
		field :mimeType, type: String

		def initialize
			@type = 'link'
			@mimeType = 'text/html'
		end
	end

	class BinaryDbAttachment < LabelAttachment
		field :data, type: String
		field :mimeType, type: String

		def initialize
			@type = 'db-data'
			@mimeType = 'application/octet-stream'
		end
	end

	class Comment
		include Mongoid::Document

		field :author, type: String
		field :text, type: String
		field :created, type: DateTime, default: DateTime.now
	
		embedded_in :commentable, polymorphic: false

		def initialized
			@created = DateTime.now
		end

		def empty?
			isAuthorEmpty = @author.nil? || @author.empty?  
			isTextEmpty = @text.nil? || @text.empty?  
			return isAuthorEmpty || isTextEmpty
		end
	end

	class Metric
		include Mongoid::Document

		field :label, type: String
		field :name, type: String
		field :types, type: Array

		# value of this release
		field :value, type: Float
		
		embedded_in :metricable, polymorphic: false

	end

	#
	# this class is e.g.
	#  - an average value of last 5 releases
	#  - an average value of last 3 month
	#  - ...
	#
	class MetricComparisionValue
		include Mongoid::Document

		field :label, type: String
		field :type, type: String
		field :value, type: Float

	end
end
