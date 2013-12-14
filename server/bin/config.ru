#!/usr/bin/env ruby

$:.unshift File.dirname(__FILE__) + '/../lib'

require 'mongoboard'

run Mongoboard::Webapp
Mongoid::load!('../etc/mongoid.yml')

