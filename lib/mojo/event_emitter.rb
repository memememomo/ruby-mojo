module Mojo
  class EventEmitter
    DEBUG = ENV["MOJO_EVENTEMITTER_DEBUG"] || 0

    def initialize
      @events = Hash.new
    end

    def emit( *args )
      name = args.shift
      if s = @events[name] then
        warn "-- Emit #{name} in \n" if DEBUG == 1
        s.each do |cb|
          cb.call(args.clone.unshift(self))
        end
      else
        warn "-- Emit #{name} in " if DEBUG == 1
        warn args[0] if name == "error"
      end

      self
    end

    def emit_safe( *args )
      name = args.shift

      if s = @events[name] then
        warn "-- Emit #{name} in \n" if DEBUG == 1
        s.each do |cb|
          begin
            cb.call(args.clone.unshift(self))
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

    def has_subscribers(name)
      self.subscribers(name).length > 0 ? true : false
    end

    def on(name, cb)
      @events[name] ||= Array.new
      @events[name].push(cb)
      cb
    end

    def once(*args)
      name = args.shift
      cb = args.shift

      wrapper = proc {
        self.unsubscribe(name, wrapper)
        cb.call(args.clone.unshift(self))
      }
      self.on(name, wrapper)

      wrapper
    end

    def subscribers(name)
      @events[name] ||= Array.new
      @events[name]
    end

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
