#Installation instructions

# Installation #

  1. Install mongodb
  1. Install ruby including all required gems
  1. Download the software:
    * latest: `git clone https://code.google.com/p/build-statistics-dashboard/`
  1. configure a connection in etc/mongoid.yml
  1. create templates for your applications.
    * use bin/setup-templates.sh as sample file.
    * copy it, edit it as you need it and execute it


## Required gems & software ##

Tested on:

  * Ruby version: ruby 1.9.3p194 (2012-04-20 [revision 35410](https://code.google.com/p/build-statistics-dashboard/source/detail?r=35410))
  * MongoDb: db version v2.0.6, pdfile version 4.5
  * Debian Wheezy x86\_64

### Gems ###

  * sinatra (1.4.4)
  * sinatra-contrib (1.4.2)
  * json (1.8.1)
  * mongoid (3.1.6)
  * moped (1.5.1)

For running unit tests:

  * rspec (2.13.0)

# Run webapplication #

  1. set a environment variable $MONGOID\_ENV to `development` or `proruction`
  1. For seeing some Data, run
    * bin/setup-templates.rb -p -t
    * bin/setup-mockdata.rb -m
  1. execute bin/run-webapp.rb
  1. open http://localhost:4567/index.html for first tes/index.html for a first test. You should see a list of releases.