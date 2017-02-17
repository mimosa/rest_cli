# -*- encoding: utf-8 -*-
module Utils
  module Hash
    def to_query(params = self, prefix = nil)
      params.sort.map do |key, value|
        if value.nil? # Array
          key   = ''
          value = key
        end
        key = "#{prefix}[#{key}]" if prefix # Hash & Array

        if value.is_a?(Array) || value.is_a?(Hash)
          to_query(value, key)
        else
          "#{key}=#{value}"
        end
      end.join('&')
    end
  end
end
Hash.send(:include, Utils::Hash) unless Hash.respond_to?(:to_query)
