#!/usr/bin/env ruby
# encoding: utf-8

require 'uri'
require 'json'
require 'cuba'
require 'httpi'
require 'yaml'

require 'common/app_const'
require 'common/security_agent'


class Cuba
	TARGET_TYPE_ALWAYS = :ALWAYS
	TARGET_TYPE_VERSIONED = :VERSIONED
	@app_redir_targets = {}
	@allowed_origins = /^https?:\/\/localhost(?::\d+)?$|^https?:\/\/192\.168\.\d+\.\d+(?::\d+)?$/

	CONF_KEY_URL = 'url'.freeze
	CONF_KEY_TYPE = 'type'.freeze

	class << self

		attr_reader :app_redir_targets, :allowed_origins

		def app_target(app, ver)
			app = app.to_s
			t = @app_redir_targets[app]
			return nil if t.nil?
			return t[CONF_KEY_URL] if t[CONF_KEY_TYPE].to_sym == TARGET_TYPE_ALWAYS

			# url = 'https://itunes.apple.com/lookup?bundleId=com.ketchapp.2048'
			url = 'https://itunes.apple.com/lookup?bundleId=' + app
			r = HTTPI.get_with_redir(url)
			# puts 'data retrieved from appstore:'
			# puts r.body
			return nil if r.code / 100 > 2 or r.headers['content-type'] !~ /json/
			version_info = JSON.parse(r.body)
			if version_info['resultCount'].to_i == 1
				ver_appstore = version_info['results'][0]['version'].to_f
				ver_current = ver.to_f
				# puts 'appstore version: ' + ver_appstore.to_s + ', current version: ' + ver_current.to_s
				# puts 'app target: %s' % Cuba.app_target(app)
				return t[CONF_KEY_URL] if ver_current <= ver_appstore
			end
		end # end of method app_target

		def load_config
			if File.exist?(AppConst::DEFAULT_CONFIG_PATH)
				@app_config = YAML.load(IO.read(AppConst::DEFAULT_CONFIG_PATH))
				app_targets = @app_config['redir targets']
				@app_redir_targets = app_targets if app_targets and app_targets.is_a?(Hash)
				allowed_origins = @app_config['allowed origins']
				@allowed_origins = Regexp.new(allowed_origins) if allowed_origins and allowed_origins.is_a?(String)
			end
		rescue
			$stderr.puts 'load_config failed: '
			$stderr.puts $!.message
			$stderr.puts $@
		end
	end

	def url(addr = nil, absolute = true, add_script_name = true)
		return addr if addr =~ /\A[A-z][A-z0-9\+\.\-]*:/
		uri = [host = '']
		if absolute
			host << "http#{'s' if req.ssl? }://"
			if env.include?('HTTP_X_FORWARDED_HOST') or req.port != (req.ssl? ? 443 : 80)
				host << req.host_with_port
			else
				host << req.host
			end
		end
		if addr.start_with?('/')
			uri << addr
		else
			uri << req.script_name.to_s if add_script_name
			uri << (addr ? addr : req.path_info).to_s
		end
		File.join uri
	end

	def cor_merge_headers(headers, merged)
		headers.select! { |k,v| v.is_a?(String) and k !~ /^access-control|transfer-encoding/ }
		headers.merge(merged || {} )
	end

	def cor_make_headers(request_headers, origin)
		merge = { 'Access-Control-Allow-Origin' => origin.to_s } if origin.to_s =~ self.class.allowed_origins
		return cor_merge_headers(request_headers, merge)
	end
end
