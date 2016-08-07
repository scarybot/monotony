require 'monotony/square'

module Monotony

	# A community chest square.
	class CommunityChest < Square

		# @param [Hash] opts
		# @option opts [String] :name the name of the square. As community chest squares are traditionally all called 'Community Chest', in the default layout we are calling these squares 'Community Chest 1', 'Community Chest 2', etc.
		def initialize(opts)
			super
			@action = Proc.new do |game, owner, player, property|
				this_cc = game.community_chest
				puts '[%s] Drew a community chest: %s' % [ player.name, this_cc ]

				case this_cc
				when /It is your birthday/
					game.players.reject { |p| p.name == player.name }.each do |other_player|
						other_player.pay(player, 10)
					end
				when /Old Kent Road/
					player.move('Old Kent Road', :backwards)
				when /Go to jail/
					player.in_jail = true
					player.move('Jail')
					puts '[%s] Got sent to jail!' % player.name
				when /Annuity matures/
					game.pay_player(player, 150)
				when /sale of stock/
					game.pay_player(player, 50)
				when /preference shares/
					game.pay_player(player, 25)
				when /tax refund/
					game.pay_player(player, 20)
				when /insurance premium/
					player.pay(:free_parking, 50, 'insurance')
				when /Doctor/
					player.pay(:free_parking, 50, "doctor's fees")
				when /Bank error/
					game.pay_player(player, 200)
				when /hospital/
					player.pay(:free_parking, 100, 'hospital fees')
				when /beauty contest/
					game.pay_player(player, 10)
				when /inherit/
					game.pay_player(player, 100)
				when 'Advance to GO'
					player.move('GO')
				when /jail free/
					player.jail_free_cards = player.jail_free_cards + 1
				when /take a chance/
					player.pay(:free_parking, 10, 'avoiding a chance')
				end
			end
		end
	end
end