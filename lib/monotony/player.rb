module Monotony
	# Represents a player, an extension of the Entity class.
	class Player < Entity
		attr_accessor :hits, :board, :name, :history, :properties, :in_game, :turns_in_jail, :behaviour, :game, :jail_free_cards, :in_jail, :personality

		# @return [Player] self
		# @param [Hash] opts
		# @option opts [Hash] :behaviour Behaviour has describing this player's reaction to certain in-game situations. See Behaviour class.
		# @option opts [String] :name The name of the player.
		# @option opts [Integer] :balance The opening balance of this player's account.
		# @option opts [Integer] :jail_free_cards The number of jail-free cards the player begins with.
		def initialize(opts = {})
			random_player_names = %w{Andy Brian Katie Cathy Tine Jody James Ryan Lucy Pierre Olu Gregor Tracy Lia Andoni Ralph San Omar}

			opts = {
				jail_free_cards: 0,
				in_jail: false,
				name: random_player_names.sample,
				behaviour: Monotony::DefaultBehaviour.new,
				personality: Personality.new({})
			}.merge(opts)

			@in_jail = false
			@turns_in_jail = 0
			@jail_free_cards = opts[:jail_free_cards].to_int
			@personality = opts[:personality]
			super
		end
		
		def simulate
			SimulatedPlayer.new(self)
		end

		# @return [Boolean] whether or not this player is currently in jail.
		def in_jail?
			@in_jail
		end

		# @return [Array<Player>] an array of all other players in the game.
		def opponents
			@game.players.reject{ |p| p == self }
		end

		# @return [Integer] the number of houses on properties owned by this player.
		def num_houses
			@properties.select { |p| p.is_a? BasicProperty }.collect(&:num_houses).inject(:+) || 0
		end

		# @return [Integer] the number of hotels on properties owned by this player.
		def num_hotels
			@properties.select { |p| p.is_a? BasicProperty }.collect(&:num_hotels).inject(:+) || 0
		end

		# @return [Integer] the number of property sets owned by this player.
		def sets_owned
			@properties.select { |p| p.is_a? BasicProperty }.select(&:set_owned?).group_by { |p| p.set }.keys
		end

		# Sets whether or not this player is currently in jail.
		# @param [Boolean] bool True for in jail, False for out of jail. 
		def in_jail=(bool)
			@in_jail = bool
			@turns_in_jail = 0 unless bool
		end

		# @return [Integer] the number of squares between this player's current position on the board, and the GO square.
		def distance_to_go
			index = @board.collect(&:name).find_index('GO')
			index == 0 ? @board.length : index
		end

		# Moves a player on the game board.
		# @param [Integer] n Number of squares to move.
		# @param [Symbol] direction :forwards or :backwards.
		# @return [Square] the square the player has landed on.
		def move(n = 1, direction = :forwards)
			direction = direction.to_sym
			n = @board.collect(&:name).find_index(n) if n.is_a? String

			case direction
			when :forwards
				if n >= distance_to_go
					unless in_jail?
						@game.log '[%s] Passed GO' % @name
						Transaction.new(from: game.bank, to: self, reason: 'passing go', amount: @game.go_amount)
					end
				end

				(n % @board.length).times {
					@board.push @board.shift
				}
			when :backwards
				n = @board.length - n
				(n % @board.length).times {
					@board.unshift @board.pop
				}
			end

			@history << @board[0].name
			@board[0]
		end

		# @return [Square] The square this player is currently on.
		def current_square
			@board[0]
		end

		# Declares a player as bankrupt, transferring their assets to their creditor.
		# @param player [Player] the player to whom this player's remaining assets will be transferred. If nil, assets are given to the bank instead.
		def bankrupt!(player = @game.bank)
			if player == @game.bank
				@game.log '[%s] Bankrupt! Giving all assets to bank' % @name
				@properties.each do |property|
					property.owner = nil
					property.is_mortgaged = false
				end

				@properties = []
			else
				@game.log '[%s] Bankrupt! Giving all assets to %s' % [ @name, player.name ]
				@properties.each { |p| p.owner = player }
				@game.log '[%s] Transferred properties to %s: %s' % [ @name, player.name, @properties.collect { |p| p.name }.join(', ') ]
				player.properties.concat @properties unless player == nil
				@properties = []
			end
			out!
		end

		# Declares a player as out of the game.
		def out!
			@game.log '[%s] is out of the game!' % @name
			@in_game = false
		end

		# @return [Boolean] whether or not this player has been eliminated from the game.
		def is_out?
			not @in_game
		end

		# Use a 'get out of jail free' card to exit jail.
		# @return [Boolean] whether the player was both in jail and had an unused jail card available.
		def use_jail_card!
			if @jail_free_cards > 0 and @in_jail
				@game.log "[%s] Used a 'get out of jail free' card!" % @name
				@in_jail = false
				@turns_in_jail = 0
				@jail_free_cards = @jail_free_cards - 1
				true
			else
				false
			end
		end

		# Calculate a forecast of the player's exposure on their next turn.
		# @return [Array<Integer>] A forecast of possible exposure based on different dice rolls.
		# @param [Integer] num_squares The number of squares ahead to forecast.
		def exposure(num_squares = (@game.die_size * @game.num_dice))
			# FIXME: Add capability to simulate more than the board's size worth of squares
			debits = []
			credits = []
			@game.board[0..num_squares-1].each do |this_square|
        simulated_player = self.simulate
        simulated_game = simulated_player.game

        simulated_square = this_square.simulate
				simulated_square.action(game: simulated_game, player: simulated_player)

				debits << Transaction.all.select { |t| t.from == simulated_player.account }.collect { |t| t.amount }.inject(:+)
				credits << Transaction.all.select { |t| t.to == simulated_player.account }.collect { |t| t.amount }.inject(:+)
			end

			# Flip the sign for debits, remove nils, append them to credits, then sort the whole array
			forecast = credits.reject(&:nil?).concat( debits.reject(&:nil?).collect { |d| 0 - d } ).sort
			@game.log '[%s] (AI) Forecast: Worst £%d %s (%s), Best £%d %s (%s) on next roll' % [ @name, forecast.min.abs, (forecast.min > 0 ? 'up' : 'down'), 'unknown', forecast.max.abs, (forecast.max > 0 ? 'up' : 'down'), 'unknown' ]
			forecast
		end

		def exposure_to(player)

		end

		# Called when a player is unable to meet his debts and needs to raise cash to stay in the game.
		# @param [Integer] amount The amount of cash still to be raised
		# @return [void]
		def short_of_cash(amount)
			super
			act(:liquidate, amount: amount)
			@account.balance > amount
		end

		# Roll the dice!
		# @return [Array<Integer>] dice roll as an array of num_dice integers between 1 and die_size.
		def roll
			Array.new(@game.num_dice).collect { Random.rand(1..@game.die_size) }
		end
	end
end
