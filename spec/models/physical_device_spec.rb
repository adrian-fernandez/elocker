require "rails_helper"

RSpec.describe PhysicalDevice, type: :model do
  describe "associations" do
    it { is_expected.to have_many(:lockers).dependent(:restrict_with_exception) }
    it { is_expected.to have_many(:lockers_newest_first).class_name("Locker") }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:device_id) }

    it "requires device_id to be unique" do
      create(:physical_device, device_id: "DUP-001")

      expect(build(:physical_device, device_id: "DUP-001")).not_to be_valid
    end
  end

  describe "#current_locker" do
    it "returns the active locker when the association is not preloaded" do
      device  = create(:physical_device)
      create(:locker, :archived, physical_device: device, name: "old")
      current = create(:locker, physical_device: device, name: "new")

      # Fetch a fresh row so the lockers association is NOT loaded.
      reloaded = described_class.find(device.id)
      expect(reloaded.association(:lockers).loaded?).to be(false)
      expect(reloaded.current_locker).to eq(current)
    end

    it "uses the in-memory lockers collection when preloaded, avoiding an extra query" do
      device  = create(:physical_device)
      current = create(:locker, physical_device: device)

      preloaded = described_class.includes(:lockers).find(device.id)
      expect(preloaded.association(:lockers).loaded?).to be(true)

      queries = []
      callback = ->(_name, _start, _finish, _id, payload) {
        queries << payload[:sql] unless payload[:name] == "SCHEMA" || payload[:sql] =~ /^(BEGIN|COMMIT|SAVEPOINT|RELEASE)/
      }

      ActiveSupport::Notifications.subscribed(callback, "sql.active_record") do
        expect(preloaded.current_locker).to eq(current)
      end

      expect(queries).to be_empty
    end
  end

  describe "#historical_lockers" do
    it "returns only lockers with an ended_at" do
      device   = create(:physical_device)
      archived = create(:locker, :archived, physical_device: device)
      create(:locker, physical_device: device)

      expect(device.historical_lockers).to contain_exactly(archived)
    end
  end
end
