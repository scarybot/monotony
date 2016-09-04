module Monotony
	# Conains predefined behaviours
	class DefaultBehaviour
		DEFAULT = {
			purchase_possible: Proc.new { |d| 
				# If the next turn could land us somewhere more expensive than we can afford, purchase should be less likely
				if d[:player].exposure.max > (d[:player].balance - d[:property].value)
					d.factors << d[:player].personality.risktaking * 0.75
				else
					d.factors << d[:player].personality.risktaking
				end

				if d[:player].properties.collect{ |p| p.set }.include? d[:property].set
					# Will definitely buy if player already owns one or more of this set
					d.yes
				elsif d[:game].players.collect { |p| p.properties.collect { |p| p.set } }.flatten.include? d[:property].set
					# Less likely to buy if another player already owns one of the set
					d.factors << d[:player].personality.hoarding * 0.5
				else
					# Will probably buy if nobody has bought any of this set yet
					d.factors << d[:player].personality.hoarding
				end
			},
			unmortgage_possible: Proc.new { |d|
				# Only bother unmortgaging something if I have the rest of the set, or it's less than 15% of my cash
				if d[:player].sets_owned.include? d[:property].set
					# Always if it completes a set
					d[:property].unmortgage
				elsif ( d[:property].cost.to_f / d[:player].balance.to_f * 100.0 ) < 15.0
					# Only if we're not about to be stung for landing somewhere expensive
					if d[:player].exposure.max > (d[:player].balance - d[:property].cost)
						d[:property].unmortgage
					end
				end
			},
			houses_available: Proc.new { |d|
				# Buy houses when possible, but don't spend more than 40% of my money on them in any one turn
				can_afford = ( ( d[:player].balance * 0.4 ) / d[:property].house_cost ).floor
				max_available = 4 - d[:property].num_houses
				d.outputs[:to_buy] = [ can_afford, max_available ].min

				# Think twice about buying a house if we're likely to land somewhere expensive next turn
				if d[:player].exposure.max > (d[:player].balance - d[:property].house_cost)
					d.factors << d[:player].personality.recklessness
				end
			},
			hotel_available: Proc.new { |d|
				# Buy a hotel, unless it's more than two thirds of my current balance.
				if d[:property].hotel_cost.to_f / d[:player].balance.to_f * 100.0) > 66.6
					d.no!
				else
					d.yes!
				end
			},
			out_of_cash: Proc.new { |s|
				portfolio = s[:player].properties.sort_by { |p| p.mortgage_value }
				while s[:player].balance < amount do
					if portfolio.length > 0
						property = portfolio.shift
						if property.is_a? BasicProperty
							if property.num_hotels == 1
								property = property.sell_hotel
							end
							break if s[:player].balance >= amount

							while property.num_houses > 0
								property = property.sell_houses(1)
								break if s[:player].balance >= amount
							end
							break if s[:player].balance >= amount

							property = property.mortgage
						end
					else
						break
					end
				end
			},
			use_jail_card: Proc.new { |d|
				# Unless less than 50% of active sets are mine, get out of jail with a card when possible
				d.yes! unless ( d[:player].sets_owned.count.to_f / d[:game].all_sets_owned.count.to_f * 100.0 ) < 50
			},
			trade_possible: Proc.new { |s|
				game.log '[%s] Considering possible trades' % s[:player].name
			    invested_colours = s[:player].properties.collect(&:set).uniq
			    s[:player].opponents.each do |opponent|
			    	opponent.properties.select { |r| invested_colours.include? r.set }.each do |desirable_property|
			    		d = Decision.new
			    		# e.g. 66% chance of buying if one property is owned, 99% chance of buying if two are
			    		d.factors << ( desirable_property.number_of_set_owned.to_f + 1.0 ) / desirable_property.number_in_set(game).to_f
			    		# More likely to trade if cash rich
						d.factors << = s[:player].balance.to_f / 1000.to_f
			    		# More likely to trade if close to GO
			    		d.factors << 1 - ( s[:player].distance_to_go.to_f / s[:game].board.length.to_f )

			    		# We use these factors to work out how much to offer relative to how much we have
			    		if d.outcome.is_yes?
				    		offer_amount = s[:player].balance * d.factors.values.inject(&:*)

				    		if offer_amount > desirable_property.cost and s[:player].balance >= offer_amount
								s[:game].log '[%s] Placing offer of £%d on %s (owned by %s) [%f]' % [ s[:player].name, offer_amount, desirable_property.name, desirable_property.owner.name, d.factors.values.inject(&:*) * 100 ]

					    		desirable_property.place_offer(player, offer_amount)
					    	end
					    end
			    	end
			    end
			},
			trade_proposed: Proc.new { |d|
				# More likely to accept a trade the longer the game has been going on for (definitely at 100 turns)
				d.factors << ( [0, d[:game].turn, 100].sort[1].to_f / 100.0 ).to_f
				# More likely to accept a trade if it is far over the list price
				d.factors << 1 - ( d[:property].cost.to_f / amount.to_f )
				# More likely to accept a trade if low on cash
				d.factors << 1 - ( d[:player].balance.to_f / 1000.to_f )

				# Random element
				game.log '[%s] Considering offer of £%d for %s (from %s) [%f]' % [ d[:player].name, amount, d[:property].name, d[:proposer].name, ( d.factors.values.collect{ |f| ( 100 / d.factors.count ) * f }.inject(:+) / 100 ) ]
			}
		}

		SIMULATION = {
			purchase_possible: Proc.new { |game, player, property| },
			unmortgage_possible: Proc.new { |game, player, property| },
			houses_available: Proc.new { |game, player, property| },
			hotel_available: Proc.new { |game, player, property| },
			money_trouble: Proc.new { |game, player, amount| },
			use_jail_card: Proc.new { |game, player| },
			trade_possible: Proc.new { |game, player| },
			trade_proposed: Proc.new { |game, player, proposer, property, amount| }
		}
	end
end
