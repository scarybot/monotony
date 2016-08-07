require 'monotony/square'

module Monotony

	# A chance square.
	class Chance < Square

		# @param [Hash] opts
		# @option opts [String] :name The name of the square. As chance squares are traditionally all called 'Chance', in the default layout we are calling these squares 'Chance 1', 'Chance 2', etc.
		def initialize(opts)
			super
			@action = Proc.new do |game, owner, player, property|
				this_chance = game.chance
				puts '[%s] Drew a chance: %s' % [ player.name, this_chance ]

				case this_chance
				when /Go to jail/
				when 'Go back three spaces'
					moved_to = player.move(-3)
					puts '[%s] Moved back to %s' % [ player.name, moved_to ]
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
					game.pay_player(player, 100)
				when /Speeding fine/
					player.pay(:free_parking, 15, 'speeding fine')
				when /school fees/
					player.pay(:free_parking, 150, 'school fees')
				when /Bank pays you/
					game.pay_player(player, 50)
				when /Drunk in charge/
					player.pay(:free_parking, 50, 'being drunk in charge')
				when /crossword/
					game.pay_player(player, 100)
				when /general repairs/
					player.pay(:free_parking, (25 * player.num_houses) + (100 * player.num_hotels), 'general repairs')
				when /street repairs/
					player.pay(:free_parking, (40 * player.num_houses) + (115 * player.num_hotels), 'street repairs')
				when /jail free/
					player.jail_free_cards = player.jail_free_cards + 1
				end
			end
		end
	end
end