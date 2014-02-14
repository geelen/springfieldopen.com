Bundler.require

require_relative '../lib/bracket_creator'

describe BracketCreator do
  let(:data_hash) { Hash[1.upto(32).map { |i| [i, i.to_s ]}] }
  subject { BracketCreator.new(data_hash, keys_by_ranking) }

  describe :bracket do
    context "with 2 episodes" do
      let(:keys_by_ranking) { [5, 1] }
      its(:bracket) { should == ["5", "1"] }
    end

    context "with 4 episodes" do
      let(:keys_by_ranking) { [1, 2, 3, 4] }
      its(:bracket) { should == [["1", "4"], ["2", "3"]] }
    end

    context "with 8 episodes" do
      let(:keys_by_ranking) { [1, 2, 3, 4, 5, 6, 7, 8] }
      its(:bracket) { should == [[["1", "8"], ["4", "5"]], [["2", "7"], ["3", "6"]]] }
    end

    context "with 5 episodes" do
      let(:keys_by_ranking) { [1, 2, 3, 4, 5] }
      its(:bracket) { should == [[["1"], ["4", "5"]], ["2", "3"]] }
    end
  end
end
