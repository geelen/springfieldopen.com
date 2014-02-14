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
      its(:bracket) { should == [[["1",nil], ["4", "5"]], [["2",nil], ["3",nil]]] }
    end
  end

  describe :lineups do
    context "with 2 episodes" do
      let(:keys_by_ranking) { [5, 1] }
      its(:lineups) { should == [
        { data: "5", lineup: [0] },
        { data: "1", lineup: [0] }
      ] }
    end

    context "with 4 episodes" do
      let(:keys_by_ranking) { [1, 2, 3, 4] }
      its(:lineups) { should == [
        { data: "1", lineup: [0,0] },
        { data: "4", lineup: [0,0] },
        { data: "2", lineup: [1,0] },
        { data: "3", lineup: [1,0] }
      ] }
    end

    context "with 8 episodes" do
      let(:keys_by_ranking) { [1, 2, 3, 4, 5, 6, 7, 8] }
      its(:lineups) { should == [
        { data: "1", lineup: [0,0,0] },
        { data: "8", lineup: [0,0,0] },
        { data: "4", lineup: [1,0,0] },
        { data: "5", lineup: [1,0,0] },
        { data: "2", lineup: [2,1,0] },
        { data: "7", lineup: [2,1,0] },
        { data: "3", lineup: [3,1,0] },
        { data: "6", lineup: [3,1,0] }
      ] }
    end

    context "with 5 episodes" do
      let(:keys_by_ranking) { [1, 2, 3, 4, 5] }
      its(:lineups) { should == [
        { data: "1", lineup: [0,0,0] },
        { data: nil, lineup: [0,0,0] },
        { data: "4", lineup: [1,0,0] },
        { data: "5", lineup: [1,0,0] },
        { data: "2", lineup: [2,1,0] },
        { data: nil, lineup: [2,1,0] },
        { data: "3", lineup: [3,1,0] },
        { data: nil, lineup: [3,1,0] }
      ] }
    end
  end
end
