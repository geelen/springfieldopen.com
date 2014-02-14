require 'ostruct'

class LisaConfig
  def self.from_argv(argv)
    if argv.include? '--production'
      production_config
    else
      staging_config
    end
  end

  def self.production_config
    OpenStruct.new({
      data_dir: File.expand_path(File.dirname(__FILE__) + '/../data/production'),
      subreddit: 'SpringfieldOpen',
      total_episodes: 256,
      round_duration: 604800, #1.week
      round_gap: 86400, #1.day
    })
  end

  def self.staging_config
    OpenStruct.new({
      data_dir: File.expand_path(File.dirname(__FILE__) + '/../data/staging'),
      subreddit: 'SpringfieldOpenTest',
      total_episodes: 8,
      round_duration: 600, #10.minutes
      round_gap: 120, #2.minutes
    })
  end
end
