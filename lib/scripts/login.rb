require_relative "plugins/sequential"

module Scripts
  class Login
    include Plugins::Sequential

    attr_reader :conn

    def initialize(conn, *args)
      puts "logging in!"
      @conn = conn

      sequentially.waitfor('Otherwise type')
        .respond(ENV["DEFAULT_USER"])
        .then('Enter your password:')
        .respond(ENV["DEFAULT_PASS"])
        .then('(N)onstop, (Q)uit, or (C)ontinue?')
        .respond("q")
        .then('X to exit):')
        .respond("g")
        .then('Doors Menu (Games)')
        .respond('3')
    end

    def on_input(data)
      super
    end

    def after_sequential
      conn.deregister_script(self)
    end
  end
end
