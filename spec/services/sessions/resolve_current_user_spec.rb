require "rails_helper"

RSpec.describe Sessions::ResolveCurrentUser do
  describe ".call" do
    context "with a valid user id in the session" do
      it "returns that user" do
        user = create(:user)
        session = { user_id: user.id }

        expect(described_class.call(session: session)).to eq(user)
      end
    end

    context "with no user id in the session" do
      it "falls back to the first user by id and persists it" do
        first_user  = create(:user)
        _other_user = create(:user)
        session = {}

        result = described_class.call(session: session)

        expect(result).to eq(first_user)
        expect(session[:user_id]).to eq(first_user.id)
      end
    end

    context "with a stale user id (user deleted)" do
      it "falls back to the first user" do
        existing = create(:user)
        session = { user_id: 0 }

        result = described_class.call(session: session)

        expect(result).to eq(existing)
        expect(session[:user_id]).to eq(existing.id)
      end
    end

    context "with no users at all" do
      it "returns nil" do
        expect(described_class.call(session: {})).to be_nil
      end
    end
  end
end
