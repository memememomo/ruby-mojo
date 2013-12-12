# -*- coding: utf-8 -*-

module Mojo
  module Util
    def self.camelize(str)
      if str =~ /^[A-Z]/
        return str
      end

      # CamelCase words 
      str.split('-').map {|item1| 
        item1.split('_').map {|item2| item2.downcase.capitalize }.join('')
      }.join('::') 
    end

    def self.decamelize(str)
      if str !~ /^[A-Z]/
        return str
      end

      # Module parts
      parts = []
      str.split('::').each do |part|
        words = []
        part.scan(/[A-Z]{1}[^A-Z]*/).each do |p|
          words.push(p.downcase)
        end
        parts.push(words.join('_'))
      end

      parts.join('-')
    end

    def self.class_to_file(class_str)
      class_str = class_str.gsub(/(::|')/, '')
      class_str = class_str.gsub(/([A-Z])([A-Z]*)/) { "#{$1}" + "#{$2}".downcase }
      decamelize(class_str)
    end

    def self.class_to_path(class_str)
      class_str.split(/::|'/).join('/') + '.' + 'pm'
    end

    def self.get_line(str)

      # Locate line ending
      if (pos = str.index("\x0a")) == nil 
        return nil
      end

      # Extract line and ending
      line = str.slice(0, pos + 1)
      str[0..pos] = '' 
      line = line.sub(/\x0d?\x0a$/, '')

      line
    end
  end
end
