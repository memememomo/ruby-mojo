# -*- coding: utf-8 -*-

module Mojo
  # == NAME
  #
  # Mojo::EventEmitter - Event emitter base class
  #
  # == SYNOPSIS
  #
  #   class Cat < Mojo::EventEmitter
  #       def poke
  #           self.emit('roar', 3)
  #       end
  #   end
  #
  #   tiger = Cat.new
  #   tiger.on('roar', proc {|tiger, args|
  #        times = args.pop
  #        times.times{
  #            puts 'RAWR!'
  #        }
  #   })
  #   tiger.poke
  #
  # == DESCRIPTION
  #
  # <em>Mojo::EventEmitter</em> is a simple base class for event emitting objects.
  #
  # == EVENTS
  #
  # <em>Mojo::EventEmitter</em> can emit the following events. 
  #
  # === error
  #
  #
  #   @e.on('error', proc {|e, args|
  #       err = args.pop
  #       ...
  #   })
  #
  # Emitted for event errors, fatal if unhandled.
  #
  #   @e.on('error', proc {|e, args|
  #       err = args.pop
  #       puts "This Looks bad: #{err}"
  #   })
  #
  # == DEBUGGING
  #
  # You can set the MOJO_EVENTEMITTER_DEBUG environment variable to get some
  # advanced diagnostics information printed to <tt>STDERR</tt>.
  #
  #  MOJO_EVENTEMITTER_DEBUG=1
  #
  class EventEmitter
    DEBUG = ENV["MOJO_EVENTEMITTER_DEBUG"] || 0

    def initialize
      @events = Hash.new
    end

    #
    #  e = e.emit('foo')
    #  e = e.emit('foo', 123)
    #
    # Emit event.
    #
    def emit(name, *args)
      if s = @events[name] then
        warn "-- Emit #{name} in \n" if DEBUG == 1
        s.each do |cb|
          cb.call(self, args.clone)
        end
      else
        warn "-- Emit #{name} in " if DEBUG == 1
        warn args[0] if name == "error"
      end

      self
    end

    #
    #  e = e.emit_safe('foo')
    #  e = e.emit_safe('foo', 123)
    # 
    # Emit event.
    #
    def emit_safe(name, *args)

      if s = @events[name] then
        warn "-- Emit #{name} in \n" if DEBUG == 1
        s.each do |cb|
          begin
            cb.call(self, args.clone)
          rescue Exception => ex
            if name == "error" then
              # Error event failed
              warn "Event \"error\" failed: " + ex.message
            else
              # Normal event failed
              self.emit_safe('error', "Event \"#{name}\" failed: " + ex.message)
            end
          end
        end
      else
        warn "-- Emit #{name} in \n" if DEBUG == 1
        warn args[0] if name == "error"
      end

      self
    end

    #
    #  bool = e.has_subscribers('foo')
    #
    # Check if event has subscribers.
    #
    def has_subscribers(name)
      self.subscribers(name).length > 0 ? true : false
    end

    #
    #  cb = e.on('foo', proc {|e, args|
    #      ...
    #  })
    #
    # on
    def on(name, cb)
      @events[name] ||= Array.new
      @events[name].push(cb)
      cb
    end

    #
    #  cb = e.once('foo', proc { ... })
    #
    # Subscribe to event and unsubscribe again after it has been emitted once.
    #
    #  e.once('foo', proc {|e, args|
    #      ...
    #  })
    #
    def once(name, cb, *args)
      wrapper = proc {
        self.unsubscribe(name, wrapper)
        cb.call(self, args.clone)
      }
      self.on(name, wrapper)

      wrapper
    end

    #
    #  subscribers = e.subscribers('foo')
    #
    # All subscribers for event
    #
    #  # Unsubscribe last subscriber
    #  e.unsubscribe('foo', e.subscribers('foo')[-1])
    #
    def subscribers(name)
      @events[name] ||= Array.new
      @events[name]
    end

    #
    #  e = e.unsubscribe('foo')
    #  e = e.unsubscribe('foo', cb)
    #
    # Unsubscribe from event.
    #
    def unsubscribe(name, cb = nil)

      if cb then
        # One
        l = Array.new
        @events[name].each{|o|
          if o != cb then
            l.push(o)
          end
        }
        @events[name] = l
      else
        # All
        @events.delete(name)
      end

      self
    end
  end
end
