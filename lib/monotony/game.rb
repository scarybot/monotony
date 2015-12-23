module Monotony
	# Contains the main game engine logic.
	class Game
		# @return [Hash] Returns a hash containing the number of times each Square has been landed on.
		attr_accessor :hits
		# @return [Array<Square>] the current game board.
		attr_accessor :board
		# @return [Boolean] players registered to the game.
		attr_accessor :players
		attr_accessor :num_dice, :die_size, :starting_currency, :chance, :community_chest, :bank_balance, :free_parking_balance, :player_starting_balance, :go_amount, :max_turns_in_jail, :last_roll, :num_houses, :num_hotels
		# @return [Boolean] whether or not the game has been completed.
		attr_accessor :completed
		# @return [Array<Purchasable>] properties yet to be purchased by players.
		attr_accessor :available_properties

		# @return [Integer] the current turn number.
		attr_accessor :turn

		# Creates a new Monopoly game
		# @param [Hash] opts Game configuration options
		# @option opts [Integer] :free_parking_balance The amount of money stored on Free Parking at the beginning of the game (unofficial game feature in widespread use).
		# @option opts [Integer] :bank_balance Starting balance of the bank.
		# @option opts [Integer] :max_turns_in_jail The maximum number of turns a player may spend in jail before being forced to pay a fine to leave.
		# @option opts [Integer] :go_amount The amount of money given to a player when they pass GO.
		# @option opts [Integer] :num_dice  The number of dice a player will roll on their turn.
		# @option opts [Integer] :die_size The number of sides per dice.
		# @option opts [Integer] :num_houses The total number of houses available to be purchased.
		# @option opts [Integer] :num_hotels The total number of hotels available to be purchased
		# @option opts [Integer] :starting_currency The amount of currency given to each player at the start of the game.
		# @option opts [Integer, Array<Player>] :players If an array of Player objects are given, then add them to the game. If an integer is given, generate that number of players with default options, and add those to the game instead. 
		# @return [String] the object converted into the expected format.
		def initialize(opts)
			opts = {
				free_parking_balance: 0,
				bank_balance: 12755,
				max_turns_in_jail: 3,
				go_amount: 200,
				num_dice: 2,
				die_size: 6,
				num_houses: 48,
				num_hotels: 12,
				starting_currency: 1500,
				players: 4,
				variant: Monotony::DefaultLayout
			}.merge(opts)

			random_player_names = %w{Andy Brian Katie Cathy Tine Jody James Ryan Lucy Pierre George Gregor Tracy Lia Andoni Ralph San}

			@board = opts[:variant]::BOARD
			@chance_all = opts[:variant]::CHANCE
			@community_chest_all = opts[:variant]::COMMUNITY_CHEST

			@hits = {}
			@turn = 0
			@bank_balance = opts[:bank_balance] 
			@free_parking_balance = opts[:free_parking_balance]
			@max_turns_in_jail = opts[:max_turns_in_jail]
			@last_roll = 0
			@go_amount = opts[:go_amount]
			@initial_board = @board
			@available_properties = @board
			@chance = @chance_all.shuffle
			@community_chest = @community_chest_all.shuffle
			@num_dice = opts[:num_dice]
			@num_houses = opts[:num_houses] 
			@num_hotels = opts[:num_hotels] 
			@die_size = opts[:die_size]
			@starting_currency = opts[:starting_currency]
			@variant = opts[:variant]

			case opts[:players]
				when Integer
					@players = []
					opts[:players].times do
						@players << Monotony::Player.new(name: random_player_names.sample)
					end
				when Array
					@players = opts[:players]
			end
			@completed = false
			@board.each do |square|
				@hits[square] = 0
			end
			@players.each do |player|
				player.board = @board.clone
				player.currency = opts[:starting_currency]
				player.game = self
			end
			self
		end

		# @return [Array<Symbol>] the names of completed property sets currently owned by players
		def all_sets_owned
			@board.select{ |p| p.is_a? BasicProperty }.select { |p| p.set_owned? }.group_by { |p| p.set }.keys
		end

		# Produces a colourful ASCII representation of the state of the game board to standard output.
		# The string produced contains ANSI colours.
		# @return [String] game summary.
		# @example Show a summary of a game in progress
		#    game.summary
		def summary
			summary = Array.new(6) { '' }
				position = 0
				header = ''

				worth = @players.collect { |p| '%s: £%d' % [ p.name, p.currency ]}
				header << 'Balances: %s' % worth.join(', ')
				puts header
				puts

				@board.each do |property|
					if position % 10 == 0 and position > 0
						puts summary.collect! { |s| s << "\n" }
						puts

						summary.collect! { '' }
					end
					if property.owner
						owner_string = ( '%7s ' % property.owner.name ).colorize(:color => :black, :background => :light_white)
					else
						owner_string = '        '.colorize(:background => :white)
					end

					summary[0] << ( '%-11s' % property.name[0..9] ).colorize(:color => :light_white, :background => property.colour) + ' '.colorize(:color => :default)
					summary[1] << ( '%11s' % ' ' ).colorize(:color => :light_white, :background => :white) + ' '.colorize(:color => :default)
					summary[3] << ( '%11s' % ' ' ).colorize(:color => :light_white, :background => :white) + ' '.colorize(:color => :default)
					summary[4] << ( '%3s' % ' ' ).colorize(:color => :light_white, :background => :white) + owner_string + ' '.colorize(:color => :default)

					this_space = @players.select { |p| p.current_square == property }				
					if this_space.length > 0
							summary[2] << ' '.colorize(:background => :white) + ( ' %-6s ' % this_space.collect(&:name).first.upcase ).colorize(:color => :black, :background => :white)
							summary[2] << ( ' ' * 2 ) .colorize(:background => :white) + ' '.colorize(:color => :default)
					else
						summary[2] << ( '%11s' % ' ' ).colorize(:color => :light_white, :background => :white) + ' '.colorize(:color => :default)
					end

					if property.is_a? PurchasableProperty and property.is_mortgaged?
						summary[5] << ' MORTGAGED '.colorize(:background => :light_black, :color => :white) + ' '.colorize(:color => :default)
					elsif property.is_a? BasicProperty
						summary[5] << property.display_house_ascii
					else
						summary[5] << ( '%11s' % ' ' ).colorize(:background => :white) + ' '.colorize(:color => :default)
					end

					position = position + 1
				end

				summary_out = summary.collect! { |s| s << "\n" }
				puts summary_out
				puts
				return summary_out
			end

		# Draws a chance card from the pile. If the pile is empty, resets and reshuffles the deck.
		# @return [String] a chance string
		def chance
			@chance = @chance_all.shuffle if @chance.length == 0
			@chance.shift
		end

		# @return [Array<Player>] an array of players who have not yet been eliminated from the game.
		def active_players
			@players.reject{ |p| p.is_out? }
		end

		# Transfers money from the bank to a player. If the bank does not have sufficient funds, transfers as much as possible.
		# @return [Boolean] whether or not the bank had sufficient cash to pay the player the desired amount.
		def pay_player(player, amount, reason = nil)
			if @bank_balance > amount
				@bank_balance = @bank_balance - amount
				player.currency = player.currency + amount
				puts '[%s] Received £%d from bank%s (balance: £%d, bank balance: £%d)' % [ player.name, amount, (reason ? ' for %s' % reason : '' ), player.currency, bank_balance ]
				true
			else
				player.currency = player.currency + bank_balance
				puts '[%s] Unable to receive £%d from bank! Received £%d instead (balance: £%d)' % [ player.name, amount, bank_balance, player.currency ]
				@bank_balance = 0
				false
			end
		end	

		# Pays the contents of the free parking square to a player.
		# @return [Integer] the amount of money given to the player.
		def payout_free_parking(player)
			payout = @free_parking_balance
			player.currency = player.currency + payout
			puts '[%s] Landed on free parking! £%d treasure found' % [player.name, @free_parking_balance] unless @free_parking_balance == 0
			@free_parking_balance = 0
			payout
		end

		# Draws a community chest card from the pile. If the pile is empty, resets and reshuffles the deck.
		# @return [String] a community chest string
		def community_chest
			@community_chest = @community_chest_all.shuffle if @community_chest.length == 0
			@community_chest.shift
		end

		# Add a player to the game.
		# @return [Array<Player>] an array of active players.
		def register_player(player)
			@players << player
		end

		# Play through a given number of turns of the game as configured.
		# @param [Integer] turns the number of turns of the game to play through.
		# @return [self]
		# @example Play through an entire game
		#     game = Monotony::Game.new
		#     game.play
		# @example Play through 10 turns
		#     game.play(10)
		def play(turns = 100000)
			if @completed
				puts 'Game is complete!'
				return false
			end
			turns.to_i.times do
				@turn = @turn + 1
				puts '- Turn %d begins!' % @turn
				@players.each do |turn|
					if turn.is_out?
						puts '[%s] Is sitting out' % turn.name
						next
					end
						puts '[%s] Go begins on %s (balance: £%d)' % [ turn.name , turn.current_square.name, turn.currency ]

					turn.properties.each do |property|
						case property
						when Station
							if property.is_mortgaged?
								turn.behaviour[:unmortgage_possible].call(self, turn, property) if turn.currency > property.cost
							end
						when Utility
							if property.is_mortgaged?
								turn.behaviour[:unmortgage_possible].call(self, turn, property) if turn.currency > property.cost
							end
						when BasicProperty
							if property.is_mortgaged?
								turn.behaviour[:unmortgage_possible].call(self, turn, property) if turn.currency > property.cost
							else
								if property.set_owned?
									case property.num_houses
									when 0..3
										turn.behaviour[:houses_available].call(self, turn, property) unless property.num_hotels > 0
									when 4
										turn.behaviour[:hotel_available].call(self, turn, property)
									end
								end
							end
						end
					end

					turn.behaviour[:trade_possible].call(self, turn) if not turn.properties.empty?
					turn.behaviour[:use_jail_card].call(self, turn) if turn.in_jail? and turn.jail_free_cards > 0

					result = turn.roll
					double = (result.uniq.length == 1)

					move_total = result.inject(:+)
					@last_roll = move_total


					puts '[%s] Rolled %s (total: %d)' % [ turn.name, result.join(', '), move_total ]
					puts '[%s] Rolled a double' % turn.name if double

					if turn.in_jail?
						if double
							puts '[%s] Got out of jail! (rolled double)' % turn.name
							turn.in_jail = false
						else
							turn.turns_in_jail = turn.turns_in_jail + 1
							puts '[%s] Is still in jail (turn %d)' % [ turn.name, turn.turns_in_jail ]
							if turn.turns_in_jail >= @max_turns_in_jail
								turn.in_jail = false
								turn.pay(:free_parking, 50)
								puts '[%s] Got out of jail (paid out)' % turn.name
							else 
								next
							end
						end
					end

					square = turn.move(move_total)

					puts '[%s] Moved to %s' % [ turn.name, square.name ]
					square.action.call(self, square.owner, turn, square)

					puts '[%s] Next throw' % turn.name if double
					redo if double
					puts '[%s] Ended go on %s (balance: £%d)' % [ turn.name, turn.current_square.name, turn.currency ]
				end

				still_in = @players.reject{ |p| p.is_out? }
				if active_players.count == 1
					winner = still_in.first
					puts '[%s] Won the game! Final balance: £%d, Property: %s' % [ winner.name, winner.currency, winner.properties.collect {|p| p.name} ]
					@completed = true
					break
				end
			end
			self
		end
	end
end
