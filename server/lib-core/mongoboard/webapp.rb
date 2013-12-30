
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

		get '/releases.*' do 
			deployments = Release.where(type: 'deployment')
			json deployments
		end

		get '/release/:id.*' do |id|
			begin
				deployment = Release.find(id)
			rescue Mongoid::Errors::DocumentNotFound
				status 404
			else
				json deployment
			end
		end

		post '/release' do 

			software = params['software']
			revision = params['revision']
			system = params['system']

			factory = ReleaseFactory.new
			release = factory.create software
			release.revision = revision
			release.system = system
			release.save

			json release
		end

		get '/templates.*' do 
			templates = Release.where(type: 'template')
			json templates
		end

		get '/releases/systems.*' do 
			knownTypes = Release.distinct(:system)
			json knownTypes
		end

	end
end
