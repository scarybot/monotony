require 'monotony/square'
require 'monotony/purchasable'

module Monotony
	# Represents a railway station tile.
	class Station < PurchasableProperty
		# @param [Hash] opts
		# @option opts [String] :name the name of the station.
		# @option opts [Symbol] :colour the colour to use when rendering this square on a GUI.
		def initialize(opts)
			super
			@set = :stations
			@action = Proc.new do |game, owner, player, property|
				if owner
					rent = [ 25, 50, 100, 200 ]
					multiplier = owner.properties.select { |p| p.is_a? Station }.count
					player.pay(owner, rent[multiplier - 1])
				else
					player.behaviour[:purchase_possible].call(game, player, self) if player.currency >= cost
				end
			end
		end
	end
end