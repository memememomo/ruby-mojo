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

    def self.split_header(str)
      tree = []
      token = []
      while str.length > 0
        str = str.sub(/^[,;\s]*([^=;,]+)\s*/) {
          token.push($1)
          ""
        }
        token.push(nil)

        if str =~ /^=\s*("(?:\\\\|\\"|[^"])*"|[^;, ]*)\s*/
          token[-1] = unquote($1)
          str = str.sub(/^=\s*("(?:\\\\|\\"|[^"])*"|[^;, ]*)\s*/, "")
        end

        # Separator
        str = str.sub(/^;\s*/, '')
        if str !~ /^,\s*/
          next
        end
        str = str.sub(/^,\s*/, '')

        if token.length > 0
          tree.push(token)
          token = []
        end
      end

      # Take care of final token
      if token.length > 0
        tree.push(token)
      end

      tree
    end

    def self.unquote(str)
      str = str.gsub(/^"(.*)"$/, "#{$1}")
      str = str.gsub(/\\\\/, "\\")
      str = str.gsub(/\\"/, "\"")
      str
    end
  end
end
