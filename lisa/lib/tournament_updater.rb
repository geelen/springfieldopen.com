class TournamentUpdater

	def initialize match_loader, reddit_poster
		@reddit_poster = reddit_poster
		@match_loader = match_loader
	end

	def run
		puts "Determining match results..."
		determine_match_results
		puts "Storing match results..."
		store_results_of_round
	end

	def new_matches all_episodes, round
		round_name = @match_loader.upcoming_round['name']
		episodes = all_episodes.select { |episode| 
			@winners.include?(episode['data']['name'])
		}
		ep_pairs = episodes.group_by { |ep| ep["lineup"][round-1] }.values
		ep_pairs.map { |pair|
			pair.map { |ep| ep['data'] }
		}
	end
	
	def start_new_round
		puts "Starting next round..."
		@reddit_poster.replace_text(current_round_name, {status: 'closed'})
		@reddit_poster.replace_text(upcoming_round_name, {status: 'open'})
	end

	def upcoming_round_name
		@match_loader.upcoming_round['name']
	end

	def current_round_name
		@match_loader.open_round['name']
	end

	private

	def determine_match_results
		matches = @match_loader.open_matches
		@winners = [nil]*matches.length
		@results = [nil]*matches.length
		update_results(parse_matches(matches))
		cnt = 10
		while @winners.any? { |e| e == nil }
			if cnt > 0
				matches = @match_loader.open_matches
				update_results(parse_matches(matches))
				cnt -= 1
			else
				randomly_allocate_remaining_results(parse_matches(matches))
				break
			end
		end
	end

	def store_results_of_round
		@results.each { |result|
			data = JSON.parse(result[:body])
			data['final_score'] = "#{result[:ep1_score]}-#{result[:ep2_score]}"
			@reddit_poster.replace_text(result[:name], data)
		}
	end

	def parse_matches matches
		matches.map { |match| 
			eps = match[:episodes]
			{
				name: match[:name],
				id: match[:id],
				body: match[:body],
				ep1_name: JSON.parse(eps[0]["body"])["name"],
				ep1_score: eps[0]['ups']-eps[0]['downs'],
				ep2_name: JSON.parse(eps[1]["body"])["name"],
				ep2_score: eps[1]['ups']-eps[1]['downs'] 
			}
		}
	end

	def update_results matches
		matches.each_with_index { |match,i|
			if @results[i] == nil
				if match[:ep1_score] > match[:ep2_score]
					@results[i] = match
					@winners[i] = match[:ep1_name]
				elsif match[:ep1_score] < match[:ep2_score]
					@results[i] = match
					@winners[i] = match[:ep2_name]
				end
			end
		}
	end

	def randomly_allocate_remaining_results matches
		matches.each_with_index { |match,i|
			if @results[i] == nil
				if (rand < 0.5)
					match[:ep1_score] += 1
					@winners[i] = match[:ep1_name]
				else
					match[:ep2_score] += 1
					@winners[i] = match[:ep2_name]
				end
				@results[i] = match
			end
		}
	end
end