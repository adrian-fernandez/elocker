class AddForcedToLockerActions < ActiveRecord::Migration[8.1]
  # Marks a request action as having been issued via Force Open / Force
  # Close (bypassing state validation). Only request actions carry it;
  # device responses (opened/closed) are always `false`.
  def change
    add_column :locker_actions, :forced, :boolean, null: false, default: false
  end
end
