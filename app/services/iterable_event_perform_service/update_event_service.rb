#frozen_string_literal: true

require 'uri'
require 'net/http'
require 'json'

module IterableEventPerformService
  class UpdateEventService < IterableEventPerformService::MainService
    def event(users, event)
      if Rails.env.test?
        event_for_users(users, event)
      else
        mock_event_for_users(users, event)
      end
    end

    private

    def event_for_users(users, event)
      user_ids = users
      begin
        ActiveRecord::Base.transaction do
          user_ids.each do |user_id|
            user = find_user(user_id)
            next unless user
            unless event.users.include?(user)
              response = track_event_for_user(user, event.title, event.id)
              if response == '200'
                event.users << user
              else
                raise StandardError, "Not able add user: #{response.message}"
              end
            end
          end
        end
        event
      rescue StandardError => e
        Rails.logger.error("Error while adding users to event")
        false
      end
    end

    def mock_event_for_users(users, event)
      user_ids = users
      begin
        ActiveRecord::Base.transaction do
          user_ids.each do |user_id|
            user = find_user(user_id)
            next unless user
            unless event.users.include?(user)
              response = event_for_user(user, event.title, event.id)
              if response == 'success'
                event.users << user
              else
                raise StandardError, "Not able add user: #{response.message}"
              end
            end
          end
        end
        event
      rescue StandardError => e
        Rails.logger.error("Error while adding users to event")
        false
      end
    end

    def find_user(user_id)
      User.find_by(id: user_id)
    end

    def track_event_for_user(user, title, event_id)
      uri = URI('https://api.iterable.com/api/events/track')
      headers = {
        'Content-Type' => 'application/json',
        'Api-Key' => ENV['ITERABLE_API_KEY']
      }
      body = {
        email: user.email,
        userId: user.id,
        id: event_id,
        eventName: title
      }

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      request = Net::HTTP::Post.new(uri, headers)
      request.body = body.to_json
      http.request(request)
    end

    def event_for_user(user, title, event_id)
      body_response = {
        "email": user.email,
        "userId": user.id,
        "id": event_id,
        "eventName": title
      }
      respond = mock_response(:post, '/api/events/track', body_response)
      respond
    end
  end
end


  