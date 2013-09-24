require 'httparty'
require 'nokogiri'
require 'json'

src = HTTParty.get("http://www.imdb.com/title/tt0096697/eprate?ref_=ttep_ql_3")
doc = Nokogiri::HTML(src)
eps = doc.search('#tn15content table:first-of-type tr:nth-child(n+2)').map { |ep|
  cells = ep.search('td')
  season, episode = cells[0].text.strip.split(".").map(&:to_i)
  title = cells[1].text
  rating = cells[2].text.to_f
  {season: season, epsiode: episode, title: title, rating: rating}
}

File.write(File.dirname(__FILE__) + "/data/episodes.json", eps.to_json)
