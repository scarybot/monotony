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
		end

		def action(**args)
			if owner
				rent = [ 25, 50, 100, 200 ]
				multiplier = args[:owner].properties.select { |p| p.is_a? Station }.count
				Transaction.new(from: args[:player], to: args[:owner], reason: 'railway station', amount: rent[multiplier - 1])
			end
			super
		end
	end
end