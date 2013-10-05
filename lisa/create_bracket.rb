Bundler.require
require './episode_loader.rb'

def partition_seeds seeds
	return seeds if seeds.length <= 2
	seeds_with_indices = seeds.each_with_index 
	partitioned_seeds_with_indices = seeds_with_indices.partition { |v,i| (i%4)==1 || (i%4)==2 }
	partitioned_seeds = partitioned_seeds_with_indices.map { |e| e.map { |v,i| v }}
	partitioned_seeds.map { |s| partition_seeds(s) }
end

def episode_battles bracket, round_inds
	return [[bracket,round_inds[1..-1]]] unless bracket.is_a? Array
	battles = []
	bracket.each_with_index { |b,i| 
		ind = 2*round_inds.first + i
		battles += episode_battles(b, round_inds.dup.unshift(ind)) 
	}
	battles
end

reddit_hash = EpisodeLoader.reddit_hash
episode_list = EpisodeLoader.local_imdb_list
ranked_reddit_ids = episode_list.map { |episode| reddit_hash[episode] }
bracket = partition_seeds(ranked_reddit_ids[0...16])
episode_lineups = episode_battles(bracket, [0])

File.open(File.dirname(__FILE__) + "/data/bracket.json", 'w') { |file|
	file << bracket.to_json
}
File.open(File.dirname(__FILE__) + "/data/episode_lineups0.json", 'w') { |file|
	file << episode_lineups.to_json
}
