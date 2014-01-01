
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

		post '/create-release' do 

			name = params['name']
			version = params['version']
			system = params['system']

			factory = ReleaseFactory.new
			release = factory.create software, version
			release.system = system
			release.save

			json release
		end

		get '/templates.json' do 
			templates = Release.where(type: 'template')
			json templates
		end

		get '/releases/systems.json' do 
			knownTypes = Release.distinct(:system)
			json knownTypes
		end

		get '/releases/names.json' do 
			knownNames = Release.distinct(:name)
			json knownNames
		end

	end
end
