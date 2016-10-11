module Monotony
	# Conains predefined behaviours
	class DefaultBehaviour
		def consider_purchase(d)
			# If the next turn could land us somewhere more expensive than we can afford, purchase should be less likely
			# if d[:player].exposure.max > (d[:player].balance - d[:property].value)
			# 	d.factors << d[:player].personality.recklessness * 0.75
			# else
				d.factors << d[:player].personality.recklessness
			# end

			if d[:player].properties.collect{ |p| p.set }.include? d[:property].set
				# Will definitely buy if player already owns one or more of this set
				d.yes!
			elsif d[:game].players.collect { |p| p.properties.collect { |p| p.set } }.flatten.include? d[:property].set
				# Less likely to buy if another player already owns one of the set
				d.factors << d[:player].personality.hoarding * 0.5
			else
				# Will probably buy if nobody has bought any of this set yet
				d.factors << d[:player].personality.hoarding
			end
		end

		def consider_unmortgage(d)
			# Only bother unmortgaging something if I have the rest of the set, or it's less than 15% of my cash
			if d[:player].sets_owned.include? d[:property].set
				# Always if it completes a set
				d[:property].unmortgage!
			elsif ( d[:property].cost.to_f / d[:player].balance.to_f * 100.0 ) < 15.0
				# Only if we're not about to be stung for landing somewhere expensive
				# if d[:player].exposure.max > (d[:player].balance - d[:property].cost)
					d[:property].unmortgage!
				# end
			end
		end

		def consider_house_purchase(d)
			# Buy houses when possible, but don't spend more than 40% of my money on them in any one turn
			can_afford = ( ( d[:player].balance * 0.4 ) / d[:property].house_cost ).floor
			max_available = 4 - d[:property].num_houses
			d.outputs[:number_to_buy] = [ can_afford, max_available ].min

			# Think twice about buying a house if we're likely to land somewhere expensive next turn
			# if d[:player].exposure.max > (d[:player].balance - d[:property].house_cost)
				d.factors << d[:player].personality.recklessness
			# end
		end

		def consider_hotel_purchase(d)
			# Buy a hotel, unless it's more than two thirds of my current balance.
			if (d[:property].hotel_cost.to_f / d[:player].balance.to_f * 100.0) > 66.6
				d.no!
			else
				d.yes!
			end
		end

		def liquidate(s)
			portfolio = s[:player].properties.sort_by { |p| p.mortgage_value }
			while s[:player].balance < s[:amount] do
				if portfolio.length > 0
					property = portfolio.shift
					if property.is_a? BasicProperty
						if property.num_hotels == 1
							property = property.sell_hotel
						end
						break if s[:player].balance >= s[:amount]

						while property.num_houses > 0
							property = property.sell_houses(1)
							break if s[:player].balance >= s[:amount]
						end
						break if s[:player].balance >= s[:amount]

						property = property.mortgage!
					end
				else
					break
				end
			end
		end

		def consider_using_jail_card(d)
			# Unless less than 50% of active sets are mine, get out of jail with a card when possible
			d.yes! unless ( d[:player].sets_owned.count.to_f / d[:game].all_sets_owned.count.to_f * 100.0 ) < 50
		end
			
		def consider_proposing_trade(s)
			s[:game].log '[%s] Considering possible trades' % s[:player].name
		    invested_colours = s[:player].properties.collect(&:set).uniq
		    s[:player].opponents.each do |opponent|
		    	opponent.properties.select { |r| invested_colours.include? r.set }.each do |desirable_property|
		    		# s[:game].log '%s Considering %s' % [ s[:player].name, desirable_property.name ]
						d = Decision.new
		    		# e.g. 66% chance of buying if one property is owned, 99% chance of buying if two are
		    		d.factors << ( desirable_property.number_of_set_owned.to_f + 1.0 ) / desirable_property.number_in_set(s[:game]).to_f
		    		# More likely to trade if cash rich
						d.factors <<  s[:player].balance.to_f / 1000.to_f
		    		# More likely to trade if close to GO
		    		d.factors << 1 - ( s[:player].distance_to_go.to_f / s[:game].board.length.to_f )

		    		# We use these factors to work out how much to offer relative to how much we have
		    		if d.is_yes?
			    		offer_amount = s[:player].balance * d.factors.inject(&:*)

			    		if offer_amount > desirable_property.cost and s[:player].balance >= offer_amount
							s[:game].log '[%s] Placing offer of £%d on %s (owned by %s) [%f]' % [ s[:player].name, offer_amount, desirable_property.name, desirable_property.owner.name, d.factors.inject(&:*) * 100 ]

				    		desirable_property.place_offer(s[:player], offer_amount)
				    	end
				    end
		    	end
		    end
		end

		def consider_proposed_trade(d)
			# More likely to accept a trade the longer the game has been going on for (definitely at 100 turns)
			d.factors << ( [0, d[:game].turn, 100].sort[1].to_f / 100.0 ).to_f
			# More likely to accept a trade if it is far over the list price
			d.factors << 1 - ( d[:property].cost.to_f / d[:amount].to_f )
			# More likely to accept a trade if low on cash
			d.factors << 1 - ( d[:player].balance.to_f / 1000.to_f )

			# Random element
			d[:game].log '[%s] Considering offer of £%d for %s (from %s) [%f]' % [ d[:player].name, d[:amount], d[:property].name, d[:proposer].name, ( d.factors.collect{ |f| ( 100 / d.factors.count ) * f }.inject(:+) / 100 ) ]
		end
	end
	
	class EmptyBehaviour
		def consider_purchase(d)
		end

		def consider_unmortgage(d)
		end

		def consider_house_purchase(d)
		end

		def consider_hotel_purchase(d)
		end

		def liquidate(s)
		end

		def consider_using_jail_card(d)
		end

		def consider_proposing_trade(s)
		end

		def consider_proposed_trade(d)
		end
	end
end
