#!/usr/bin/env ruby
# encoding: utf-8


class TrueClass
  def bool?
    self
  end
end

class FalseClass
  def bool?
    self
  end
end

class NilClass
  def bool?; false; end
end

class String
  def bool?(default = false)
    return false if empty?
    return true if self =~ /^(?:t|true|yes|OK|good|success)$|^[+-]?[1-9][0-9]*$/i
    return false if self =~ /^(?:f|false|no|fail|wrong|bad|0)$/i
    return default
  end
end
