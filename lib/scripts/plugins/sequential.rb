require "active_support/core_ext/module/aliasing"

module Plugins
  module Sequential
    class Sequence
      attr_accessor :patterns, :script, :received_data
      def initialize(script)
        @patterns = []
        @script = script
        @received_data = ""
      end

      def waitfor(string)
        patterns << [string]
        self
      end
      alias_method :then, :waitfor

      def respond(string)
        patterns.last << string
        self
      end

      def on_input(data)
        received_data << data
        if index = received_data.index(patterns.first.first)
          tuple = patterns.shift
          script.conn.send(tuple.last + "\r\n")
          script.after_sequential if patterns.empty?
        end
      end
    end

    def sequentially
      @sequences ||= []
      seq = Sequence.new(self)
      @sequences << seq
      seq
    end

    def on_input(data)
      @sequences.each do |seq|
        seq.on_input(data)
      end
    end
  end
end
