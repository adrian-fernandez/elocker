module Sessions
  # Mocked "login as" — finds the target user and stores its id in the session.
  #
  # The session store is passed in rather than reached for globally, which lets
  # tests use a plain Hash in place of Rails' session hash.
  class SwitchUser < ApplicationService
    def initialize(user_id:, session:, model: User)
      @user_id = user_id
      @session = session
      @model = model
    end

    def call
      user = @model.find(@user_id)
      @session[:user_id] = user.id
      user
    end
  end
end
