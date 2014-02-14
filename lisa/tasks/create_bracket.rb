Bundler.require
require_relative '../lib/episode_loader'
require_relative '../lib/bracket_creator'
require_relative '../lib/lisa_config'

config = LisaConfig.from_argv(ARGV)
reddit_hash = EpisodeLoader.reddit_hash
episode_keys_by_imdb_ranking = EpisodeLoader.episode_keys_by_imdb_ranking

bracket_creator = BracketCreator.new(config, reddit_hash, episode_keys_by_imdb_ranking)

File.open(config.data_dir + "/bracket.json", 'w') { |file|
	file << JSON.pretty_generate(bracket_creator.bracket)
}
File.open(config.data_dir + "/episode_lineups.json", 'w') { |file|
  file << JSON.pretty_generate(bracket_creator.episode_lineups)
}
