class BracketCreator

  def initialize(data_hash, keys_by_ranking)
    @data_hash = data_hash
    @keys_by_ranking = keys_by_ranking
  end

  def bracket
    @bracket ||= partition_seeds(ranked_reddit_ids)
  end

  def ranked_reddit_ids
    @ranked_reddit_ids ||= @keys_by_ranking.map { |episode| @data_hash[episode] }
  end

  def episode_lineups
    @episode_lineups ||= episode_battles(bracket, [0])
  end

  private

  def partition_seeds seeds
  	return seeds if seeds.length <= 2
  	seeds_with_indices = seeds.each_with_index
  	partitioned_seeds_with_indices = seeds_with_indices.partition { |v,i| (i%4)==0 || (i%4)==3 }
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
