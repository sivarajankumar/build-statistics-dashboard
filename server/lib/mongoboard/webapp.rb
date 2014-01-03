require 'moped'
require 'sinatra/base'
require 'sinatra/respond_with'
require 'sinatra/contrib'
require 'sinatra/json'

module Mongoboard
	class Webapp < Sinatra::Base
	
		set :static, true
		set :public_dir, File.dirname(__FILE__) + '/static'

		get '/' do
			redirect '/releases.json'
		end

		get '/releases.json' do 
			deployments = Release.where(type: 'release_candidate')
			json deployments
		end

		get '/release/:id.json' do |id|
			begin
				deployment = Release.find(id)
			rescue Mongoid::Errors::DocumentNotFound
				status 404
			else
				json deployment
			end
		end

		delete '/release/:id.json' do |id|
			begin
				deployment = Release.find(id)
				deployment.delete()
			rescue Mongoid::Errors::DocumentNotFound
				status 404
			end
		end

		post '/release.json' do 

			name = params['name']
			version = params['version']
			system = params['system']

			factory = ReleaseFactory.new
			release = factory.create name, version
			release.system = system
			release.save

			json release
		end

		get '/templates.json' do 
			templates = Release.where(type: 'template')
			json templates
		end

		get '/releases/systems.json' do 
			knownTypes = Release.where(type: 'release_candidate').distinct(:system)
			json knownTypes
		end

		get '/releases/names.json' do 
			knownNames = Release.where(type: 'template').distinct(:name)
			json knownNames
		end

		post '/release/:releaseId/step/:stepId.json' do |releaseId, stepId|
			status = params['status']

			begin
				step = StepService.instance.find(releaseId, stepId)
				step.status = status if status != nil

				step.save

			rescue Mongoid::Errors::DocumentNotFound
				status 404
			else
				json step
			end
		end

		delete '/release/:releaseId/step/:stepId.json' do |releaseId, stepId|
			begin
				step = StepService.instance.find(releaseId, stepId)
				step.delete()
			rescue Mongoid::Errors::DocumentNotFound
				status 404
			end
		end

		get '/release/:releaseId/step/:stepId.json' do |releaseId, stepId|
			begin
				step = StepService.instance.find(releaseId, stepId)
			rescue Mongoid::Errors::DocumentNotFound
				status 404
			else
				json step
			end
		end

		post '/release/:releaseId/step/:stepId/comment.json' do |releaseId, stepId|

			author = params['author']
			text = params['text']

			comment = Comment.new
			comment.author = author
			comment.text = text

			begin
				step = StepService.instance.find(releaseId, stepId)

				step.comments.push comment
				step.save!

			rescue Mongoid::Errors::DocumentNotFound
				status 404
			else
				json step
			end
		end

		post '/create/release-:software/version-:version/step-:stepLabel/attachments/label.json' do |software, version, stepLabel|

			attachment = LabelAttachment.new
			attachment.label = params['label']
			attachment.type = 'label'

			begin
				step = StepService.instance.findUniqByName software, version, stepLabel
				saveAttachment step, attachment, request.ip

			rescue Mongoid::Errors::DocumentNotFound
				status 404
			else
				json attachment
			end

		end

		post '/create/release-:software/version-:version/step-:stepLabel/attachments/href.json' do |software, version, stepLabel|

			mimeType = params['mime-type']
			link = params['link']
			label = params['label']

			attachment = HrefAttachment.new
			attachment.mimeType = mimeType if not mimeType.nil?
			attachment.label = label
			attachment.href = link
			attachment.type = 'href'

			begin
				step = StepService.instance.findUniqByName software, version, stepLabel
				saveAttachment step, attachment, request.ip

			rescue Mongoid::Errors::DocumentNotFound
				status 404
			else
				json attachment
			end

		end

		get '/metric/:metricId.json' do |metricId|
			begin
				metric = Metric.find(metricId)
			rescue Mongoid::Errors::DocumentNotFound
				status 404
			else
				json metric
			end
		end

		delete '/metric/:metricId.json' do |metricId|
			begin
				metric = Metric.find(metricId)
				metric.delete
			rescue Mongoid::Errors::DocumentNotFound
				status 404
			else
				json metric
			end
		end

		post '/metric/:metricId.json' do |metricId|
			begin
				metric = Metric.find(metricId)
				updateMetric(metric, params)
			rescue Mongoid::Errors::DocumentNotFound
				status 404
			else
				json metric
			end
		end

		get '/release/:releaseId/metrics-default-history.json' do |releaseId|

			service = MetricService.instance
			begin
				history = service.findMetricHistory(releaseId, 50)
			rescue Mongoid::Errors::DocumentNotFound
				status 404
			else
				json history
			end

		end

		#
		# metricName - first type in record is name of a metric
		#
		post '/create-or-replace/release-:software/version-:version/metric-:metricName.json' do |software, version, metricName|

			service = MetricService.instance
			begin
				metric = service.findOrCreateMetric(software, version, metricName)
			rescue Errors::WrongResultCount => e
				status 404, e.message
			else
				updateMetric(metric, params)
				json metric
			end
			
		end

		private

		def updateMetric(metric, params)

			value = params['value']
			label = params['label']
			types = params['types']
			
			metric.value = value.to_f if not value.nil?
			metric.label = label.to_s if not label.nil?
			metric.types = toStringArray(types) if not types.nil?
			metric.save!
			metric
		end

		def toStringArray(parameter)
			result = []
			if parameter.kind_of?(Array)
				parameter.each do |item|
					result.push item.to_s
				end
			else
				result.push parameter.to_s
			end
			result
		end

		def saveAttachment step, attachment, clientIp

			step.attachments.push attachment

			comment = Comment.new
			comment.author = "System " + clientIp
			comment.text = "Created attachment " + attachment.label.to_s
			step.comments.push comment

			step.save!
		end

	end
end
