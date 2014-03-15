# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project/template/ios'
require 'bubble-wrap'
require 'bubble-wrap/http'

begin
  require 'bundler'

  Bundler.require
rescue LoadError
end

Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  app.name = 'Booksharing'
  app.codesign_certificate = 'iPhone Developer: Stephen Corona (VK3Y5GHZCB)'
  app.identifier = '7B64MB9S7K.*'
  app.provisioning_profile = 'Scanner.mobileprovision'
  app.frameworks += ['AVFoundation']

end
