#!/usr/bin/env ruby

class Productivity
  
  require 'rubygems'
  begin
    gem 'bjeanes-ghost'
    require 'ghost'
  rescue Gem::LoadError
    puts "you need to install the ghost gem from http://github.com/bjeanes/ghost"
  end

  # Format of .productivity_ftwrc (saved in home dir):
  # - Each line is a space-separated list of one or more words.
  # - First word is the base of the subdomain.
  # - If not qualified with .com/.net/.org, assumed to be .com
  # - The www. prefix is assumed to be blocked.
  # - subsequent words are subdomains to block.
  productivity_ftwrc = "#{ENV['HOME']}/.productivity_ftwrc"
  if File.exists?(productivity_ftwrc)
    BLOCK_LIST = File.read(productivity_ftwrc).split("\n").map(&:split).map do |domain, *subdomains|
      domain += ".com" unless domain =~ /\.(org|net|com)/
      ["#{domain}", "www.#{domain}"] + subdomains.map{|subdomain| "#{subdomain}.#{domain}"}
    end.flatten
  else
    BLOCK_LIST = ["facebook.com", "www.facebook.com", "www.twitter.com", "api.twitter.com", "twitter.com"]
  end
  
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
    end
    puts "Productivity degraded -10, (Now available for distraction: #{BLOCK_LIST.join(', ')})"
  end
end
