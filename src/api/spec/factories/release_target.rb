FactoryBot.define do
  factory :release_target do
    repository
    target_repository { create(:repository) }
    trigger { nil }
  end
end
