module Monotony
	# The classic UK edition of Monopoly.
	class DefaultLayout
		# An array of strings representing a deck of 'Community Chest' cards. Will be shuffled before use.
		COMMUNITY_CHEST = [
			'Go to jail. Move directly to jail. Do not pass GO. Do not collect £200.',
			'Receive interest on 7% preference shares (£25)',
			'Pay hospital £100', 'Pay your insurance premium (£50)',
			'Advance to GO', 'Income tax refund (collect £20)',
			'It is your birthday! (£10 from each player)',
			'Go back to Old Kent Road',
			'Bank error in your favour (£200)',
			'Annuity matures (collect £100)',
			'From sale of stock you get £50',
			'You have won second prize in a beauty contest (£10)',
			'Get out of jail free',
			'Pay a £10 fine or take a chance',
			"Doctor's fee (£50)",
			'You inherit £100'
		]

		# An array of strings representing a deck of 'Chance' cards. Will be shuffled before use.
		CHANCE = [
			'Your building loan matures (receive £150)',
			'Take a trip to Marylebone Station',
			'Go back three spaces',
			'Speeding fine (£15)',
			'Advance to Mayfair',
			'Make general repairs on all of your houses. For each house pay £25, and for each hotel pay £100.',
			'Advance to Trafalgar BoardSquare',
			'You are assessed for street repairs. £40 per house, £115 per hotel.',
			'Pay school fees of £150',
			'Advance to GO',
			'Bank pays you dividend of £50',
			'Drunk in charge (£20 fine)',
			'Go to jail. Move directly to jail. Do not pass GO. Do not collect £200',
			'Advance to Pall Mall',
			'Get out of jail free',
			'You have won a crossword competition (£100)'
		]

		# The game board layout, consisting of an array of BoardSquares.
		BOARD = [
			BoardSquare.new(
				name: 'GO',
				display_class: 'bigsquare',
				action: Proc.new { |game, owner, player, property|
					Transaction.new(from: game.bank, to: player, reason: 'landing on go', amount: game.go_amount)
				}
			),
			
			BasicProperty.new(
				name: 'Old Kent Road',
				rent: [ 2, 10, 30, 90, 160, 250 ],
				house_cost: 50,
				hotel_cost: 50,
				mortgage_value: 30,
				value: 60,
				set: :brown,
				colour: '#8b4513'
			),

			CommunityChest.new(
				name: 'Community Chest 1',
				display_name: 'Community Chest'
			),

			BasicProperty.new(
				name: 'Whitechapel Road',
				rent: [ 4, 20, 60, 180, 320, 450 ],
				house_cost: 50,
				hotel_cost: 50,
				mortgage_value: 30,
				value: 60,
				set: :brown,
				colour: '#8b4513'
			),

			BoardSquare.new(
				name: 'Income Tax',
				colour: '#ecfcf4',
				action: Proc.new { |game, owner, player, property|
					Transaction.new(from: player, to: game.bank, reason: 'income tax', amount: 200)
				}
			),

			Station.new(
				name: "King's Cross Station",
				value: 200,
				mortgage_value: 100
			),

			BasicProperty.new(
				name: 'The Angel Islington',
				rent: [ 6, 30, 90, 270, 400, 550 ],
				house_cost: 50,
				hotel_cost: 50,
				mortgage_value: 50,
				value: 100,
				set: :blue,
				colour: '#7ec0ee'
			),

			Chance.new(
				name: 'Chance 1',
				display_name: 'Chance'
			),

			BasicProperty.new(
				name: 'Euston Road',
				rent: [ 6, 30, 90, 270, 400, 550 ],
				house_cost: 50,
				hotel_cost: 50,
				mortgage_value: 50,
				value: 100,
				set: :blue,
				colour: '#7ec0ee'
			),

			BasicProperty.new(
				name: 'Pentonville Road',
				rent: [ 8, 40, 100, 300, 450, 600 ],
				house_cost: 50,
				hotel_cost: 50,
				mortgage_value: 60,
				value: 120,
				set: :blue,
				colour: '#7ec0ee'
			),

			BoardSquare.new(
				name: 'Jail',
				display_class: 'bigsquare'
			),

			BasicProperty.new(
				name: 'Pall Mall',
				rent: [ 10, 50, 150, 450, 625, 750 ],
				house_cost: 100,
				hotel_cost: 100,
				mortgage_value: 70,
				value: 140,
				set: :pink,
				colour: '#9932cc'
			),

			Utility.new(
				name: 'Electric Company',
				value: 150,
				mortgage_value: 75
			),

			BasicProperty.new(
				name: 'Whitehall',
				rent: [ 10, 50, 150, 450, 625, 750 ],
				house_cost: 100,
				hotel_cost: 100,
				mortgage_value: 70,
				value: 140,
				set: :pink,
				colour: '#9932cc'
			),

			BasicProperty.new(
				name: 'Northumberland Avenue',
				rent: [ 12, 60, 180, 500, 700, 900 ],
				house_cost: 100,
				hotel_cost: 100,
				mortgage_value: 80,
				value: 160,
				set: :pink,
				colour: '#9932cc'
			),

			Station.new(
				name: 'Marylebone Station',
				value: 200,
				mortgage_value: 100
			),

			BasicProperty.new(
				name: 'Bow Street',
				rent: [ 14, 70, 200, 550, 750, 950 ],
				house_cost: 100,
				hotel_cost: 100,
				mortgage_value: 90,
				value: 180,
				set: :orange,
				colour: '#ffa500'
			),

			CommunityChest.new(
				name: 'Community Chest 2',
				display_name: 'Community Chest',
				set: :communitychest
			),

			BasicProperty.new(
				name: 'Marlborough Street',
				rent: [ 14, 70, 200, 550, 750, 950 ],
				house_cost: 100,
				hotel_cost: 100,
				mortgage_value: 90,
				value: 180,
				set: :orange,
				colour: '#ffa500'
			),

			BasicProperty.new(
				name: 'Vine Street',
				rent: [ 16, 80, 220, 600, 800, 1000 ],
				house_cost: 100,
				hotel_cost: 100,
				mortgage_value: 100,
				value: 200,
				set: :orange,
				colour: '#ffa500'
			),

			BoardSquare.new(
				name: 'Free Parking',
				display_class: 'bigsquare',
				action: Proc.new { |game, owner, player, property|
					game.payout_free_parking(player)
				}
			),

			BasicProperty.new(
				name: 'Strand',
				rent: [ 18, 90, 250, 700, 875, 1050 ],
				house_cost: 150,
				hotel_cost: 150,
				mortgage_value: 110,
				value: 220,
				set: :red,
				colour: :red
			),

			Chance.new(
				name: 'Chance 2',
				display_name: 'Chance'
			),

			BasicProperty.new(
				name: 'Fleet Street',
				rent: [ 18, 90, 250, 700, 875, 1050 ],
				house_cost: 150,
				hotel_cost: 150,
				mortgage_value: 110,
				value: 220,
				set: :red,
				colour: :red
			),

			BasicProperty.new(
				name: 'Trafalgar BoardSquare',
				rent: [ 20, 100, 300, 750, 925, 1100 ],
				house_cost: 150,
				hotel_cost: 150,
				mortgage_value: 120,
				value: 240,
				set: :red,
				colour: :red
			),

			Station.new(
				name: 'Fenchurch St Station',
				value: 200,
				mortgage_value: 100
			),

			BasicProperty.new(
				name: 'Leicester Square',
				rent: [ 22, 110, 330, 800, 975, 1150 ],
				house_cost: 150,
				hotel_cost: 150,
				mortgage_value: 130,
				value: 260,
				set: :yellow,
				colour: :yellow
			),

			BasicProperty.new(
				name: 'Coventry Street',
				rent: [ 22, 110, 330, 800, 975, 1150 ],
				house_cost: 150,
				hotel_cost: 150,
				mortgage_value: 130,
				value: 260,
				set: :yellow,
				colour: :yellow
			),

			Utility.new(
				name: 'Water Works',
				value: 150,
				mortgage_value: 75
			),

			BasicProperty.new(
				name: 'Piccadilly',
				rent: [ 22, 120, 360, 850, 1025, 1200 ],
				house_cost: 150,
				hotel_cost: 150,
				mortgage_value: 140,
				value: 280,
				set: :yellow,
				colour: :yellow
			),

			BoardSquare.new(
				name: 'Go to Jail',
				display_class: 'bigsquare',
				action: Proc.new { |game, owner, player, property|
					player.in_jail = true
					player.move('Jail')
					game.log '[%s] Got sent to jail!' % player.name
				}
			),

			BasicProperty.new(
				name: 'Regent Street',
				rent: [ 26, 130, 390, 900, 1100, 1275 ],
				house_cost: 200,
				hotel_cost: 200,
				mortgage_value: 150,
				value: 300,
				set: :green,
				colour: :green
			),

			BasicProperty.new(
				name: 'Oxford Street',
				rent: [ 26, 130, 390, 900, 1100, 1275 ],
				house_cost: 200,
				hotel_cost: 200,
				mortgage_value: 150,
				value: 300,
				set: :green,
				colour: :green
			),

			CommunityChest.new(
				name: 'Community Chest 3',
				display_name: 'Community Chest'
			),

			BasicProperty.new(
				name: 'Bond Street',
				rent: [ 28, 150, 450, 1000, 1200, 1400 ],
				house_cost: 200,
				hotel_cost: 200,
				mortgage_value: 160,
				value: 320,
				set: :green,
				colour: :green
			),

			Station.new(
				name: 'Liverpool St Station',
				value: 200,
				mortgage_value: 100
			),

			Chance.new(
				name: 'Chance 3',
				display_name: 'Chance'
			),

			BasicProperty.new(
				name: 'Park Lane',
				rent: [ 35, 175, 500, 1100, 1300, 1500 ],
				house_cost: 200,
				hotel_cost: 200,
				mortgage_value: 175,
				value: 350,
				set: :purple,
				colour: :blue
			),

			BoardSquare.new(
				name: 'Super Tax',
				action: Proc.new {|game, owner, player, property| 
					Transaction.new(from: player, to: game.bank, reason: 'super tax', amount: 100)
				}
			),

			BasicProperty.new(
				name: 'Mayfair',
				rent: [ 50, 200, 600, 1400, 1700, 2000 ],
				house_cost: 200,
				hotel_cost: 200,
				mortgage_value: 200,
				value: 400,
				set: :purple,
				colour: :blue
			)
		]
	end
end
