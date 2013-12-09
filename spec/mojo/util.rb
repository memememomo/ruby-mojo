require 'rubygems'
require 'rspec'

require 'mojo/util.rb'

describe 'Mojo::Util' do
  context '#camelize' do
    it do
      expect(Mojo::Util.camelize('foo_bar_baz')).to eq('FooBarBaz') # right camelized result
      expect(Mojo::Util.camelize('FooBarBaz')).to eq('FooBarBaz')   # right camelized result
      expect(Mojo::Util.camelize('foo_b_b')).to eq('FooBB')         # right camelized result
      expect(Mojo::Util.camelize('foo-b_b')).to eq('Foo::BB')         # right camelized result
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
end
