# Encoding: utf-8
class TasksController < ApplicationController

  WORD_STUB = "%WORD%".freeze
  ANSWER = 'снежные'.freeze
  SERVER_URL = 'http://pushkin-contest.ror.by/quiz'.freeze
  #SERVER_URL = 'http://localhost:3000/quiz'.freeze


  def index
    token = Token.new
    token.token = params[:token]

    if token.save
      data = {answer: ANSWER}
      render text: data.to_json
    else
      render nothing: true
    end
  end

  def quiz
    token = Token.last.token
    question = params[:question]
    task_id = params[:id]

    answer = case (params[:level])
               when 1 then
                 level1(question)
               when 2 then
                 level2(question)
               when 3 then
                 level3(question)
               when 4 then
                 level4(question)
               when 5
                 level5(question)
               else
                 nil
             end

    answer ||= 'nothing'
    result = answer.mb_chars.downcase.to_s

    uri = URI(SERVER_URL)
    parameters = {answer: result, token: token, task_id: task_id}
    Net::HTTP.post_form(uri, parameters)

    render nothing: true
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
      next if word.length <= 3
      row = ''
      index = 0
      prev_index = -1
      while index <= 33647
        break if prev_index == index

        row, id = get_row_by_word(word, index)
        break if row.nil?

        return find_answer(row, words) if right_row?(row, words)

        prev_index = index
        index = id
        p index
        p id
        p prev_index
      end
    end
    nil
  end

  private

  #for level 5
  def right_row?(row, words)
    words_in_row = get_words(row)
    words_count = words.count
    return false unless row.split(" ").count == words_count

    count = 0
    words.each do |word|
      count += 1 unless words_in_row.index(word).nil?
    end
    count >= words_count - 1 ? true : false
  end

  # for level 5
  def get_words(str)
    words = str.split(" ")
    words.each { |word| word.gsub!(/[[:punct:]]\z/, '') }
    words.sort_by { |elem| elem.size }.reverse
  end

  #for level 5
  def find_answer(row, words)
    words_in_row = get_words(row)
    word_found = ''
    words.each do |word|
      if words_in_row.index(word).nil?
        word_found = word
      else
        words_in_row.delete(word)
      end
    end
    return words_in_row.first + ',' + word_found
  end

  #for level 5
  def get_row_by_word(word, id)
    rows = Row.where('content like :word_find and id > :id', word_find: "%#{word}%", id: id).limit(1)
    unless rows.nil? || rows.empty?
      return rows.first.content, rows.first.id
    end
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
end