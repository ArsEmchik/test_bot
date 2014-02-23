class TasksController < ApplicationController

  ANSWER = 'снежные'.freeze

  def index
    @token = params[:token]
    render text: ANSWER, :encoding => 'utf-8'
  end

  def quiz
    @level = params[:level]
    @question = params[:question]
  end


end