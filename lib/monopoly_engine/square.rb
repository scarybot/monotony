module MonopolyEngine
	class Square
		attr_accessor :action, :name, :owner, :colour, :set
		def initialize(opts)
			@owner = nil
			@set = opts[:set] || nil
			@name = opts[:name]
			@action = opts[:action] || Proc.new {|game, owner, player, property|}
			@colour = opts[:colour] || ( String.colors.include? opts[:set] ? opts[:set] : :light_black )
		end
	end
end