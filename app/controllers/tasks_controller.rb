# Encoding: utf-8
class TasksController < ApplicationController

  ANSWER = 'снежные'.freeze
  #SERVER_URL = 'http://pushkin-contest.ror.by/quiz'.freeze
  SERVER_URL = 'http://localhost:3000/quiz'.freeze


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

    answer = case (params[:task_level])
               when 1 then
                 level1
               when 2 then
                 level2
               when 3 then
                 3
               when  4 then
                 4
               when 5
                 5
               else
                 nil
             end


    poem = Poem.where('content like ?', "%#{question}%").first

    if answer
      uri = URI(SERVER_URL)
      parameters = {answer: answer, token: token, task_id: task_id}
      Net::HTTP.post_form(uri, parameters)
    end

    render nothing: true
  end


  private

  def level1
    Poem.where('content like ?', "%#{question}%").first.title
  end

  def level2

  end

  def result
    result = params[:result]
    render nothing: true
  end

end