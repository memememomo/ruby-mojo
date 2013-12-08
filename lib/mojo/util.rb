# -*- coding: utf-8 -*-

module Mojo
  module Util
    def self.camelize(str)
      if str === /^[A-Z]/
        return str
      end
     
      # CamelCase words 
      str.split('-').map {|item1| 
        item1.split('_').map {|item2| item2.downcase.capitalize }.join('')
      }.join('::') 
    end
  end
end
