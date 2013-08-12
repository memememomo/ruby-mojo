require 'rubygems'
require 'rspec'
require 'tempfile'

require 'mojo/event_emitter.rb'

describe "Mojo::EventEmitter" do

  before do
    @e = Mojo::EventEmitter.new
    @called = 0
      @echo = ""
      @err = ""
  end

  context 'Normal event' do
    it do
      @e.on('test1', proc { @called += 1 })
      @e.emit('test1')
      expect(@called).to eq(1)



      @e.on("die", proc { raise "works!\n" })
      expect { @e.emit('die') }.to raise_error("works!\n")



      @tempfile = Tempfile.open("stdouttest")
      $stderr = File.open(@tempfile, "w")
      @e.emit("error", "just")
      @e.emit_safe("error", "works")
      $stderr.flush
      $stderr = STDERR
      @error = "";
      File.open(@tempfile) {|f|
        @error += f.read
      }
      expect(@error).to eq("just\nworks\n")




      @e.on('error', proc {|args| @err = args.pop })
      @e.on('test2', proc {|args| @echo += 'echo: ' + args.pop })
      @e.on('test2', proc {|args|
              msg = args.pop
              raise "test2: #{msg}\n"
            })
      cb = proc {|args| @echo += 'echo2: ' + args.pop }
      @e.on('test2', cb)
      @e.emit_safe('test2', 'works!')
      expect(@echo).to eq("echo: works!echo2: works!")
      @echo = ""
      @err = ""
      expect(@e.subscribers('test2').length).to eq(3)
      @e.unsubscribe('test2', cb)
      expect(@e.subscribers('test2').length).to eq(2)
      @e.emit_safe('test2', 'works!')
      expect(@echo).to eq("echo: works!")
      expect(@err).to eq("Event \"test2\" failed: test2: works!\n")




      # Normal event again
      @e.emit('test1')
      expect(@called).to eq(2)
      expect(@e.subscribers('test1').length).to eq(1)
      @e.emit('test1')
      @e.unsubscribe('test1', @e.subscribers('test1')[0])
      expect(@called).to eq(3)
      expect(@e.subscribers('test1').length).to eq(0)
      @e.emit('test1')
      expect(@called).to eq(3)
      @e.emit('test1')
      expect(@called).to eq(3)



      # One-time event
      @once = 0
      @e.once('one_time', proc { @once += 1 })
      expect(@e.subscribers('one_time').length).to eq(1)
      @e.emit('one_time')
      expect(@once).to eq(1)
      expect(@e.subscribers('one_time').length).to eq(0)
      @e.emit('one_time')
      expect(@once).to eq(1)
      @e.emit('one_time')
      expect(@once).to eq(1)
      @e.emit('one_time')
      expect(@once).to eq(1)
      @e.once('one_time', proc {|args|
                obj = args.shift
                obj.once('one_time', proc { @once += 1 })
              })
      @e.emit('one_time')
      expect(@once).to eq(1)
      @e.emit('one_time')
      expect(@once).to eq(2)
      @e.emit('one_time')
      expect(@once).to eq(2)
      @e.once('one_time', proc {|args|
                obj = args[0]
                @once = obj.has_subscribers('one_time')
              })
      @e.emit('one_time')
      expect(@once).to eq(false)

      # Nested one-time events
      @once = 0
      @e.once('one_time', proc {
                |args|
                obj = args[0]
                obj.once('one_time', proc {
                           |args|
                           obj = args[0]
                           obj.once('one_time', proc { @once += 1 })
                         })
              })
      expect(@e.subscribers('one_time').length).to eq(1)
      @e.emit('one_time')
      expect(@once).to eq(0)
      expect(@e.subscribers('one_time').length).to eq(1)
      @e.emit('one_time')
      expect(@once).to eq(0)
      expect(@e.subscribers('one_time').length).to eq(1)
      @e.emit('one_time')
      expect(@once).to eq(1)
      expect(@e.subscribers('one_time').length).to eq(0)
      @e.emit('one_time')
      expect(@once).to eq(1)
      @e.emit('one_time')
      expect(@once).to eq(1)
      @e.emit('one_time')
      expect(@once).to eq(1)
    end
  end

  context 'Error' do
    it do
    end
  end

  context "Unhandled error event" do
    before do
    end

    it do
    end
  end

  context "Error fallback" do
    before do
    end

    it do
    end
  end

  context "Normal event again" do
    it do
    end
  end

end
