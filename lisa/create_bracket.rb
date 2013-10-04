Bundler.require

def partition_seeds seeds
	return seeds if seeds.length <= 2
	seeds_with_indices = seeds.each_with_index 
	partitioned_seeds_with_indices = seeds_with_indices.partition { |v,i| (i%4)==1 || (i%4)==2 }
	partitioned_seeds = partitioned_seeds_with_indices.map { |e| e.map { |v,i| v }}
	partitioned_seeds.map { |s| partition_seeds(s) }
end

all_episodes = begin
	full_hash = JSON.parse(File.read("data/episodes.json"))
	full_hash.map { |ep| "#{ep['season']}.#{ep['episode']} #{ep['title']}" }
end

episodes = all_episodes[0...512]
bracket = partition_seeds(episodes)
test_bracket = partition_seeds((0...16).to_a)

binding.pry