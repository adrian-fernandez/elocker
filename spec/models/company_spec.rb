require "rails_helper"

RSpec.describe Company, type: :model do
  describe "associations" do
    it { is_expected.to have_many(:users) }
    it { is_expected.to have_many(:teams) }
    it { is_expected.to have_many(:lockers) }
  end

  describe "platform_owner uniqueness" do
    it "allows one platform_owner company" do
      expect { create(:company, :platform) }.not_to raise_error
    end

    it "forbids a second platform_owner at the DB level" do
      create(:company, :platform)
      duplicate = build(:company, name: "Other eLocker", platform_owner: true)

      expect { duplicate.save(validate: false) }
        .to raise_error(ActiveRecord::RecordNotUnique)
    end

    it "allows many tenants" do
      create_list(:company, 3)
      expect(described_class.count).to eq(3)
    end
  end
end
