#frozen_string_literal: true

require 'uri'
require 'net/http'
require 'json'

module IterableEventPerformService
  class CreateEventService < IterableEventPerformService::MainService
    def user_event(user, name)
      Rails.env.test? ? actual_user_event(user, name) : mock_user_event(user, name)
    end

    private

    def mock_user_event(user, name)
      begin
        body_response = {
          email: user.email,
          userId: user.id,
          id: 0,
          eventName: name
        }
        response = mock_response(:post, '/api/events/track', body_response)
        if response == 'success'
          event = IterableEvent.create(user_id: user.id, title: name)
          return event
        else
          raise StandardError, "Failed to create event"
        end
      rescue StandardError => e
        Rails.logger.error("Error creating event: #{e.message}")
        false
      end
    end

    def actual_user_event(user, name)
      begin
        body_response = {
          email: user.email,
          userId: user.id,
          id: 0,
          eventName: name
        }
        response = call_event(body)
        if response.code == '200'
          event = IterableEvent.create(user_id: user.id, title: name)
          return event
        else
          raise StandardError, "Failed to create event"
        end
      rescue StandardError => e
        Rails.logger.error("Error creating event: #{e.message}")
        false
      end
    end

    def call_event(body)
      uri = URI('https://api.iterable.com/api/events/track')
      headers = {
        'Content-Type' => 'application/json',
        'Api-Key' => ENV['ITERABLE_API_KEY']
      }
      
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      request = Net::HTTP::Post.new(uri, headers)
      request.body = body.to_json

      http.request(request)
    end
  end
end