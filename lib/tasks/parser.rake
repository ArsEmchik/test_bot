namespace :db do
  task :parse => :environment do
    Poem.delete_all

    URL = "http://ilibrary.ru/text/"

    mechanize = Mechanize.new { |agent|
      agent.user_agent_alias = 'Linux Firefox'
    }

    page = mechanize.get("http://ilibrary.ru/author/pushkin/l.all/index.html")
    links = page.parser.css('.list a')

    id_poems = links.map { |l| l.attributes['href'].value.scan(/\d{3}/).join }
    id_poems = id_poems.drop(8) # drop links to categories

    num = 0
    size = id_poems.size

    id_poems.each do |id|
      link = URL + id + "/p.1/index.html"

      page = mechanize.get(link)

      title = page.parser.css('.title h1').text
      text = page.parser.css('.poem_main').text
      text.gsub!(/\u0097/, "\u2014") # replacement of unprintable symbol
      text.gsub!(/^\n/, "") # remove first \n

      puts "=".cyan*30
      puts title.green
      puts text.red
      puts "#{num} of #{size}".cyan
      num += 1

      poem = Poem.new
      poem.title = title
      poem.content = text
      poem.save
    end
    clear_database
    fill_rows_table
  end

  # created by ars
  def clear_database
    p 'подговка db'
    Poem.delete_all("title = '' and content = ''")
    poems = Poem.all
    poems.each do |poem|
      id = Poem.where('content = :content', content: poem.content).first.id
      Poem.delete_all(['content = :content and id > :id', content: poem.content, id: id])
    end
  end



  def fill_rows_table
    Row.delete_all
    p 'идет разбиение на строки'
    count1 = 0
    count2 = 0

    poems = Poem.all
    poems.each do |p|
      count1 += 1
      next if p.content.empty?
      count2 += fill_row(p.content)
    end

    p count1
    p count2
  end

  def fill_row(content)
    count2 = 0 #for test

    row_arr = content.split("\n")
    row_arr.each do |r|
      count2 += 1

      row = Row.new
      row.content = r
      row.save
    end
    count2
  end
end
