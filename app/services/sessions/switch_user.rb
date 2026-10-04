module Sessions
  # Mocked "login as" — the session store is passed in rather than reached
  # for globally, so tests can use a plain Hash in place of Rails' session.
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
