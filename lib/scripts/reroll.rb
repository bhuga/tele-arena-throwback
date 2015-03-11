module Scripts
  class Reroll

    attr_reader :conn

    def initialize(conn, *args)
      puts "got dat reroll going: #{args.inspect}"
      @conn = conn
      @count = 0

      unless args.size == 6 || args.size == 0
        puts "args aint 6!"
        return
      end

      if args.size == 0
        args = [22, 25, 15, 15, 19, 21]
      else
        bad_arg = args.find { |arg| arg !~ /\d+/ }
        if bad_arg
          puts "#{bad_arg} aint a number foo"
          return
        end
      end

      @target = args.map(&:to_i)
      @last_stats = ""
      puts "reroll registered"
      conn.send_command "st"
    end

    def on_input(data)
      @last_stats << data
      puts "checking #{@last_stats}"

      # "st" has completed"
      if @last_stats.include?("Encumberance")

        stats = parse_stats(@last_stats).map(&:to_i)

        pairs = stats.zip @target
        puts "pairs: #{pairs.inspect}"

        if pairs.all? { |a, b| a >= b }
          puts "WOOHOO WE ROLLED EM YO: only took #{@count} rerolls"
          conn.deregister_script self
          Process.exit!
        else
          puts "#{stats} not enough; rerolling"
          @last_stats = ""
          conn.send_command "reroll"
          @count += 1
        end
      end
    end

    def parse_stats(stats_output)
      rolled = []
      rolled[0] = stats_output.match(/Intellect:\s+(\d+)/)[1]
      rolled[1] = stats_output.match(/Knowledge:\s+(\d+)/)[1]
      rolled[2] = stats_output.match(/Physique:\s+(\d+)/)[1]
      rolled[3] = stats_output.match(/Stamina:\s+(\d+)/)[1]
      rolled[4] = stats_output.match(/Agility:\s+(\d+)/)[1]
      rolled[5] = stats_output.match(/Charisma:\s+(\d+)/)[1]
      rolled
    end
  end
end
