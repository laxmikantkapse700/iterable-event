#frozen_string_literal: true

class IterableEvent < ApplicationRecord 
  has_many :user_iterable_events
  has_many :users, through: :user_iterable_events
  validates :title, presence: true
  def create_event(type, title, user)
    if type == 'A'
      event = IterableEventPerformService::CreateEventService.new.user_event(user, title)
      return event.present?, event
    elsif type == 'B'
      event = IterableEventPerformService::CreateEventService.new.user_event(user, title)
      if event
        notification = IterableEventPerformService::NotificationService.new.notification(user, event.title)
        return [event.present?, notification.present?], [event, notification]
      else
        return [false, false], [nil, nil]
      end
    end
  end


  def update_event(my_event, user_ids)
    user_ids = user_ids.reject(&:blank?).map(&:to_i)
    event = IterableEventPerformService::UpdateEventService.new.event(user_ids, my_event)
    if event
      return event
    else
      return false
    end
  end
end