# -*- encoding: utf-8 -*-

module Utils
  module Hash
    def to_query(params = self, prefix = nil)
      params.sort.map do |key, value|
        key, value = '', key      if value.nil? # Array
        key = "#{prefix}[#{key}]" if prefix # Hash & Array

        if value.kind_of?(Array) || value.kind_of?(Hash)
          self.to_query(value, key)
        else
          "#{key}=#{value}"
        end
      end.join('&')
    end
  end
end
Hash.send(:include, Utils::Hash) unless Hash.respond_to?(:to_query)