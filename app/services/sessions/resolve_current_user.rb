module Sessions
  # Returns the user represented by the current session, falling back to the
  # first user when the session is empty (first-request onboarding for the
  # mocked auth). Persists the chosen id into the session so subsequent
  # requests are stable.
  class ResolveCurrentUser < ApplicationService
    def initialize(session:, model: User)
      @session = session
      @model = model
    end

    def call
      user = @model.find_by(id: @session[:user_id]) if @session[:user_id]
      user ||= @model.includes(:company).order(:id).first
      @session[:user_id] = user.id if user
      user
    end
  end
end
