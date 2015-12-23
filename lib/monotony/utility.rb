require 'monotony/square'
require 'monotony/purchasable'

module Monotony
	# Represents a utility tile, such as the Electricity Company or Water Works.
	class Utility < PurchasableProperty

		# @param opts [Hash]
		# @option opts [String] :name A symbol identifying this property as a member of a set of properties.
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