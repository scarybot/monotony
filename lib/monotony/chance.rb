require 'monotony/square'

module Monotony

	# A chance square.
	class Chance < Square

		# @param [Hash] opts
		# @option opts [String] :name The name of the square. As chance squares are traditionally all called 'Chance', in the default layout we are calling these squares 'Chance 1', 'Chance 2', etc.
		def initialize(opts)
			super
		end

		def action(**args)
			player, game = args[:player], args[:game]
			this_chance = game.chance
			game.log '[%s] Drew a chance: %s' % [ player.name, this_chance ]

			case this_chance
			when /Go to jail/
			when 'Go back three spaces'
				moved_to = player.move(-3)
				game.log '[%s] Moved back to %s' % [ player.name, moved_to.name ]
			when 'Take a trip to Marylebone Station'
				player.move('Marylebone Station')
			when 'Advance to Mayfair'
				player.move('Mayfair')
			when 'Advance to Trafalgar Square'
				player.move('Trafalgar Square')
			when 'Advance to GO'
				player.move('GO')
			when 'Advance to Pall Mall'
				player.move('Pall Mall')
			when /Your building loan matures/
				Transaction.new(from: game.bank, to: player, reason: 'chance: building loan matures', amount: 100)
			when /Speeding fine/
				Transaction.new(from: player, to: game.free_parking, reason: 'chance: speeding fine', amount: 15)
			when /school fees/
				Transaction.new(from: player, to: game.free_parking, reason: 'chance: school fees', amount: 150)
			when /Bank pays you/
				Transaction.new(from: game.bank, to: player, reason: 'chance: dividend', amount: 50)
			when /Drunk in charge/
				Transaction.new(from: player, to: game.free_parking, reason: 'chance: drunk in charge', amount: 50)
			when /crossword/
				Transaction.new(from: game.bank, to: player, reason: 'chance: crossword competition', amount: 100)
			when /general repairs/
				Transaction.new(from: player, to: game.free_parking, reason: 'chance: general repairs', amount: (25 * player.num_houses) + (100 * player.num_hotels) )
			when /street repairs/
				Transaction.new(from: player, to: game.free_parking, reason: 'chance: street repairs', amount: (40 * player.num_houses) + (115 * player.num_hotels) )
			when /jail free/
				player.jail_free_cards = player.jail_free_cards + 1
			end

			super
		end
	end
end