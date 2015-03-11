require 'socket'
require 'pp'
require 'set'

class Connection
  attr_reader :socket, :input_buffer, :recently_sent_messages, :scripts

  def initialize(host, port = 23)
    @socket = Socket.tcp host, port
    @scripts = []
    @socket.connect Socket.pack_sockaddr_in(port, host)

    @input_buffer = Queue.new
    @recently_sent_messages = Set.new

    Thread.new do
      while true
        begin
          data = @socket.readpartial 4096
          if data
            recently_sent_messages.find_all { |m| data.include?(m) }.each do |m|
              data = data.gsub(m, "")
              recently_sent_messages.delete(m)
            end
          end

          $stdout.write data
          scripts.each do |script|
            script.on_input(data)
          end
          $stdout.flush
        rescue IO::WaitReadable
          IO.select(@socket)
        rescue EOFError
          puts "disconnected"
          exit("game over man game over")
        rescue Exception => e
          puts e.class
          puts e.backtrace
          puts e.message
        end
      end
    end

    Thread.new do
      begin
        while data = input_buffer.pop
          @socket.write "#{data}"
          recently_sent_messages << data unless data =~ /^\s+$/
          @socket.flush
        end
      rescue Exception => e
        puts e.class
        puts e.message
        puts e.backtrace
      end
    end
  end

  def send(data)
    if data.start_with?("script")
      run_script(data)
    else
      input_buffer << data
    end
  end

  def send_command(string)
    send("#{string}\r\n")
  end

  def register_script(script)
    @scripts << script
  end

  def deregister_script(script)
    @scripts.delete script
  end

  def run_script(script_command)
    _, script, args = script_command.split(/\s+/, 3)
    args = args.split(/\s+/)
    puts "running script: #{script} #{args.inspect}"
    load "scripts/#{script}.rb"
    Scripts.const_get(script.camelize).new(self, *args)
    puts "script run!"
  end

  def blocking_read_loop!
    $stdin.echo = true

    while line = $stdin.gets
      line = line.gsub "\n", "\r\n"
      send line
    end
  end
end
