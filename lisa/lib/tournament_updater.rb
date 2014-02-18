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
		puts "Creating new matches..."
		create_new_matches
		puts "Starting next round..."
		update_statuses # (is this a word)
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

	def create_new_matches
		round_name = @match_loader.upcoming_round['name']
		@winners.each { |winner|
			# something...
		}
	end

	def update_statuses
		current_round_name = @match_loader.open_round['name']
		next_round_name = @match_loader.upcoming_round['name']
		@reddit_poster.replace_text(current_round_name, {status: 'closed'})
		@reddit_poster.replace_text(next_round_name, {status: 'open'})
	end

	def parse_matches matches
		matches.map { |match| 
			eps = match[:episodes]
			{
				name: match[:name],
				id: match[:id],
				body: match[:body],
				ep1_details: eps[0]["body"],
				ep1_score: eps[0]['ups']-eps[0]['downs'],
				ep2_details: eps[1]["body"],
				ep2_score: eps[1]['ups']-eps[1]['downs'] 
			}
		}
	end

	def update_results matches
		matches.each_with_index { |match,i|
			if @results[i] == nil
				if match[:ep1_score] > match[:ep2_score]
					@results[i] = match
					@winners[i] = match[:ep1_details]
				elsif match[:ep1_score] < match[:ep2_score]
					@results[i] = match
					@winners[i] = match[:ep2_details]
				end
			end
		}
	end

	def randomly_allocate_remaining_results matches
		matches.each_with_index { |match,i|
			if @results[i] == nil
				if (rand < 0.5)
					match[:ep1_score] += 1
					@winners[i] = match[:ep1_details]
				else
					match[:ep2_score] += 1
					@winners[i] = match[:ep2_details]
				end
				@results[i] = match
			end
		}
	end
end