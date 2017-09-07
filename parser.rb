require 'nokogiri'
require 'open-uri'
require 'json'

page = Nokogiri::HTML(open('https://snig.info/en'))
resorts = page.css('li.menu__item').map do |mi|
  { resort: mi.children.css('a').first.text.downcase.tr(' ', '_'),
    cams: mi.css('li.submenu__item a').map do |a|
      {
        id: a['href'][/([^\/]+)$/],
        title: a.text
      }
    end
  }
end
resorts.shift

File.open('resorts.json', 'w') do |f|
  f.write(JSON.pretty_generate(resorts))
end