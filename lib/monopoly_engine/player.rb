module MonopolyEngine
	# Represents a player
	class Player
		attr_accessor :hits, :board, :name, :currency, :history, :properties, :in_game, :turns_in_jail, :behaviour, :game, :jail_free_cards
		# @return [Player] self
		# @param [Hash] args
		# @option opts [Hash] :behaviour Behaviour has describing this player's reaction to certain in-game situations. See Behaviour class.
		# @option opts [String] :name The name of the player
		def initialize(args)
			@history = []
			@in_game = true
			@in_jail = false
			@turns_in_jail = 0
			@jail_free_cards = 0
			@currency = 0
			@game = nil
			@name = args[:name]
			@board = []
			@properties = []
			@behaviour = args[:behaviour] || MonopolyEngine::Behaviour::DEFAULT
			self
		end

		# @return [Boolean] whether or not this player is currently in jail.
		def in_jail?
			@in_jail
		end
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
			n = @board.collect(&:name).find_index(n) if n.is_a? String

			case direction
			when :forwards
				if n >= distance_to_go
					unless in_jail?
						puts '[%s] Passed GO' % @name
						@game.pay_player(self, @game.go_amount, 'passing go')
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
		def bankrupt!(player = nil)
			if player == nil
				puts '[%s] Bankrupt! Giving all assets to bank' % @name
				@properties.each do |property|
					property.owner = nil
					property.is_mortgaged = false
				end

				@properties = []
			else
				puts '[%s] Bankrupt! Giving all assets to %s' % [ @name, player.name ]
				@properties.each { |p| p.owner = player }
				puts '[%s] Transferred properties to %s: %s' % [ @name, player.name, @properties.collect { |p| p.name }.join(', ') ]
				player.properties.concat @properties unless player == nil
				@properties = []
			end
			out!
		end

		# Called when a player is unable to pay a debt. Calls the 'money_trouble' behaviour.
		def money_trouble(amount)
			puts '[%s] Has money trouble and is trying to raise £%d... (balance: £%d)' % [ @name, (amount - @currency), @currency ]
			@behaviour[:money_trouble].call(game, self, amount)
		end

		# Declares a player as out of the game.
		def out!
			puts '[%s] is out of the game!' % @name
			@in_game = false
		end
		def is_out?
			! @in_game
		end
		def use_jail_card!
			if @jail_free_cards > 0
				puts "[%s] Used a 'get out of jail free' card!" % @name
				@in_jail = false
				@turns_in_jail = 0
				@jail_free_cards = @jail_free_cards - 1
			end
		end
		def pay(beneficiary = :bank, amount = 0, description = nil)
			money_trouble(amount) if @currency < amount
			amount_to_pay = ( @currency >= amount ? amount : @currency )

			case beneficiary
			when :bank
				@game.bank_balance = @game.bank_balance + amount_to_pay
				paying_to = 'bank'
			when :free_parking
				@game.free_parking_balance = @game.free_parking_balance + amount_to_pay
				paying_to = 'free parking'
			when Player
				beneficiary.currency = beneficiary.currency + amount_to_pay
				paying_to = beneficiary.name
			end

			@currency = @currency - amount_to_pay

			if amount_to_pay < amount then			
				puts '[%s] Unable to pay £%d to %s%s! Paid £%d instead' % [ @name, amount, paying_to, ( description ? ' for %s' % description : '' ), amount_to_pay ]
				bankrupt!(beneficiary)
			else
				puts '[%s] Paid £%d to %s%s (balance: £%d)' % [ @name, amount, paying_to, ( description ? ' for %s' % description : '' ), @currency ]
				true
			end

		end

		# Roll the dice!
		# @return [Array<Integer>] dice roll as an array of num_dice integers between 1 and die_size.
		def roll
			Array.new(@game.num_dice).collect { Random.rand(1..@game.die_size) }
		end
	end
end
