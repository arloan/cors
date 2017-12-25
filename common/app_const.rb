#!/usr/bin/env ruby
# encoding: utf-8

class AppConst
	DEFAULT_CONFIG_PATH = File.absolute_path(File.join(File.dirname(__FILE__), '../config/cors.yaml'))
	LOCAL_CONFIG_PATH = File.join(File.dirname(DEFAULT_CONFIG_PATH), 'cors.local.yaml')
end

class RedirTargetKeyName < String
	KEY_ = self.new('redir targets').freeze
	URL = self.new('url').freeze
	TYPE = self.new('type').freeze
end

class AllowedOriginKeyName < String
	KEY_ = self.new('allowed origins').freeze
end

class RedirTargetType < String
	NEVER = self.new('NEVER').freeze
	ALWAYS = self.new('ALWAYS').freeze
	VERSIONED = self.new('VERSIONED').freeze
end
