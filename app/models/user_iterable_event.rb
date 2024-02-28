class UserIterableEvent < ApplicationRecord
  belongs_to :user
  belongs_to :iterable_event
end