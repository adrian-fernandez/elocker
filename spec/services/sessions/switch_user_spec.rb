require "rails_helper"

RSpec.describe Sessions::SwitchUser do
  describe ".call" do
    it "writes the user id into the session hash" do
      session = {}
      user = create(:user)

      result = described_class.call(user_id: user.id, session: session)

      expect(result).to eq(user)
      expect(session[:user_id]).to eq(user.id)
    end

    it "overwrites a previous session value" do
      session = { user_id: 999 }
      user = create(:user)

      described_class.call(user_id: user.id, session: session)

      expect(session[:user_id]).to eq(user.id)
    end

    it "raises when the user doesn't exist" do
      expect {
        described_class.call(user_id: 0, session: {})
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
