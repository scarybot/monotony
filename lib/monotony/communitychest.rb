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
				game.log '[%s] Drew a community chest: %s' % [ player.name, this_cc ]

				case this_cc
				when /It is your birthday/
					game.players.reject { |p| p.name == player.name }.each do |other_player|
						Transaction.new(from: other_player, to: player, reason: 'birthday!', amount: 10)
					end
				when /Old Kent Road/
					player.move('Old Kent Road', :backwards)
				when /Go to jail/
					player.in_jail = true
					player.move('Jail')
					game.log '[%s] Got sent to jail!' % player.name
				when /Annuity matures/
					Transaction.new(from: game.bank, to: player, reason: 'community chest: annuity matures', amount: 150)
				when /sale of stock/
					Transaction.new(from: game.bank, to: player, reason: 'community chest: sale of stock', amount: 50)
				when /preference shares/
					Transaction.new(from: game.bank, to: player, reason: 'community chest: preference shares', amount: 25)
				when /tax refund/
					Transaction.new(from: game.bank, to: player, reason: 'community chest: tax refund', amount: 20)
				when /insurance premium/
					Transaction.new(from: game.bank, to: player, reason: 'community chest: insurance', amount: 50)
				when /Doctor/
					Transaction.new(from: player, to: game.bank, reason: "community chest: doctor's fees", amount: 50)
				when /Bank error/
					Transaction.new(from: game.bank, to: player, reason: 'community chest: bank error', amount: 200)
				when /hospital/
					Transaction.new(from: player, to: game.bank, reason: 'community chest: hospital fees', amount: 100)
				when /beauty contest/
					Transaction.new(from: game.bank, to: player, reason: 'community chest: beauty contest', amount: 10)
				when /inherit/
					Transaction.new(from: game.bank, to: player, reason: 'community chest: inheritance', amount: 100)
				when 'Advance to GO'
					player.move('GO')
				when /jail free/
					player.jail_free_cards = player.jail_free_cards + 1
				when /take a chance/
					Transaction.new(from: player, to: game.bank, reason: 'community chest: avoiding a chance', amount: 10)
				end
			end
		end
	end
end