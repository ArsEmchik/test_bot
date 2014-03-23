class Token < ActiveRecord::Base
  before_save :delete_token

  def delete_token
    Token.destroy_all
  end

end