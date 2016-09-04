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
		end

		def action(**args)
			if @owner
				rent = @owner.game.last_roll * ( @owner.properties.collect { |p| p.is_a? Utility }.count == 2 ? 10 : 4 ) 
				Transaction.new(from: args[:player], to: @owner, reason: 'utility rent on %s' % @name, amount: rent)
			end

			super
		end
	end
end