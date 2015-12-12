module MonopolyEngine
	class Player
		attr_accessor :hits, :board, :name, :currency, :history, :properties, :in_game, :turns_in_jail, :behaviour, :game, :jail_free_cards
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
			@behaviour = args[:behaviour]
			self
		end
		def in_jail?
			@in_jail
		end
		def opponents
			@game.players.reject{ |p| p == self }
		end
		def num_houses
			@properties.select {|p| p.is_a? BasicProperty }.collect(&:num_houses).inject(:+) || 0
		end
		def num_hotels
			@properties.select {|p| p.is_a? BasicProperty }.collect(&:num_hotels).inject(:+) || 0
		end
		def sets_owned
			@properties.select{ |p| p.is_a? BasicProperty }.select(&:set_owned?).group_by { |p| p.set }.keys
		end
		def in_jail=(bool)
			@in_jail = bool
			@turns_in_jail = 0 if bool == false
		end
		def distance_to_go
			index = @board.collect(&:name).find_index('GO')
			index == 0 ? @board.length : index
		end

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
		def current_square
			@board[0]
		end
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
			out
		end
		def money_trouble(amount)
			puts '[%s] Has money trouble and is trying to raise £%d... (balance: £%d)' % [ @name, (amount - @currency), @currency ]
			@behaviour[:money_trouble].call(game, self, amount)
		end
		def out
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
		def roll
			Array.new(@game.num_dice).collect { Random.rand(1..@game.die_size) }
		end
	end
end
