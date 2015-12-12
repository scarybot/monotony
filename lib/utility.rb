require 'monopoly_engine/square'
require 'monopoly_engine/purchasable'

module MonopolyEngine
	class Utility < PurchasableProperty
		def initialize(opts)
			super
			@set = :utilities
			@action = Proc.new do |game, owner, player, property|
				if owner
					rent = game.last_roll * ( owner.properties.collect { |p| p.is_a? Utility }.count == 2 ? 10 : 4 ) 
					player.pay(owner, rent)
				else
					player.behaviour[:purchase_possible].call(game, player, self) if player.currency >= cost
				end
			end
		end
	end
end