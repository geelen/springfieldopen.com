class BracketCreator

  def initialize(config, reddit_hash, episode_list)
    @config = config
    @reddit_hash = reddit_hash
    @episode_list = episode_list
  end

  def bracket
    @bracket ||= partition_seeds(ranked_reddit_ids[0...@config.total_episodes])
  end

  def ranked_reddit_ids
    @ranked_reddit_ids ||= @episode_list.map { |episode| [episode, @reddit_hash[episode]] }
  end

  def episode_lineups
    @episode_lineups ||= episode_battles(bracket, [0])
  end

  private

  def partition_seeds seeds
  	return seeds if seeds.length <= 2
  	seeds_with_indices = seeds.each_with_index
  	partitioned_seeds_with_indices = seeds_with_indices.partition { |v,i| (i%4)==1 || (i%4)==2 }
  	partitioned_seeds = partitioned_seeds_with_indices.map { |e| e.map { |v,i| v }}
  	partitioned_seeds.map { |s| partition_seeds(s) }
  end

  def episode_battles bracket, round_inds
  	return [[bracket,round_inds[1..-1]]] unless bracket.first.is_a? Array
  	battles = []
  	bracket.each_with_index { |b,i|
  		ind = 2*round_inds.first + i
  		battles += episode_battles(b, round_inds.dup.unshift(ind))
  	}
  	battles
  end

end
