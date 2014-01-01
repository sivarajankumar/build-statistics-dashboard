
require 'mongoid'

module Mongoboard

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

		embeds_many :steps
		embeds_many :metrics

	end

	class Step
		include Mongoid::Document

		field :label, type: String
		field :status, type: String
		field :types, type: Array

		embeds_many :attachments
		embeds_many :comments
	end

	class Attachment
		include Mongoid::Document
		field :type, type: String

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
	end

	class Metric
		include Mongoid::Document

		field :label, type: String
		field :types, type: Array

		# value of this release
		field :value, type: Float

		embeds_many :MetricComparisonValues

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
