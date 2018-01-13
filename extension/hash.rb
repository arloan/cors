# encoding: utf-8

class Hash
	def path_lookup(path)
		return nil if path == nil || path.to_s.empty?
		path = path.to_s
		path_list = path.split('.')

		o = self
		path_list.each_with_index do |pe, idx|
			o = o[pe] || o[pe.to_sym]
			return nil if o == nil || !o.is_a?(Hash) && idx < path_list.length - 1
		end
		o
	end
end
