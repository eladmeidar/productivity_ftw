#!/usr/bin/env ruby

class Productivity
  
  require 'rubygems'
  begin
    gem 'ghost'
    require 'ghost'
  rescue Gem::LoadError
    puts "you need to install the ghost gem from http://github.com/bjeanes/ghost"
  end
  
  BLOCK_LIST = ["facebook.com", "www.facebook.com", "www.twitter.com", "api.twitter.com", "twitter.com"]
  ALLOWED_ACTIONS = ["start", "stop"]
  
  def self.start
     BLOCK_LIST.each do |block_target|
       begin 
         Host.add(block_target, '127.0.0.1')
       rescue
         puts "#{block_target} already blocked"
       end
     end
     puts "Productivity enhanced +10!!!, (Blocked: #{BLOCK_LIST.join(', ')})"
  end
  
  def self.stop
    BLOCK_LIST.each do |block_target|
      Host.delete(block_target)
      puts "Productivity degraded -10, (Now available for distraction: #{BLOCK_LIST.join(', ')})"
    end
  end
end
