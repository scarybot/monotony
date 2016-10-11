module Monotony
	class Personality
		attr_accessor :patience, :recklessness, :hoarding, :stubbornness, :opportunism
		def initialize(opts)
			opts = {
				:patience => Random.rand(0..1),
				:recklessness => Random.rand(0..1),
				:hoarding => Random.rand(0..1),
				:stubbornness => Random.rand(0..1),
				:opportunism => Random.rand(0..1)
			}.merge(opts)

			@patience = opts[:patience],
			@recklessness = opts[:recklessness],
			@hoarding = opts[:hoarding],
			@stubbornness = opts[:stubbornness],
			@opportunism = opts[:opportunism]

			self
		end
	end
end
