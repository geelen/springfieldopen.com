Bundler.require

def partition_seeds seeds
	return seeds if seeds.length <= 2
	seeds_with_indices = seeds.each_with_index 
	partitioned_seeds_with_indices = seeds_with_indices.partition { |v,i| (i%4)==1 || (i%4)==2 }
	partitioned_seeds = partitioned_seeds_with_indices.map { |e| e.map { |v,i| v }}
	partitioned_seeds.map { |s| partition_seeds(s) }
end

subreddit = "SpringfieldOpenEps"
reddit_hash = begin
	response = HTTParty.get("http://www.reddit.com/r/#{subreddit}.json?limit=100")
	full_episode_details = response['data']['children'].map { |child| child['data'] }
	last_id = (full_episode_details.empty?) ? nil : full_episode_details[-1]['name']
	while last_id
		response = HTTParty.get("http://www.reddit.com/r/#{subreddit}.json?limit=100&after=#{last_id}")
		new_episode_details = response['data']['children'].map { |child| child['data'] }
		last_id = (new_episode_details.empty?) ? nil : new_episode_details[-1]['name']
		full_episode_details += new_episode_details
	end
	Hash[full_episode_details.map { |ep| [ep['title'], ep['name']] }]
end

imdb_list = begin
	full_hash = JSON.parse(File.read("data/episodes.json"))
	full_hash.map { |ep| "#{ep['season']}.#{ep['episode']} #{ep['title']}" } 
end

updated_list = imdb_list.map { |episode| reddit_hash[episode] }

episodes = updated_list[0...512]
bracket = partition_seeds(episodes)

File.open(File.dirname(__FILE__) + "/data/bracket.json", 'w') { |file|
	file << bracket.to_json
}

