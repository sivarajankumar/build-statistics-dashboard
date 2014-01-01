#!/usr/bin/env ruby

$:.unshift File.dirname(__FILE__) + '/../lib-core'
require 'mongoboard'

Mongoid::load!('../etc/mongoid.yml')
Mongoboard::Webapp.run!

