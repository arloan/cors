# encoding: utf-8

class NilClass
  def empty?; true; end
end

class Array
  def empty?
    return length == 0
  end
end

class Hash
  def empty?
    return size == 0
  end
end

class String
	def empty?
		return length == 0
	end
end

class Numeric
	def empty?
		return self == 0
	end
end
