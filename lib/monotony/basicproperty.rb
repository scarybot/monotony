require 'monotony/square'
require 'monotony/purchasable'

module Monotony
	# A property class representing the majority of properties on the board.
	class BasicProperty < PurchasableProperty
		# @return [Integer] Returns the cost of purchasing a house on this property.
		attr_accessor :house_cost
		# @return [Integer] Returns the cost of purchasing a hotel on this property.
		attr_accessor :hotel_cost
		# @return [Symbol] Returns the name of the set containing this property.
		attr_accessor :set
		# @return [Integer] Returns the number of houses on this property.
		attr_accessor :num_houses
		# @return [Integer] Returns the number of hotels on this property.
		attr_accessor :num_hotels
		# @return [Array<Integer>] Returns an array of six elements containing rent values for an property with no houses, one house, two houses, three houses, four houses, and a hotel.
		attr_accessor :rent
		# @param opts [Hash]
		# @option opts [Array<Integer>] :rent An array of six elements containing rent values for an property with no houses, one house, two houses, three houses, four houses, and a hotel.
		# @option opts [Integer] :house_cost The cost of purchasing a house on this property.
		# @option opts [Integer] :hotel_cost The cost of purchasing a hotel on this property. Traditionally equal to house_cost.
		# @option opts [Symbol] :set A symbol identifying this property as a member of a set of properties.
		def initialize(opts)
			super
			@rent = opts[:rent]
			@house_cost = opts[:house_cost]
			@hotel_cost = opts[:hotel_cost]
			@set = opts[:set]
			@num_houses = 0
			@num_hotels = 0
			@action = Proc.new do |game, owner, player, property|
				if owner
					if set_owned?
						rent_to_pay = (property.num_hotels  == 1 ? property.rent[5] : ( property.num_houses == 0 ? (@rent[0] * 2) :  property.rent[property.num_houses] ) )
					else
						rent_to_pay = property.rent[0]
					end
					if owner != player
						if not owner.is_out? and not is_mortgaged?
							game.log '[%s] Due to pay £%d rent to %s for landing on %s with %s' % [ player.name, rent_to_pay, owner.name, property.name, ( property.num_hotels == 1 ? 'a hotel' : '%d houses' % property.num_houses) ]
							Transaction.new(from: player, to: owner, reason: 'rent on %s' % property.name, amount: rent_to_pay)
						end
					end
				else
					player.behaviour[:purchase_possible].call(game, player, self) if player.balance >= cost
				end
			end
		end

		# Mortgage the property to raise cash for its owner.
		# @return [self]
		def mortgage
			super
			properties_in_set(@owner.game).each do |other|
				other.sell_hotel if @num_hotels > 0
				other.sell_houses if @num_houses > 0
			end
			self
		end

		# Buy houses on the property.
		# @param [Integer] number number of houses to add to the property.
		# @return [self]
		def add_houses(number)
			number = number.to_int
			housing_value = @house_cost * number
			if @owner.game.num_houses >= number
				if (@num_houses + number) > 4
					@owner.game.log '[%s] Cannot place more than 4 houses on %s' % [ @owner.name, @name ]
				else
					if @owner.balance < housing_value
						@owner.game.log '[%s] Unable to buy %d houses! (short of cash by £%d)' % [ @owner.name, number, (housing_value - @owner.balance) ]
						false
					else
						Transaction.new(from: @owner, to: @owner.game.bank, reason: 'housing purchase on %s' % @name, amount: housing_value)
						@owner.game.num_houses = @owner.game.num_houses - number
						@num_houses = @num_houses + number
						@owner.game.log '[%s] Purchased %d houses on %s for £%d (new balance: £%d)' % [ @owner.name, number, @name, housing_value, @owner.balance ]
						true
					end
				end
			else
				@owner.game.log '[%s] Not enough houses left to purchase %d more for %s' % [ @owner.name, number, @name ]
			end
			self
		end

		# Sell houses from the property.
		# @param [Integer] number number of houses to sell from the property.
		# @return [self]
		def sell_houses(number)
			number = number.to_int
			housing_value = (@house_cost / 2) * number
			if number > @num_houses
				@owner.game.log "[%s] Can't sell %d houses on %s, as there are only %d" % [ @owner.name, number, @name, @num_houses ]
				false
			else
				@num_houses = @num_houses - number
				@owner.game.num_houses = @owner.game.num_houses + number
				Transaction.new(to: @owner, from: @owner.game.bank, amount: housing_value, reason: 'housing sale on %s' % @name)
				@owner.game.log '[%s] Sold %d houses on %s for £%d (%d remaining)' % [ @owner.name, number, @name, housing_value, @num_houses ]
			end
			self
		end

		# Buy a hotel on the property.
		# @return [self]
		def add_hotel
			if @num_houses == 4
				if @owner.game.num_houses > 0
					if @owner.balance < @hotel_cost
						@owner.game.log '[%s] Unable to buy a hotel! (short of cash by £%d)' % [ @owner.name, (@hotel_cost - @owner.balance) ]
					else
						Transaction.new(to: @owner.game.bank, from: @owner, amount: @hotel_cost, reason: 'hotel purchase on %s' % @name)
						@num_houses, @num_hotels = 0, 1
						@owner.game.num_houses = @owner.game.num_houses + 4
						@owner.game.num_hotels = @owner.game.num_hotels - 1
						@owner.game.log '[%s] Purchased a hotel on %s for £%d (new balance: £%d)' % [ @owner.name, @name, @hotel_cost, @owner.balance ]
					end			
				else
					@owner.game.log '[%s] Not enough hotels left to purchase one for %s' % [ @owner.name, @name ]
				end
			end
			self
		end

		# Sell hotels from the property.
		# @return [self]
		def sell_hotel
			if @num_hotels < 1
				@owner.game.log "[%s] Can't sell hotel on %s, as there isn't one!" % [ @owner.name, @name ]
			else
			 	housing_value = (@hotel_cost / 2) 
				@num_hotels = 0
				@owner.game.num_hotels = @owner.game.num_hotels + 1
				Transaction.new(to: @owner, from: @owner.game.bank, amount: housing_value, reason: 'hotel sale on %s' % @name)
				@owner.game.log '[%s] Sold hotel on %s for £%d' % [ @owner.name, @name, housing_value ]

				case @owner.game.num_houses
				when 1..3
					sell_houses(4 - @owner.game.num_houses)
					@owner.game.log '[%s] Devolved %s to %d houses as 4 were not available' % [ @owner.name, @name, @num_houses ]
				when 0
					sell_houses(4)
					@owner.game.log '[%s] Devolved to undeveloped site as no houses were available' % [ @owner.name, @name, @num_houses ]
				else
					@owner.game.num_houses = @owner.game.num_houses - 4
					@num_houses = 4
					@owner.game.log '[%s] Devolved %s to %d houses' % [ @owner.name, @name, @num_houses ]
				end
			end
			self
		end

		# Draw an ASCII representation of this property's housing.
		# @return [void]
		def display_house_ascii
			house_array = []
			house_string = ''

			if @num_hotels == 1
				house_string << '   '.colorize(:background => :light_black) + '     '.colorize(:background => :red) + '   '.colorize(:background => :light_black)
			else
				until house_array.length == @num_houses
					house_array << '  '.colorize(:background => :green) 
				end
				until house_array.length == 4
					house_array << '  '.colorize(:background => :light_black)
				end

				house_string = house_array.join(' '.colorize(:background => :light_black))
			end
			house_string + ' '.colorize(:color => :default)
		end
	end
end