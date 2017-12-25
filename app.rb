#!/usr/bin/env ruby
# encoding: utf-8

require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)

require 'digest'
# require 'cuba/render'

# https://github.com/elcuervo/cuba-sugar
#require 'cuba/sugar/content_for'
require 'cuba/sugar/as'

require 'common/app_const'
require 'common/exception'
require 'common/security_agent'
require 'extension/extension'


# Cuba.use Rack::Session::Cookie, :secret => '#_____a_really_long_string_____#'
Cuba.use Rack::Protection::RemoteReferrer
Cuba.use Rack::Protection, except: [:session_hijacking, :remote_token]

#Cuba.plugin Cuba::Sugar::ContentFor
Cuba.plugin Cuba::Sugar::As
# Cuba.plugin Cuba::Render
# Cuba.settings[:render][:template_engine] = 'haml'

# helpers
require 'helpers'

# routes in all controller
#require 'controller/generic'
#require 'controller/serial'

module HTTPI
  class << self
    def get_with_redir(request, adapter = nil, &block)
      request = Request.new(request) if request.kind_of? String
      request.follow_redirect = true
      request(:get, request, adapter, &block)
    end
  end
end

Cuba.load_config
Cuba.define do
	on get do
		on root do
			# as { partial('index') }
      res.write '<h1>Hello!</h1>'
    end

    on /cor\/https?:\/.+/ do
      # puts 'full request uri: ' + env['REQUEST_URI']
      # puts 'query: ' + env['QUERY_STRING']
      # puts JSON.pretty_generate(env)
      url = env['REQUEST_URI'][/http.+/]
      # puts 'target url: '+ url
      r = HTTPI.get_with_redir(url)
      origin = env['Origin'] || env['HTTP_ORIGIN']
      as r.code, cor_make_headers(r.headers, origin) do #http://localhost:8100
        r.body || ''
      end
    end

    on /wp-media-v2\/https?:\/.+/ do
      url = env['REQUEST_URI'][/http.+/]
      r = HTTPI.get_with_redir(url)
      data = r.body
      if r.code / 100 == 2 && r.headers['content-type'] =~ /json/
        data = JSON.parse(data)
        data = data.path_lookup('guid.rendered')
        res.redirect data
      else
        not_found
      end
    end

    on 'togo', param('app'), param('ver') do |app, ver|
      target = Cuba.app_target(app, ver)
      if target
        as 200, cor_merge_headers(res.headers, { 'Access-Control-Allow-Origin' => '*' }) do
          target
        end
      end
    end

		on 'env' do
      res.write '<pre>'
      res.write JSON.pretty_generate(env.select {|k,_v| k != 'PASSENGER_CONNECT_PASSWORD' })
      res.write '</pre>'
    end

  end # on get

  on put do
    on 'reload-config' do
      Cuba.load_config
      res.status = 204
    end
  end

end # Cuba.define
