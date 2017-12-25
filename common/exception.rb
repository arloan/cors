#!/usr/bin/env ruby
# encoding: utf-8

class LogicError < ::StandardError
end

class ServerError < ::StandardError
end

class LicenseError < ServerError
end

class AuthError < ServerError
end
