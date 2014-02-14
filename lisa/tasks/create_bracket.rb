Bundler.require
require File.dirname(__FILE__) + '/../lib/episode_loader'
require File.dirname(__FILE__) + '/../lib/bracket_creator'
require File.dirname(__FILE__) + '/../lib/lisa_config'

config = LisaConfig.from_argv(ARGV)
reddit_hash = EpisodeLoader.reddit_hash
episode_list = EpisodeLoader.local_imdb_list

bracket_creator = BracketCreator.new(config, reddit_hash, episode_list)

File.open(config.data_dir + "bracket.json", 'w') { |file|
	file << bracket_creator.bracket.to_json
}
File.open(config.data_dir + "episode_lineups.json", 'w') { |file|
  file << bracket_creator.episode_lineups.to_json
}
