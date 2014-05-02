# Encoding: utf-8
class TasksController < ApplicationController

  WORD_STUB = "%WORD%".freeze # test
  ANSWER = 'снежные'.freeze
  #SERVER_URL = 'http://pushkin-contest.ror.by/quiz'.freeze
  SERVER_URL = 'http://localhost:3000/quiz'.freeze


  def index
    #token = Token.new
    #token.token = params[:token]
    #
    #if token.save
    #  data = {answer: ANSWER}
    #  render text: data.to_json
    #else
    #  render nothing: true
    #end

    q, a = generate_task4
    p q
    p a
    p '='*20
    p quiz(q)
    render nothing: true
  end

  def quiz(q)
    #token = Token.last.token
    #question = params[:question]
    #task_id = params[:id]
    question = q
    level = 4


    answer = case (level)
               when 1 then
                 level1(question)
               when 2 then
                 level2(question)
               when 3 then
                 level3(question)
               when 4 then
                 level4(question)
               when 5
                 5
               else
                 nil
             end

    answer ||= 'noting'
    p answer
    answer.mb_chars.downcase.to_s
    #if answer
    #  uri = URI(SERVER_URL)
    #  parameters = {answer: answer, token: token, task_id: task_id}
    #  Net::HTTP.post_form(uri, parameters)
    #end

    #render nothing: true
  end


  private

  def level1(question)
    poem = Poem.where('content like :question', question: "%#{question}%").limit(1).first.title
  end

  def level2(question)
    position = get_index_word(question)
    substring1, substring2 = get_substr(question)

    row = Row.where('content like :substr1 and content like :substr2', substr1: "%#{substring1}%", substr2: "%#{substring2}%").limit(1).first.content
    find_word(row, position)
  end

  def level3(question)
    q_str1, q_str2 = question.split("\n")
    substring1, substring2 = get_substr(q_str1)

    q_str1.gsub!(/[[:punct:]]\z/, '') unless q_str1[-1] == '%'
    q_str2.gsub!(/[[:punct:]]\z/, '') unless q_str2[-1] == '%'

    position_word1 = get_index_word(q_str1)
    position_word2 = get_index_word(q_str2)

    if position_word1.nil? || position_word2.nil?
      return 'error index of %WORD% !'
    end

    poems = Poem.where('content like :substr1 and content like :substr2', substr1: "%#{substring1}%", substr2: "%#{substring2}%").limit(1)

    unless poems.nil? || poems.empty?
      arr_str = poems.first.content.split("\n")
      arr_str.each_with_index do |str1, index|
        if str1.include? substring1 and str1.include? substring2
          str2 = arr_str[index + 1]

          str1.gsub!(/[[:punct:]]\z/, '')
          str2.gsub!(/[[:punct:]]\z/, '')

          return find_word(str1, position_word1) + ',' + find_word(str2, position_word2)
        end
      end
    end
    nil
  end


  def level4(question)
    q_str1, q_str2, q_str3 = question.split("\n")

    substring1, substring2 = get_substr(q_str1)

    position_word1 = get_index_word(q_str1)
    position_word2 = get_index_word(q_str2)
    position_word3 = get_index_word(q_str3)

    if position_word1.nil? || position_word2.nil? || position_word2.nil?
      return 'error index of %WORD% !'
    end

    poems = Poem.where('content like :substr1 and content like :substr2', substr1: "%#{substring1}%", substr2: "%#{substring2}%").limit(1)

    unless poems.nil? || poems.empty?
      arr_str = poems.first.content.split("\n")
      arr_str.each_with_index do |str1, index|
        if str1.include? substring1 and str1.include? substring2
          str2 = arr_str[index + 1]
          str3 = arr_str[index + 2]

          str1.gsub!(/[[:punct:]]\z/, '')
          str2.gsub!(/[[:punct:]]\z/, '')
          str3.gsub!(/[[:punct:]]\z/, '')

          return find_word(str1, position_word1) + ',' + find_word(str2, position_word2) + ',' + find_word(str3, position_word3)
        end
      end
    end
    nil
  end


  def level5(question)
    words = get_words(question)
    get_words(question).each do |word|
      row = get_row_by_word(word)
      a = right_row?(row, words, word)
      find_right_word(row) and break unless row.nil?
    end
  end

  private

  def right_row?(row, words, word)
    words_in_row = row.split(" ")
    return false unless words_in_row.count == words.count

  end

  def get_words(str)
    words = str.split(" ")
    #words.each {|word| word.gsub!(/[[:punct:]]\z/, '')}
    word.sort_by{|elem| elem.size}.reverse
  end

  def get_row_by_word(word)
    rows = Row.where('content like :word_find', word_find: "%#{word}%").limit(1)
    rows.first.content unless rows.nil? || rows.empty?
  end

  def find_right_word(row)

  end

  def get_substr(q_str)
    arr_substr = q_str.split(WORD_STUB)
    substring1 = arr_substr[0] || ''
    substring2 = arr_substr[1] || ''
    return substring1, substring2
  end

  def get_index_word(question_str)
    arr_words = question_str.split(" ")
    arr_words.each do |word|
      word.gsub!(/[[:punct:]]\z/, '') unless word[-1] == '%'
    end
    arr_words.index("%WORD%")
  end

  def find_word(row, index)
    return 'error in find_word' if row.nil? || index.nil?
    arr_words = row.split(" ")
    arr_words.each do |word|
      word.gsub!(/[[:punct:]]\z/, '')
    end
    return arr_words[index] if index < arr_words.length
    'error in find_word'
  end

  def result
    result = params[:result]
    render nothing: true
  end


  # ================= for test from pc ==================
  def words_to_answer(words)
    words.map { |word| word.mb_chars.downcase.to_s }.join(',')
  end

  def pick_word(string)
    words = string.to_s.split(/\s/)
    strip_punctuation words.sample
  end

  alias_method :pick_words, :pick_word

  def pick_line(string, number=1)
    lines = string.split("\n")
    start = lines.size >= number ? rand(0..lines.size-number) : 0
    lines[start...start+number]
  end

  alias_method :pick_lines, :pick_line

  def strip_punctuation(string)
    string.strip.gsub(/[[:punct:]]\z/, '')
  end

  # level 1
  def generate_task1
    poem = Poem.where("title NOT ILIKE ?", '%*%').last #random
    line = strip_punctuation pick_line(poem.content).first

    return line, strip_punctuation(poem.title.downcase)
  end

  #level 2
  def generate_task2
    poem = Poem.last #random

    line = strip_punctuation pick_line(poem.content).first
    word = pick_word(line)

    q = line.sub(word, WORD_STUB)
    a = strip_punctuation(words_to_answer([word]))

    return q, a
  end

  def generate_task3
    poem = Poem.last #random

    lines = pick_lines poem.content, 2
    words = lines.map { |line| pick_word(line) }
    question = words.map.with_index { |word, index| lines[index].sub(word, WORD_STUB) }.join("\n")

    return question, strip_punctuation(words_to_answer(words))
  end

  def generate_task4
    poem = Poem.last #random

    lines = pick_lines poem.content, 3
    words = lines.map {|line| pick_word(line) }
    question = words.map.with_index { |word, index| lines[index].sub(word, WORD_STUB) }.join("\n")

    return question, strip_punctuation(words_to_answer(words))
  end

  def generate_task5
    poem = Poem.random.first

    line = strip_punctuation pick_line(poem.content).first
    word = pick_word(line)

    return line.sub(word, random_word), strip_punctuation(words_to_answer([word, random_word]))
  end

  def random_word
    @random_word ||= generate_random_word
  end

  protected

  def generate_random_word
    poem = Poem.last
    line = pick_line(poem.content).first
    pick_word(line)
  end

end