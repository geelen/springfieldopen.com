require_relative '../lib/tournament_updater'
require_relative '../lib/tournament_creator'
require_relative '../lib/match_creator'

class TournamentManager

	def initialize config, reddit_poster
		@round_duration = config.round_duration
		@round_gap = config.round_gap
		@base_url = "http://www.reddit.com/r/#{config.subreddit}" 
		@reddit_poster = reddit_poster
		response = HTTParty.get(@base_url + "/new.json")
		@rounds = response['data']['children'].map { |r| r['data'] }
		@episode_subreddit = "SpringfieldOpenEps"
		@log_file = File.open(config.data_dir + "/log.txt", 'a')
		log_time
	end

	def log_time
		@log_file << Time.now.to_s
		@log_file << "\n"
	end

	def close_log
		@log_file.close
	end

	def begin_tournament
		tournament_creator = TournamentCreator.new(@reddit_poster,episodes)
		@log_file << "Preparing for tournament...\n"
		tournament_creator.prepare_for_tournment
		@log_file << "Creating round one matches...\n"
		matches = tournament_creator.round_one_matches
		round_name = tournament_creator.round_one_name
		match_creator = MatchCreator.new(@reddit_poster,round_name,@episode_subreddit)
		match_creator.create_matches(matches)
	end

	def perform_update_if_its_time
		@time_elapsed = calculate_elapsed_time
		@log_file << "Time elapsed: "
		@log_file << (@time_elapsed/60).floor
		@log_file << " min(s)\n"
		@time_buffer = 0.01
		updater = TournamentUpdater.new(@reddit_poster)
		identify_rounds		
		if time_to_end_the_round
			@log_file << "Determining match results...\n"
			determine_match_results(updater)
			@log_file << "Storing match results...\n"
			updater.store_results_of_round
			if upcoming_round
				@log_file << "Determing upcoming matches...\n"
				matches = updater.new_matches(episodes,upcoming_round_number)
				@log_file << "Creating upcoming matches...\n"
				match_creator = MatchCreator.new(@reddit_poster,upcoming_round_name,@episode_subreddit)
				match_creator.create_matches(matches)
			end
			@log_file << "Closing round...\n"
			updater.close_current_round(open_round_name,upcoming_round_name)
		elsif time_to_start_the_next_round
			@log_file << "Starting next round...\n"
			updater.open_next_round(upcoming_round_name)		
		else
			@log_file << "Nothing to do currently...\n"
		end
	end

	private

	def determine_match_results updater
		updater.find_results(poll_open_matches)
		cnt = 10
		while updater.undetermined_results
			if cnt > 0
				matches = poll_open_matches
				updater.update_results(matches)
				cnt -= 1
			else
				updater.randomly_allocate_remaining_results(matches)
				break
			end
		end
	end

	def poll_open_matches
		if open_round
			url = @base_url + "/comments/#{open_round['id']}.json"
			response = HTTParty.get(url)
			response.last['data']['children'].map { |match|
				data = match['data']
				eps = data['replies']['data']['children'].map { |ep| ep['data'] } 
				{ 
					name: data['name'],
					id: data['id'],
					body: data['body'],
					episodes: eps
				}
			}
		else
			[]
		end
	end

	def calculate_elapsed_time
		tournament_start_time = @rounds.first['created_utc']
		Time.now.utc.to_i - tournament_start_time
	end

	def identify_rounds
		@round_status = @rounds.map { |round| 
			response = HTTParty.get(@base_url + "/comments/#{round['id']}.json")
			JSON.parse(response.first['data']['children'].first['data']['selftext'])['status']
		}
		@log_file << "Rounds: "
		@log_file << @round_status.reverse.to_s
		@log_file << "\n"
		@open_index = @round_status.find_index { |s| s == 'open' }
		if @open_index && @open_index > 0
			@upcoming_index = @open_index - 1
		elsif @open_index
			@upcoming_index = nil
		else
			@upcoming_index = @round_status.find_index { |s| s == 'ready' }
		end
	end

	def open_round
		@open_index ? @rounds[@open_index] : nil
	end

	def upcoming_round
		@upcoming_index ? @rounds[@upcoming_index] : nil
	end

	def open_round_number
		@open_index ? @rounds.length - @open_index : nil
	end

	def upcoming_round_number
		@upcoming_index ? @rounds.length - @upcoming_index : nil
	end

	def open_round_name
		open_round ? open_round['name'] : nil
	end

	def upcoming_round_name
		upcoming_round ? upcoming_round['name'] : nil
	end

	def time_to_end_the_round
		if open_round_number
			t = @time_elapsed - @round_duration*(open_round_number-1)
			t > (@round_duration - @round_gap) - @time_buffer
		else
			false
		end
	end

	def time_to_start_the_next_round
		if upcoming_round_number && !open_round_number
			t = @time_elapsed - @round_duration*(upcoming_round_number-1)
			t > -@time_buffer
		else
			false
		end
	end

	def time_for_some_sort_of_update
		time_to_end_the_round || time_to_start_the_next_round
	end

	def episodes
		episodes_file = "data/staging/episode_lineups.json"
		@episodes ||= JSON.parse(File.read(episodes_file))
	end

end
