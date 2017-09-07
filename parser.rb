tmp = open('resorts.html')
page = Nokogiri::HTML(tmp)
resorts = page.css("li.menu__item").map{|mi| {resort: mi.children.css("a").first.text.downcase.tr(" ", "_"), cams:mi.css("li.submenu__item a").map{|a| {id: a['href'][/([^\/]+)$/], link: a['href'], title: a.text}}}}