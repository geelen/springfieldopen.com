Bundler.require

src = HTTParty.get("http://simpsons.wikia.com/wiki/List_of_episodes")
doc = Nokogiri::HTML(src)

episodes = []
doc.search('#mw-content-text table').each_with_index { |table,i|
	next if i == 0 
	table.search('tr').each_with_index { |row,j|
		next if j%2 == 0 
		cells = row.search('td')
		attrs = cells[0].children[1].children[0].attributes
		title = attrs['title'].value
		link = attrs['href'].value
		ep_src = HTTParty.get("http://simpsons.wikia.com#{link}")
		ep_doc = Nokogiri::HTML(ep_src)
		images = ep_doc.search('#mw-content-text img').map { |image| 
			url = image.parent.attributes['href']
			if url && url.value.include?("http://images")
				if url.value.include?("Australian_Flag.png")
					nil
				elsif url.value.include?("Flag_of_the_United_States.svg.png")
					nil
				else
					url.value
				end
			else
				nil
			end
		}.compact
		synopsis = ""
		attention = false
		ep_doc.search('#mw-content-text h2').each { |heading|
			if heading.search('#Synopsis').length > 0
				synopsis = heading.next_sibling.next_sibling.children.map { |e|
					e.attributes['title'] ? e.attributes['title'].value : e.text
				}.join("").strip
				break
			end
		}
		if synopsis == ""
			attention = true
			paragraph = ep_doc.search('#mw-content-text p').first
			element = paragraph
			while element && !(['table','h2','h3'].include?(element.name))
				element = element.children.first if element.name == "p"
				if element.name != "figure"
					synopsis << (element.attributes['title'] ? element.attributes['title'].value : element.text)
				end
				element = element.next_sibling
				if !element
					paragraph = paragraph.next_sibling
					element = paragraph
				end
			end
			synopsis = synopsis.strip
		end
		episodes << {season: i, episode: (j+1)/2, title: title, synopsis: synopsis, images: images, synopsis_needs_attention: attention}
	}
}

File.open(File.dirname(__FILE__) + "/data/wikia_episodes.json", 'w') { |file| 
	file << episodes.to_json
}
