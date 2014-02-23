class TournamentUpdater

	def initialize reddit_poster
		@reddit_poster = reddit_poster
	end

	def find_results matches
		@winners = [nil]*matches.length
		@results = [nil]*matches.length
		update_results(matches)
	end

	def undetermined_results
		@winners.any? { |e| e == nil }
	end

	def update_results matches
		parse_matches(matches).each_with_index { |match,i|
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
		parse_matches(matches).each_with_index { |match,i|
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

	def store_results_of_round
		@results.each { |result|
			data = JSON.parse(result[:body])
			data['final_score'] = "#{result[:ep1_score]}-#{result[:ep2_score]}"
			@reddit_poster.replace_text(result[:name], data)
		}
	end

	def new_matches all_episodes, round_number
		episodes = all_episodes.select { |episode| 
			@winners.include?(episode['data']['name'])
		}
		ep_pairs = episodes.group_by { |ep| 
			ep["lineup"][round_number-1] 
		}.values
		ep_pairs.map { |pair|
			pair.map { |ep| ep['data'] }
		}
	end
	
	def close_current_round current_round_name, current_round_data, upcoming_round_name, upcoming_round_data
		current_round_data['status'] = 'closed'
		@reddit_poster.replace_text(current_round_name, current_round_data)
		if upcoming_round_name
			upcoming_round_data['status'] = 'ready'
			@reddit_poster.replace_text(upcoming_round_name, upcoming_round_data)
		end
	end

	def open_next_round upcoming_round_name, upcoming_round_data
		upcoming_round_data['status'] = 'open'
		@reddit_poster.replace_text(upcoming_round_name, upcoming_round_data)
	end

	private

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

end