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

  def lineups
    @lineups ||= create_lineups
  end

  private

  def partition_seeds seeds
  	return seeds if seeds.length <= 2
  	seeds_with_indices = seeds.each_with_index
  	partitioned_seeds_with_indices = seeds_with_indices.partition { |v,i| (i%4)==0 || (i%4)==3 }
  	partitioned_seeds = partitioned_seeds_with_indices.map { |e| e.map { |v,i| v }}
  	partitioned_seeds.map { |s| partition_seeds(s) }
  end

  def create_lineups
    num_rounds = Math.log2(ranked_reddit_ids.length).to_i
    bracket.flatten.each_with_index.map do |data, i|
      {data: data, lineup: 1.upto(num_rounds).map { |round|
        i / 2**round
      }}
    end
  end

end
