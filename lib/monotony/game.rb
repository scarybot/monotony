module Monotony
	# Contains the main game engine logic.
	class Game
    include DeepDive

		# @return [Hash] a hash containing the number of times each Square has been landed on.
		attr_accessor :hits
		# @return [Array<Square>] the current game board.
		attr_accessor :board
		# @return [Boolean] players registered to the game.
		attr_accessor :players
		# @return [Integer] the number of dice being used for player move rolls.
		attr_accessor :num_dice
		# @return [Integer] the number of faces on each dice being rolled.
		attr_accessor :die_size
		# @return [Integer] the amount of currency each player started the game with.
		attr_accessor :starting_currency
		# @return [Array<String>] the deck from which chance cards will be drawn.
		attr_accessor :chance
		# @return [Array<String>] the deck from which commuity chest cards will be drawn.
		attr_accessor :community_chest
		# @return [Integer] the amount of currency given to each player as they pass GO.		
		attr_accessor :go_amount
		# @return [Integer] the maximum number of turns a player may spend in jail before being required to pay a fine.
		attr_accessor :max_turns_in_jail
		# @return [Array<Integer>] an array containing the last roll of the dice.
		attr_accessor :last_roll
		# @return [Integer] the number of houses available to be purchased.
		attr_accessor :num_houses
		# @return [Integer] the number of hotels available to be purchased.
		attr_accessor :num_hotels
		# @return [Boolean] whether or not the game has been completed.
		attr_accessor :completed
		# @return [Array<PurchasableProperty>] properties yet to be purchased by players.
		attr_accessor :available_properties
		# @return [Integer] the current turn number.
		attr_accessor :turn
		# @return [Boolean] whether or not this Game object is a simulation inside another Game.
		attr_accessor :is_simulation
		# @return [Account] the Account holding the money owned by the bank.
		attr_reader :bank
		# @return [Account] the Account holding the currency held on free parking (in some game variants).
		attr_reader :free_parking

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
		# @return [self]
		def initialize(opts = {})
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

			@board = opts[:variant]::BOARD
			@chance_all = opts[:variant]::CHANCE
			@community_chest_all = opts[:variant]::COMMUNITY_CHEST

			@hits = {}
			@turn = 0
			@max_turns_in_jail = opts[:max_turns_in_jail].to_int
			@last_roll = 0
			@go_amount = opts[:go_amount].to_int
			@initial_board = @board
			@available_properties = @board.select { |p| p.respond_to? :sell_to }
			@chance = @chance_all.shuffle
			@community_chest = @community_chest_all.shuffle
			@num_dice = opts[:num_dice].to_int
			@num_houses = opts[:num_houses].to_int
			@num_hotels = opts[:num_hotels].to_int
			@die_size = opts[:die_size].to_int
			@starting_currency = opts[:starting_currency].to_int
			@variant = opts[:variant]
			@logger = Logger.new(STDERR)
			@logger.level = Logger::INFO
			@logger.datetime_format = '%H:%M:%S'

			@bank = Entity.new(
				name: :bank,
				balance: opts[:bank_balance],
				game: self
			)

			@free_parking = Entity.new(
				name: :free_parking,
				balance: opts[:free_parking_balance],
				game: self
			)

			case opts[:players]
				when Integer
					@players = []
					opts[:players].times do
						@players << Monotony::Player.new
					end
				when Array
					@players.each do |p|
						unless p.kind_of? Player
							raise TypeError.new(':players must be either an integer or an array of Players')
						end
					end
					@players = opts[:players]
				else
					raise TypeError.new(':players must be either an integer or an array of Players')
			end

			@completed = false

			@board.each do |square|
				@hits[square] = 0
				square.game = self
			end

			@players.each do |player|
				player.account.balance = @starting_currency
				player.board = @board.clone
				player.game = self
			end
			self
		end

    # @return [Array<Symbol>] the names of completed property sets currently owned by players
		def all_sets_owned
			@board.select{ |p| p.is_a? BasicProperty }.select(&:set_owned?).group_by { |p| p.set }.keys
		end

		# @param [Player] player A player object.
		# @return [Integer] the index of the given player object in the list of players.
		def player_index(player)
			@players.index(player)
		end

		# @return [void]
		def log(message)
			@logger.info(message)
		end

		# @return [void]
		def debug_log(message)
			@logger.debug(message)
		end

		# @return [Game] a clone of the current game object for forecasting purposes.
		def simulate
			simulation = self.dclone
			simulation.is_simulation = true
			simulation
		end

		# Produces a colourful ASCII representation of the state of the game board to standard output.
		# The string produced contains ANSI colours.
		# @return [String] a textual summary of the state of the game.
		# @example Show a summary of a game in progress
		#    game.summary
		def summary
			summary = Array.new(6) { '' }
				position = 0
				header = ''

				worth = @players.collect { |p| '%s: £%d' % [ p.name, p.balance ]}
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
			@players.reject(&:is_out?)
		end

		# Pays the contents of the free parking square to a player.
		# @return [Integer] the amount of money given to the player.
		def payout_free_parking(player)
			payout = @free_parking.balance
			log '[%s] Landed on free parking! £%d treasure found' % [ player.name, @free_parking.balance ] unless @free_parking.balance == 0
			Transaction.new(to: player, from: @free_parking, amount: @free_parking.balance, reason: 'free parking')
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
			turns = turns.to_int

			if @completed
				log 'Game is complete!'
				return false
			end

			turns.times do
				@turn = @turn + 1
				log '- Turn %d begins!' % @turn
				@players.each do |current_player|
					if current_player.is_out?
						log '[%s] Is sitting out' % current_player.name
						next
					end
					log '[%s] Begins on %s (balance: £%d)' % [ current_player.name , current_player.current_square.name, current_player.balance ]

					current_player.properties.each do |property|
						property.maintenance_actions
					end

					current_player.act(:consider_proposing_trade) unless current_player.properties.empty?

					if current_player.in_jail? and current_player.jail_free_cards > 0
						current_player.use_jail_card! if current_player.decide(:consider_using_jail_card).is_yes?
					end

					result = current_player.roll
					double = (result.uniq.length == 1)

					move_total = result.inject(:+)
					@last_roll = move_total


					log '[%s] Rolled %s (total: %d)' % [ current_player.name, result.join(', '), move_total ]
					log '[%s] Rolled a double' % current_player.name if double

					if current_player.in_jail?
						if double
							log '[%s] Got out of jail! (rolled double)' % current_player.name
							current_player.in_jail = false
						else
							current_player.turns_in_jail = current_player.turns_in_jail + 1
							log '[%s] Is still in jail (turn %d)' % [ current_player.name, current_player.turns_in_jail ]
							if current_player.turns_in_jail >= @max_turns_in_jail
								current_player.in_jail = false
								Transaction.new(to: @free_parking, from: current_player, amount: 50, reason: 'get out of jail')
								log '[%s] Got out of jail (paid out)' % current_player.name
							else 
								next
							end
						end
					end

					square = current_player.move(move_total)

					log '[%s] Moved to %s' % [ current_player.name, square.name ]
					square.action(game: self, player: current_player)

					log '[%s] Next throw' % current_player.name if double
					redo if double
					log '[%s] Ended on %s (balance: £%d)' % [ current_player.name, current_player.current_square.name, current_player.balance ]
				end

				still_in = @players.reject(&:is_out?)
				if active_players.count == 1
					winner = still_in.first
					log '[%s] Won the game after %d turns! Final balance: £%d, Property: %s' % [ winner.name, @turn, winner.balance, winner.properties.collect {|p| p.name} ]
					@completed = true
					break
				end
			end
			self
		end
	end
end

