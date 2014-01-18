require 'rubygems'
require 'rspec'

require 'mojo/util.rb'

describe 'Mojo::Util' do
  context '#camelize' do
    it do
      expect(Mojo::Util.camelize('foo_bar_baz')).to eq('FooBarBaz') # right camelized result
      expect(Mojo::Util.camelize('FooBarBaz')).to eq('FooBarBaz')   # right camelized result
      expect(Mojo::Util.camelize('foo_b_b')).to eq('FooBB')         # right camelized result
      expect(Mojo::Util.camelize('foo-b_b')).to eq('Foo::BB')       # right camelized result
      expect(Mojo::Util.camelize('FooBar')).to eq('FooBar')         # already camelized
      expect(Mojo::Util.camelize('Foo::Bar')).to eq('Foo::Bar')     # already camelized
    end
  end

  context '#decamelize' do
    it do
      expect(Mojo::Util.decamelize('FooBarBaz')).to eq('foo_bar_baz')   # right decamelized result
      expect(Mojo::Util.decamelize('foo_bar_baz')).to eq('foo_bar_baz') # right decamelized result
      expect(Mojo::Util.decamelize('FooBB')).to eq('foo_b_b')           # right decamelized result
      expect(Mojo::Util.decamelize('Foo::BB')).to eq('foo-b_b')         # right decamelized result
    end
  end

  context '#class_to_file' do
    it do
      expect(Mojo::Util.class_to_file('Foo::Bar')).to eq('foo_bar')         # right file
      expect(Mojo::Util.class_to_file('FooBar')).to eq('foo_bar')           # right file
      expect(Mojo::Util.class_to_file('FOOBar')).to eq('foobar')            # right file
      expect(Mojo::Util.class_to_file('FOOBAR')).to eq('foobar')            # right file
      expect(Mojo::Util.class_to_file('FOO::Bar')).to eq('foobar')          # right file
      expect(Mojo::Util.class_to_file('FooBAR')).to eq('foo_bar')           # right file
      expect(Mojo::Util.class_to_file("Foo'BAR")).to eq('foo_bar')          # right file
      expect(Mojo::Util.class_to_file("Foo'Bar::Baz")).to eq('foo_bar_baz') # right file
    end
  end

  context '#class_to_path' do
    it do
      expect(Mojo::Util.class_to_path('Foo::Bar')).to eq('Foo/Bar.pm')         # right path
      expect(Mojo::Util.class_to_path("Foo'Bar")).to eq('Foo/Bar.pm')          # right path
      expect(Mojo::Util.class_to_path("Foo'Bar::Baz")).to eq('Foo/Bar/Baz.pm') # right path
      expect(Mojo::Util.class_to_path("Foo::Bar'Baz")).to eq('Foo/Bar/Baz.pm') # right path
      expect(Mojo::Util.class_to_path("Foo'Bar'Baz")).to eq('Foo/Bar/Baz.pm')  # right path
    end
  end

  context '#get_line' do
    it do
      buffer = "foo\x0d\x0abar\x0dbaz\x0ayada\x0d\x0a"
      expect(Mojo::Util.get_line(buffer)).to eq('foo')        # right line
      expect(buffer).to eq("bar\x0dbaz\x0ayada\x0d\x0a")      # right line
      expect(Mojo::Util.get_line(buffer)).to eq("bar\x0dbaz") # right line
      expect(buffer).to eq("yada\x0d\x0a")                    # right line
      expect(Mojo::Util.get_line(buffer)).to eq("yada")       # right line
      expect(buffer).to eq("")                                # no line
    end
  end

  context '#split_header' do
    it do
      expect(Mojo::Util.split_header('')).to match_array [] # right result
      expect(Mojo::Util.split_header('foo=b=a=r')).to match_array [['foo', 'b=a=r']] # right result
      expect(Mojo::Util.split_header(',,foo,, ,bar')).to match_array [['foo', nil], ['bar', nil]] # right result
      expect(Mojo::Util.split_header(';;foo;; ;bar')).to match_array [['foo', nil, 'bar', nil]] # right result
      expect(Mojo::Util.split_header('foo=;bar=""')).to match_array [['foo', '', 'bar', '']] # right result
      expect(Mojo::Util.split_header('foo=bar baz=yada')).to match_array [['foo', 'bar', 'baz', 'yada']]
      expect(Mojo::Util.split_header('foo,bar,baz')).to match_array [['foo', nil], ['bar', nil], ['baz', nil]]
      expect(Mojo::Util.split_header('f "o" o , ba r')).to match_array [['f', nil, '"o"', nil, 'o', nil], ['ba', nil, 'r', nil]]
      expect(Mojo::Util.split_header('foo="b,; a\" r\"\\\\"')).to match_array [['foo', 'b,; a" r"\\']]
      expect(Mojo::Util.split_header('foo = "b a\" r\"\\\\"')).to match_array [['foo', 'b a" r"\\']]

      header = %q{</foo/bar>; rel="x"; t*=UTF-8'de'a%20b}
      tree = [['</foo/bar>', nil, 'rel', 'x', 't*', 'UTF-8\'de\'a%20b']]
      expect(Mojo::Util.split_header(header)).to match_array tree

      header = 'a=b c; A=b.c; D=/E; a-b=3; F=Thu, 07 Aug 2008 07:07:59 GMT; Ab;'
      tree   = [
        ['a', 'b', 'c', nil, 'A', 'b.c', 'D', '/E', 'a-b', '3', 'F', 'Thu'],
        [
          '07'      , nil, 'Aug', nil, '2008', nil,
          '07:07:59', nil, 'GMT', nil, 'Ab',   nil
        ]
      ];
      expect(Mojo::Util.split_header(header)).to match_array tree
    end
  end
end
