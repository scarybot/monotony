module Monotony

	# Represents any landable square on the board.
	class Square
		attr_accessor :action, :name, :owner, :colour

		# @return [Symbol] Returns the name of the set containing this property.
		attr_accessor :set

		# @param [Hash] opts
		# @option opts [Symbol] :set a symbol identifying this property as a member of a set of properties.
		# @option opts [String] :name the name of the property.
		# @option opts [Proc] :action a procedure to run when a player lands on this square.
		# @option opts [Symbol] :colour the colour to use when rendering this square on a GUI.
		def initialize(opts)
			@owner = nil
			@set = opts[:set] || nil
			@name = opts[:name]
			@action = opts[:action] || Proc.new {|game, owner, player, property|}
			@colour = opts[:colour] || ( String.colors.include? opts[:set] ? opts[:set] : :light_black )
		end
	end
end