#!/usr/bin/ruby

require 'pp'
require 'pry'
require 'colorize'

require 'monopoly_engine/basicproperty'
require 'monopoly_engine/chance'
require 'monopoly_engine/communitychest'
require 'monopoly_engine/game'
require 'monopoly_engine/player'
require 'monopoly_engine/purchasable'
require 'monopoly_engine/square'
require 'monopoly_engine/station'
require 'monopoly_engine/utility'

module MonopolyEngine

	monopoly_board = []

	monopoly_board << Square.new(
		name: 'GO',
		action: Proc.new { |game, owner, player, property|
			game.pay_player(player, 200, 'landing on GO')
		}
	)

	monopoly_board << BasicProperty.new(
		name: 'Old Kent Road',
		rent: [ 2, 10, 30, 90, 160, 250 ],
		house_cost: 50,
		hotel_cost: 50,
		mortgage_value: 30,
		value: 60,
		set: :brown,
		colour: :yellow,
	)

	monopoly_board << CommunityChest.new(
		name: 'Community Chest 1',
		colour: :light_cyan
	)

	monopoly_board << BasicProperty.new(
		name: 'Whitechapel Road',
		rent: [ 4, 20, 60, 180, 320, 450 ],
		house_cost: 50,
		hotel_cost: 50,
		mortgage_value: 30,
		value: 60,
		set: :brown,
		colour: :yellow
	)

	monopoly_board << Square.new(
		name: 'Income Tax',
		colour: :light_black,
		action: Proc.new { |game, owner, player, property|
			player.pay(:bank, 200, 'income tax')
		}
	)

	monopoly_board << Station.new(
		name: "King's Cross Station",
		value: 200,
		mortgage_value: 100,
		colour: :light_blue
	)

	monopoly_board << BasicProperty.new(
		name: 'The Angel Islington',
		rent: [ 6, 30, 90, 270, 400, 550 ],
		house_cost: 50,
		hotel_cost: 50,
		mortgage_value: 50,
		value: 100,
		set: :blue,
		colour: :blue
	)

	monopoly_board << Chance.new(
		name: 'Chance 1',
		colour: :light_cyan
	)

	monopoly_board << BasicProperty.new(
		name: 'Euston Road',
		rent: [ 6, 30, 90, 270, 400, 550 ],
		house_cost: 50,
		hotel_cost: 50,
		mortgage_value: 50,
		value: 100,
		set: :blue,
		colour: :blue
	)

	monopoly_board << BasicProperty.new(
		name: 'Pentonville Road',
		rent: [ 8, 40, 100, 300, 450, 600 ],
		house_cost: 50,
		hotel_cost: 50,
		mortgage_value: 60,
		value: 120,
		set: :blue,
		colour: :blue
	)

	monopoly_board << Square.new(
		name: 'Jail',
		colour: :light_black
	)

	monopoly_board << BasicProperty.new(
		name: 'Pall Mall',
		rent: [ 10, 50, 150, 450, 625, 750 ],
		house_cost: 100,
		hotel_cost: 100,
		mortgage_value: 70,
		value: 140,
		set: :pink,
		colour: :light_magenta
	)

	monopoly_board << Utility.new(
		name: 'Electric Company',
		value: 150,
		mortgage_value: 75,
		colour: :cyan
	)

	monopoly_board << BasicProperty.new(
		name: 'Whitehall',
		rent: [ 10, 50, 150, 450, 625, 750 ],
		house_cost: 100,
		hotel_cost: 100,
		mortgage_value: 70,
		value: 140,
		set: :pink,
		colour: :light_magenta

	)

	monopoly_board << BasicProperty.new(
		name: 'Northumberland Avenue',
		rent: [ 12, 60, 180, 500, 700, 900 ],
		house_cost: 100,
		hotel_cost: 100,
		mortgage_value: 80,
		value: 160,
		set: :pink,
		colour: :light_magenta
	)

	monopoly_board << Station.new(
		name: 'Marylebone Station',
		value: 200,
		mortgage_value: 100,
		colour: :light_blue
	)

	monopoly_board << BasicProperty.new(
		name: 'Bow Street',
		rent: [ 14, 70, 200, 550, 750, 950 ],
		house_cost: 100,
		hotel_cost: 100,
		mortgage_value: 90,
		value: 180,
		set: :orange,
		colour: :light_red
	)

	monopoly_board << CommunityChest.new(
		name: 'Community Chest 2',
		set: :communitychest,
		colour: :light_cyan
	)

	monopoly_board << BasicProperty.new(
		name: 'Marlborough Street',
		rent: [ 14, 70, 200, 550, 750, 950 ],
		house_cost: 100,
		hotel_cost: 100,
		mortgage_value: 90,
		value: 180,
		set: :orange,
		colour: :light_red
	)

	monopoly_board << BasicProperty.new(
		name: 'Vine Street',
		rent: [ 16, 80, 220, 600, 800, 1000 ],
		house_cost: 100,
		hotel_cost: 100,
		mortgage_value: 100,
		value: 200,
		set: :orange,
		colour: :light_red
	)

	monopoly_board << Square.new(
		name: 'Free Parking',
		colour: :white,
		action: Proc.new { |game, owner, player, property|
			game.payout_free_parking(player)
		}
	)

	monopoly_board << BasicProperty.new(
		name: 'Strand',
		rent: [ 18, 90, 250, 700, 875, 1050 ],
		house_cost: 150,
		hotel_cost: 150,
		mortgage_value: 110,
		value: 220,
		set: :red,
		colour: :red
	)

	monopoly_board << Chance.new(
		name: 'Chance 2',
		colour: :light_cyan
	)

	monopoly_board << BasicProperty.new(
		name: 'Fleet Street',
		rent: [ 18, 90, 250, 700, 875, 1050 ],
		house_cost: 150,
		hotel_cost: 150,
		mortgage_value: 110,
		value: 220,
		set: :red,
		colour: :red
	)

	monopoly_board << BasicProperty.new(
		name: 'Trafalgar Square',
		rent: [ 20, 100, 300, 750, 925, 1100 ],
		house_cost: 150,
		hotel_cost: 150,
		mortgage_value: 120,
		value: 240,
		set: :red,
		colour: :red
	)

	monopoly_board << Station.new(
		name: 'Fenchurch St Station',
		value: 200,
		mortgage_value: 100,
		colour: :light_blue
	)

	monopoly_board << BasicProperty.new(
		name: 'Leicester Square',
		rent: [ 22, 110, 330, 800, 975, 1150 ],
		house_cost: 150,
		hotel_cost: 150,
		mortgage_value: 130,
		value: 260,
		set: :yellow,
		colour: :yellow
	)

	monopoly_board << BasicProperty.new(
		name: 'Coventry Street',
		rent: [ 22, 110, 330, 800, 975, 1150 ],
		house_cost: 150,
		hotel_cost: 150,
		mortgage_value: 130,
		value: 260,
		set: :yellow,
		colour: :yellow
	)

	monopoly_board << Utility.new(
		name: 'Water Works',
		value: 150,
		mortgage_value: 75,
		colour: :cyan
	)

	monopoly_board << BasicProperty.new(
		name: 'Piccadilly',
		rent: [ 22, 120, 360, 850, 1025, 1200 ],
		house_cost: 150,
		hotel_cost: 150,
		mortgage_value: 140,
		value: 280,
		set: :yellow,
		colour: :yellow
	)

	monopoly_board << Square.new(
		name: 'Go to Jail',
		colour: :light_black,
		action: Proc.new {|game, owner, player, property|
			player.in_jail = true
			player.move('Jail')
			puts '[%s] Got sent to jail!' % player.name
		}
	)

	monopoly_board << BasicProperty.new(
		name: 'Regent Street',
		rent: [ 26, 130, 390, 900, 1100, 1275 ],
		house_cost: 200,
		hotel_cost: 200,
		mortgage_value: 150,
		value: 300,
		set: :green,
		colour: :green
	)

	monopoly_board << BasicProperty.new(
		name: 'Oxford Street',
		rent: [ 26, 130, 390, 900, 1100, 1275 ],
		house_cost: 200,
		hotel_cost: 200,
		mortgage_value: 150,
		value: 300,
		set: :green,
		colour: :green
	)

	monopoly_board << CommunityChest.new(
		name: 'Community Chest 3',
		colour: :light_cyan
	)

	monopoly_board << BasicProperty.new(
		name: 'Bond Street',
		rent: [ 28, 150, 450, 1000, 1200, 1400 ],
		house_cost: 200,
		hotel_cost: 200,
		mortgage_value: 160,
		value: 320,
		set: :green,
		colour: :green
	)

	monopoly_board << Station.new(
		name: 'Liverpool St Station',
		value: 200,
		mortgage_value: 100,
		colour: :light_blue
	)

	monopoly_board << Chance.new(
		name: 'Chance 3',
		colour: :light_cyan
	)

	monopoly_board << BasicProperty.new(
		name: 'Park Lane',
		rent: [ 35, 175, 500, 1100, 1300, 1500 ],
		house_cost: 200,
		hotel_cost: 200,
		mortgage_value: 175,
		value: 350,
		set: :purple,
		colour: :magenta
	)

	monopoly_board << Square.new(
		name: 'Super Tax',
		action: Proc.new {|game, owner, player, property| 
			player.pay(:bank, 100, 'super tax')
		}
	)

	monopoly_board << BasicProperty.new(
		name: 'Mayfair',
		rent: [ 50, 200, 600, 1400, 1700, 2000 ],
		house_cost: 200,
		hotel_cost: 200,
		mortgage_value: 200,
		value: 400,
		set: :purple,
		colour: :magenta
	)

	community_chest = ['Go to jail. Move directly to jail. Do not pass GO. Do not collect £200.', 'Receive interest on 7% preference shares (£25)', 'Pay hospital £100', 'Pay your insurance premium (£50)', 'Advance to GO', 'Income tax refund (collect £20)', 'It is your birthday! (£10 from each player)', 'Go back to Old Kent Road', 'Bank error in your favour (£200)', 'Annuity matures (collect £100)', 'From sale of stock you get £50', 'You have won second prize in a beauty contest (£10)', 'Get out of jail free', 'Pay a £10 fine or take a chance', "Doctor's fee (£50)", 'You inherit £100']

	chance = ['Your building loan matures (receive £150)', 'Take a trip to Marylebone Station', 'Go back three spaces', 'Speeding fine (£15)', 'Advance to Mayfair', 'Make general repairs on all of your houses. For each house pay £25, and for each hotel pay £100.', 'Advance to Trafalgar Square', 'You are assessed for street repairs. £40 per house, £115 per hotel.', 'Pay school fees of £150', 'Advance to GO', 'Bank pays you dividend of £50', 'Drunk in charge (£20 fine)', 'Go to jail. Move directly to jail. Do not pass GO. Do not collect £200', 'Advance to Pall Mall', 'Get out of jail free', 'You have won a crossword competition (£100)']

	behaviour = {
		purchase_possible: Proc.new { |game, player, property| 
			if player.properties.collect{ |p| p.set }.include? property.set
				# Will definitely buy if player already owns one or more of this set
				property.sell_to(player)
			elsif game.players.collect { |p| p.properties.collect { |p| p.set } }.flatten.include? property.set
				# Less likely to buy if another player already owns one of the set
				property.sell_to(player) if Random.rand(0..100) >= 75
			else
				# Will probably buy if nobody has bought any of this set yet
				property.sell_to(player) if Random.rand(0..100) >= 25
			end
		},
		unmortgage_possible: Proc.new { |game, player, property|
			# Only bother unmortgaging something if I have the rest of the set, or it's less than 15% of my cash
			if player.sets_owned.include? property.set
				property.unmortgage
			elsif ( property.cost.to_f / player.currency.to_f * 100.0 ) < 15.0
				property.unmortgage
			end
		},
		houses_available: Proc.new {|game, player, property|
			# Buy houses when possible, but don't spend more than 40% of my money on them in any one turn
			can_afford = ( ( player.currency * 0.4 ) / property.house_cost ).floor
			max_available = 4 - property.num_houses
			to_buy = [ can_afford, max_available ].min
			property.add_houses(to_buy) if to_buy > 0 unless game.active_players == 1
		},
		hotel_available: Proc.new {|game, player, property|
			# Buy a hotel, unless it's more than half my current balance.
			property.add_hotel unless ( property.hotel_cost.to_f / player.currency.to_f * 100.0) > 50.0
		},
		money_trouble: Proc.new {|game, player, amount|
			portfolio = player.properties.sort_by { |p| p.mortgage_value }
			while player.currency < amount do
				if portfolio.length > 0
					property = portfolio.shift
					if property.is_a? BasicProperty
						if property.num_hotels == 1
							property = property.sell_hotel
						end
						break if player.currency >= amount

						while property.num_houses > 0
							property = property.sell_houses(1)
							break if player.currency >= amount
						end
						break if player.currency >= amount

						property = property.mortgage
					end
				else
					break
				end
			end
		},
		use_jail_card: Proc.new {|game, player|
			# Unless less than 50% of active sets are mine, get out of jail with a card when possible
			player.use_jail_card! unless ( player.sets_owned.count.to_f / game.all_sets_owned.count.to_f * 100.0 ) < 50
		},
		trade_possible: Proc.new {|game, player|
			puts '[%s] Considering possible trades' % player.name
		    invested_colours = player.properties.collect(&:set).uniq
		    player.opponents.each do |opponent|
		    	opponent.properties.select { |r| invested_colours.include? r.set }.each do |desirable_property|
		    		factors = {}
		    		# e.g. 66% chance of buying if one property is owned, 99% chance of buying if two are
		    		factors[:number_owned] = ( desirable_property.number_of_set_owned.to_f + 1.0 ) / desirable_property.number_in_set(game).to_f
		    		# More likely to trade if player has over £1000
					factors[:currency] = player.currency.to_f / 1000.to_f
		    		# More likely to trade if close to GO
		    		factors[:proximity_to_go] = 1 - ( player.distance_to_go.to_f / game.board.length.to_f )

		    		# We use these factors to work out how much to offer relative to how much we have
		    		offer_amount = player.currency * factors.values.inject(&:*)
		    		if offer_amount > desirable_property.cost and player.currency >= offer_amount
						puts '[%s] Placing offer of £%d on %s (owned by %s) [%f]' % [ player.name, offer_amount, desirable_property.name, desirable_property.owner.name, factors.values.inject(&:*) * 100 ]

			    		desirable_property.place_offer(player, offer_amount)
			    	end
		    	end
		    end
		},
		trade_proposed: Proc.new {|game, player, proposer, property, amount|
			factors = {}
			# More likely to accept a trade the longer the game has been going on for (definitely at 100 turns)
			factors[:longevity] = ( [0, game.turn, 100].sort[1].to_f / 100.0 ).to_f
			# More likely to accept a trade if it is far over the list price
			factors[:value_added] = 1 - ( property.cost.to_f / amount.to_f )
			# More likely to accept a trade if low on cash
			factors[:currency] = 1 - ( player.currency.to_f / 1000.to_f )

			# Random element
			factors[:random] = Random.rand(1..100)
			puts '[%s] Considering offer of £%d for %s (from %s) [%f]' % [ player.name, amount, property.name, proposer.name, ( factors.values.collect{ |f| ( 100 / factors.count ) * f }.inject(:+) / 100 ) ]
			property.sell_to(proposer, amount) if Random.rand(1..100) > ( factors.values.collect{ |f| ( 100 / factors.count ) * f }.inject(:+) / 100 )
		}
	}

	monopoly_players = [
	 	Player.new( name: 'James', behaviour: behaviour ),
	 	Player.new( name: 'Jody',  behaviour: behaviour ),
	 	Player.new( name: 'Ryan',  behaviour: behaviour ),
	 	Player.new( name: 'Tine',  behaviour: behaviour )
	]

	monopoly = Game.new(
		layout: monopoly_board,
		chance: chance,
		community_chest: community_chest,
		num_dice: 2,
		die_size: 6,
		starting_currency: 1500,
		bank_balance: 12755,
		num_hotels: 12,
		num_houses: 48,
		go_amount: 200,
		max_turns_in_jail: 3,
		players: monopoly_players
	)
end

# Good place to break, for tweaking before starting the game
# binding.pry

# monopoly.play(ARGV[0])
