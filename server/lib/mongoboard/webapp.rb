
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
				step = findStep(releaseId, stepId)
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
				step = findStep(releaseId, stepId)
				step.delete()
			rescue Mongoid::Errors::DocumentNotFound
				status 404
			end
		end

		get '/release/:releaseId/step/:stepId.json' do |releaseId, stepId|
			begin
				step = findStep(releaseId, stepId)
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
				step = findStep(releaseId, stepId)

				step.comments.push comment
				step.save!

			rescue Mongoid::Errors::DocumentNotFound
				status 404
			else
				json step
			end
		end

		post '/release/:releaseId/step/:stepId/attachment/label.json' do |releaseId, stepId|

			attachment = LabelAttachment.new
			attachment.href = params['label']

			begin
				step = findStep(releaseId, stepId)

				step.attachments.push comment
				step.save!

			rescue Mongoid::Errors::DocumentNotFound
				status 404
			else
				json attachment
			end

		end

		post '/release/:releaseId/step/:stepId/attachment/href.json' do |releaseId, stepId|

			mimeType = params['mime-type']
			link = params['link']

			attachment = HrefAttachment.new
			attachment.mimeType = mimeType if not mimeType.nil?
			attachment.href = link

			begin
				step = findStep(releaseId, stepId)

				step.attachments.push comment
				step.save!

			rescue Mongoid::Errors::DocumentNotFound
				status 404
			else
				json attachment
			end

		end

		private

		def findStep(releaseId, stepId)
			release = Release.find(releaseId)
			step = release.steps.find(stepId)
			step
		end
	end
end
