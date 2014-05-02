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

    q, a = generate_task3
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
    level = 3


    answer = case (level)
               when 1 then
                 level1(question)
               when 2 then
                 level2(question)
               when 3 then
                 level3(question)
               when 4 then
                 4
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
    str_sql, position = prepare_str(question)
    poems = Poem.where("content_text @@ to_tsquery('pg_catalog.russian', '#{str_sql}')").limit(1)
    poems.first.title unless poems.nil? || poems.empty?
  end

  def level2(question)
    str_sql, position = prepare_str(question)
    rows = Row.where("content_text @@ to_tsquery('pg_catalog.russian', '#{str_sql}')").limit(1)

    find_word(rows.first.content, position) unless rows.nil? || rows.empty?
  end

  def level3(question)
    q_str1, q_str2 = question.split("\n")
    q_str1.gsub!(/[[:punct:]]\z/, '') unless q_str1[-1] == '%'
    q_str2.gsub!(/[[:punct:]]\z/, '') unless q_str2[-1] == '%'

    str_sql1, position_word1 = prepare_str(q_str1)
    str_sql2, position_word2 = prepare_str(q_str2)
    str_sql = str_sql1 + '&' + str_sql2
    str_sql.slice!('&%WORD%') #костыль

    substring1, substring2 = q_str1.split(WORD_STUB)
    substring1 ||= ''
    substring2 ||= ''

    poems = Poem.where("content_text @@ to_tsquery('pg_catalog.russian', '#{str_sql}')").limit(1)

    unless poems.nil? || poems.empty?
      arr_str = poems.first.content.split("\n")
      p arr_str
      p substring1, substring2
      arr_str.each_with_index do |str1, index|
        str1.gsub!(/[[:punct:]]\z/, '')
        if str1.include? substring1 and str1.include? substring2
          str2 = arr_str[index + 1].gsub!(/[[:punct:]]\z/, '')
          return find_word(str1, position_word1) + ',' + find_word(str2, position_word2)
        end
      end
    end
    nil
  end

  private

  def get_index_word(question_str)
    arr_words = question_str.split(" ")
    arr_words.index(WORD_STUB)
  end

  def prepare_str(str)
    result = ''
    arr_words = str.split(" ")
    arr_words.each do |word|
       word.gsub!(/[[:punct:]]\z/, '') unless word[-1] == '%'
    end
    position = arr_words.index("%WORD%")
    a = arr_words.delete("%WORD%")
    if a.nil?
      stop = 1
    end

    arr_words.each do |word|
      result += word.strip.gsub(/[[:punct:]]\z/, '') + '&'
    end
    return result[0..-2], position
  end

  def find_word(row, index)
    p 'find_word'
    p row
    p index
    return 'error in find_word' if row.nil? || index.nil?
    arr_words = row.split(" ")
    arr_words.each do |word|
      word.strip.gsub(/[[:punct:]]\z/, '')
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

end