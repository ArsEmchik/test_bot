class TasksController < ApplicationController

  ANSWER = 'снежные'.freeze
  SERVER_URL = 'http://localhost:3000/quiz'.freeze

  def index
    @token = params[:token]
    render text: ANSWER
  end

  def quiz
    level = params[:task_level]
    question = params[:question]
    token = params[:token]
    task_id = params[:task_id]

    poem = Poem.where('content like ?', "%#{question}%").first

    if poem
      uri = URI(SERVER_URL)
      request = Net::HTTP::Post.new(uri)
      request.post_form(answer: poem.title, token: token, task_id: task_id)
    end

    render nothing: true

  end

end