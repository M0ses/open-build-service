class GroupMaintainer < ApplicationRecord
  belongs_to :user
  belongs_to :group

  validate :validate_duplicates, on: :create

  private

  def validate_duplicates
    return unless GroupMaintainer.find_by(user: user, group: group)

    errors.add(:user, "#{user.login} is maintainer of this group already")
  end
end

# == Schema Information
#
# Table name: group_maintainers
#
#  id       :integer          not null, primary key
#  group_id :integer          indexed
#  user_id  :integer          indexed
#
# Indexes
#
#  group_id  (group_id)
#  user_id   (user_id)
#
# Foreign Keys
#
#  group_maintainers_ibfk_1  (group_id => groups.id)
#  group_maintainers_ibfk_2  (user_id => users.id)
#
