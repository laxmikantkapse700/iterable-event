#frozen_string_literal: true

require 'uri'
require 'net/http'
require 'json'

module IterableEventPerformService
  class NotificationService < IterableEventPerformService::MainService
    def notification(user, name)
      if Rails.env.test?
        actual_notification(user, name)
      else
        mock_notification(user, name)
      end
    end

    private

    def mock_notification(user, name)
      begin     
        body = {
          "campaignId": 0,
          "recipientEmail": user.email,
          "recipientUserId": user.id,
          "sendAt": Time.now,
          "allowRepeatMarketingSends": true
        }
        response = mock_response(:post, '/api/email/target', body)
        
        if response == 'success'
          SendNotificationMailer.notification(user.email, name).deliver_now
          return true
        else
          raise StandardError, "not able to send email notification"
        end
      rescue StandardError => e
        Rails.logger.error("Error sending email notification: #{e.message}")
        return false
      end
    end

    def actual_notification(user, name)
      begin     
        body = {
          "campaignId": 0,
          "recipientEmail": user.email,
          "recipientUserId": user.id,
          "sendAt": Time.now,
          "allowRepeatMarketingSends": true
        }
        response = send_notification_request(body)
        
        if response.code == '200'
          SendNotificationMailer.notification(user.email, name).deliver_now
          return true
        else
          raise StandardError, "Not able to send email notification: #{response.message}"
        end
      rescue StandardError => e
        Rails.logger.error("Error sending email notification: #{e.message}")
        return false
      end
    end

    private

    def send_notification_request(body)
      uri = URI('https://api.iterable.com/api/email/target')
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