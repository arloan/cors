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
	@app_config = {}
	@local_config = {}
	@app_redir_targets = {}
	@local_app_redir_targets = {}
	@allowed_origins = /^https?:\/\/localhost(?::\d+)?$|^https?:\/\/192\.168\.\d+\.\d+(?::\d+)?$/

	class << self

		attr_reader :app_redir_targets, :allowed_origins

		def app_target(app, ver)
			app = app.to_s
			t = lookup_app_redir_target(app)
			return nil if t.nil? || t[RedirTargetKeyName::TYPE] == RedirTargetType::NEVER
			return t if t[RedirTargetKeyName::TYPE] == RedirTargetType::ALWAYS

			# url = 'https://itunes.apple.com/lookup?bundleId=com.ketchapp.2048'
			url = 'https://itunes.apple.com/lookup?bundleId=' + app
			r = HTTPI.get_with_redir(url)
			# puts 'data retrieved from appstore:'
			# puts r.body
			return nil if r.code / 100 > 2 || r.headers['content-type'] !~ /json/
			version_info = JSON.parse(r.body)
			if version_info['resultCount'].to_i == 1
				ver_appstore = version_info['results'][0]['version'].to_f
				ver_current = ver.to_f
				# puts 'appstore version: ' + ver_appstore.to_s + ', current version: ' + ver_current.to_s
				# puts 'app target: %s' % Cuba.app_target(app)
				return t if ver_current <= ver_appstore
			end
		end # end of method app_target

		def load_config
			if File.exist?(AppConst::DEFAULT_CONFIG_PATH)
				@app_config = YAML.load(IO.read(AppConst::DEFAULT_CONFIG_PATH))
				@app_config = {} unless @app_config.is_a?(Hash)
				app_targets = @app_config[RedirTargetKeyName::KEY_]
				@app_redir_targets = app_targets if app_targets && app_targets.is_a?(Hash)
				allowed_origins = @app_config[AllowedOriginKeyName::KEY_]
				@allowed_origins = Regexp.new(allowed_origins) if allowed_origins && allowed_origins.is_a?(String)
			end
			if File.exist?(AppConst::LOCAL_CONFIG_PATH)
				@local_config = YAML.load(IO.read(AppConst::LOCAL_CONFIG_PATH))
				app_targets = @local_config[RedirTargetKeyName::KEY_]
				@local_app_redir_targets = app_targets if app_targets && app_targets.is_a?(Hash)
				allowed_origins = @local_config[AllowedOriginKeyName::KEY_]
				@allowed_origins = allowed_origins if allowed_origins && allowed_origins.is_a?(String)
			end
		rescue
			$stderr.puts 'load_config failed: '
			$stderr.puts $!.message
			$stderr.puts $@
		end

		def lookup_app_redir_target(app)
			t = @local_app_redir_targets[app]
			t && t.is_a?(Hash) ? t : @app_redir_targets[app]
		end

	end

	def url(addr = nil, absolute = true, add_script_name = true)
		return addr if addr =~ /\A[A-z][A-z0-9\+\.\-]*:/
		uri = [host = '']
		if absolute
			host << "http#{'s' if req.ssl? }://"
			if env.include?('HTTP_X_FORWARDED_HOST') || req.port != (req.ssl? ? 443 : 80)
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
		headers.select! { |k,v| v.is_a?(String) && k !~ /^access-control|transfer-encoding/ }
		headers.merge(merged || {} )
	end

	def cor_make_headers(request_headers, origin)
		merge = { 'Access-Control-Allow-Origin' => origin.to_s } if origin.to_s =~ self.class.allowed_origins
		return cor_merge_headers(request_headers, merge)
	end
end
