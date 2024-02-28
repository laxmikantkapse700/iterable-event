#frozen_string_literal: true

require 'rails_helper'

RSpec.describe IterableEventPerformService::NotificationService do
  describe "#notification" do
    context "email notification" do
      let(:user) { User.create(email: 'demo@demo.com', password: 'password') }
      let(:name) { "Test Event" }
      it "calls actual_notification method" do
        expect(subject).to receive(:actual_notification).with(user, name)
        subject.notification(user, name)
      end
    end
  end

  describe "#mock_notification" do
    let(:user) { User.create(email: 'demo@demo.com', password: 'password') }
    let(:name) { "Test Event" }

    context "when notification succeeds" do
      before do
        allow(subject).to receive(:mock_response).and_return('success')
        allow(SendNotificationMailer).to receive(:notification).and_return(double(deliver_now: true))
      end

      it "sends email notification" do
        expect(SendNotificationMailer).to receive(:notification).with(user.email, name)
        expect(subject.send(:mock_notification, user, name)).to be_truthy
      end
    end
  end

  describe "#actual_notification" do
    let(:user) { User.create(email: 'demo@demo.com', password: 'password') }
    let(:name) { "Test Event" }

    context "when notification succeeds" do
      before do
        allow(subject).to receive(:send_notification_request).and_return(double(code: '200'))
        allow(SendNotificationMailer).to receive(:notification).and_return(double(deliver_now: true))
      end

      it "sends email notification" do
        expect(SendNotificationMailer).to receive(:notification).with(user.email, name)
        expect(subject.send(:actual_notification, user, name)).to be_truthy
      end
    end
  end

  describe "#send_notification_request" do
    let(:user) { User.create(email: 'demo@demo.com', password: 'password') }
    let(:name) { "Test Event" }
    let(:body) do
      {
        "campaignId": 0,
        "recipientEmail": user.email,
        "recipientUserId": user.id,
        "sendAt": Time.now,
        "allowRepeatMarketingSends": true
      }
    end

    it "returns a response" do
      http_double = double(Net::HTTP)
      post_double = double(Net::HTTP::Post)
      response_double = double("Response", code: '200')
      allow(Net::HTTP).to receive(:new).and_return(http_double)
      allow(http_double).to receive(:use_ssl=)
      allow(Net::HTTP::Post).to receive(:new).and_return(post_double)
      allow(post_double).to receive(:body=)
      allow(http_double).to receive(:request).and_return(response_double)

      expect(subject.send(:send_notification_request, body)).to have_attributes(code: '200')
    end
  end
end

