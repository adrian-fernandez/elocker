require "rails_helper"

RSpec.describe Lockers::Transfer do
  describe ".call" do
    let(:device)       { create(:physical_device) }
    let(:amazon)       { create(:company, name: "Amazon") }
    let(:dpd)          { create(:company, name: "DPD") }

    context "transferring an assigned locker to another company" do
      let!(:original) { create(:locker, physical_device: device, company: amazon, name: "A1") }

      it "closes the current contract and opens a new one" do
        described_class.call(physical_device: device, company: dpd, name: "D7")

        original.reload
        new_locker = device.lockers.find_by(ended_at: nil)

        expect(original.ended_at).to be_present
        expect(new_locker).not_to eq(original)
        expect(new_locker.company).to eq(dpd)
        expect(new_locker.name).to eq("D7")
        expect(new_locker.status).to eq("closed")
      end

      it "wipes team permissions of the outgoing contract" do
        team = create(:team, company: amazon)
        create(:locker_team_permission, locker: original, team: team, company_id: amazon.id)

        expect {
          described_class.call(physical_device: device, company: dpd, name: "D7")
        }.to change { original.reload.locker_team_permissions.count }.from(1).to(0)
      end

      it "preserves historical actions on the outgoing contract" do
        action = create(:locker_action, locker: original, company_id: amazon.id)

        described_class.call(physical_device: device, company: dpd, name: "D7")

        expect(action.reload).to be_present
        expect(action.company_id).to eq(amazon.id)
        expect(action.locker_id).to eq(original.id)
      end
    end

    context "unassigning (transferring to nil)" do
      let!(:original) { create(:locker, physical_device: device, company: amazon, name: "A1") }

      it "creates a new unassigned contract" do
        described_class.call(physical_device: device, company: nil, name: "A1-returned")

        new_locker = device.lockers.find_by(ended_at: nil)
        expect(new_locker).to be_unassigned
        expect(new_locker.name).to eq("A1-returned")
      end
    end

    context "no-op transfer" do
      let!(:original) { create(:locker, physical_device: device, company: amazon, name: "A1") }

      it "raises InvalidTransferError when owner + name are unchanged" do
        expect {
          described_class.call(physical_device: device, company: amazon, name: "A1")
        }.to raise_error(described_class::InvalidTransferError, /already owned/)
      end
    end

    context "validation" do
      it "requires a name" do
        expect {
          described_class.call(physical_device: device, company: amazon, name: "")
        }.to raise_error(described_class::InvalidTransferError, /Name/)
      end
    end
  end
end
