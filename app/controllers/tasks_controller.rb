# Encoding: utf-8
class TasksController < ApplicationController

  ANSWER = 'снежные'.freeze
  SERVER_URL = 'http://pushkin-contest.ror.by/quiz'.freeze

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
    token = Token.last
    #level = params[:task_level]
    question = params[:question]
    task_id = params[:task_id]

    poem = Poem.where('content like ?', "%#{question}%").first

    if poem
      uri = URI(SERVER_URL)
      parameters = {answer: poem.title, token: token, task_id: task_id}
      Net::HTTP.post_form(uri, parameters)
    end

    render nothing: true
  end

  def result
    result = params[:result]
    render nothing: true
  end

end