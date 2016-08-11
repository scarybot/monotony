module Monotony
	# Represents a player
	class Player < Entity
		attr_accessor :hits, :board, :name, :history, :properties, :in_game, :turns_in_jail, :behaviour, :game, :jail_free_cards, :in_jail

		# @return [Player] self
		# @param [Hash] args
		# @option opts [Hash] :behaviour Behaviour has describing this player's reaction to certain in-game situations. See Behaviour class.
		# @option opts [String] :name The name of the player.
		# @option opts [Integer] :currency A currency adjustment for this player (positive or negative).
		# @option opts [Integer] :jail_free_cards The number of jail-free cards the player begins with.
		def initialize(opts = {})
			random_player_names = %w{Andy Brian Katie Cathy Tine Jody James Ryan Lucy Pierre Olu Gregor Tracy Lia Andoni Ralph San Omar}

			opts = {
				jail_free_cards: 0,
				in_jail: false,
				name: random_player_names.sample,
			}.merge(opts)

			@in_jail = false
			@turns_in_jail = 0
			@jail_free_cards = opts[:jail_free_cards].to_int
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
			@turns_in_jail = 0 if bool == false
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
			! @in_game
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

		# Transfer currency to another player, or the bank.
		# @return [Boolean] whether or not the player was able to pay the amount requested. False indicates bancruptcy.
		# @param [Symbol] beneficiary target Player instance or :bank.
		# @param [Integer] amount amount of currency to transfer.
		# @param [String] description Reference for the transaction (for game log).
		# def pay(beneficiary = @game.bank, amount = 0, description = nil)
		# 	Transaction.new(from: self, to: beneficiary, reason: description, amount: amount_to_pay)
		# end

		def exposure(num_squares = (@game.die_size * @game.num_dice))
			# FIXME: Add capability to simulate more than the board's size worth of squares
			# fees = {}
			# @game.board[0..num_squares-1].each do |this_square|
			# 	simulated_square = this_square.clone
			# 	simulated_game = @game.clone
			# 	simulated_player = self.simulate
			# 	simulated_square.action.call(simulated_game, simulated_square.owner, simulated_player, simulated_square)
			# 	this_fee = simulated_player.transactions.inject(:+)
			# 	fees[simulated_square.name] = this_fee.to_i unless this_fee.nil?
			# end
			# sorted_fees = fees.sort_by{ |k, v| v }
			# best_fee = sorted_fees.last || [ 'null', 0 ]
			# worst_fee = sorted_fees.first || [ 'null', 0 ]
			# @game.log '[%s] (AI) Forecast: Worst £%d %s (%s), Best £%d %s (%s), Average £%d %s on next roll' % [ @name, worst_fee[1].abs, (worst_fee[1].to_int > 0 ? 'up' : 'down'), worst_fee[0], best_fee[1].abs, (best_fee[1].to_int > 0 ? 'up' : 'down'), best_fee[0], (fees.values.inject(:+) / fees.values.size).to_int.abs, ((fees.values.inject(:+) / fees.values.size).to_int > 0 ? 'up' : 'down') ]
			# sorted_fees.collect { |f| - f[1] }
			[0]
		end

		def exposure_to(player)

		end

		# Roll the dice!
		# @return [Array<Integer>] dice roll as an array of num_dice integers between 1 and die_size.
		def roll
			Array.new(@game.num_dice).collect { Random.rand(1..@game.die_size) }
		end
	end
end
