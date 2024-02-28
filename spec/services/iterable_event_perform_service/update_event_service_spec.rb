#frozen_string_literal: true

require 'rails_helper'

RSpec.describe IterableEventPerformService::UpdateEventService do
  let(:users) { [1, 2, 3] }
  let(:event) { IterableEvent.create(title: "my event", user_id: 4) }
  let(:user) { instance_double("User", email: "test@example.com", id: 1) }
  let(:response_double) { double("Response", code: "200", message: "Success") }

  subject { described_class.new }

  describe "#mock_event_for_users" do
    before do
      allow(subject).to receive(:find_user).and_return(user)
      allow(subject).to receive(:event_for_user).and_return("success")
    end

    it "adds users to the event" do
      expect(event.users).to receive(:<<).with(user).exactly(users.count).times
      subject.send(:mock_event_for_users, users, event)
    end

    context "when API call returns success" do
      it "adds user to the event" do
        expect(event.users).to receive(:<<).with(user).exactly(users.count).times
        subject.send(:mock_event_for_users, users, event)
      end
    end
  end

  describe "#track_event_for_user" do
    let(:user) { User.create(email: 'demo345@demo.com', password: 'password1') }
    let(:event) { IterableEvent.create(title: "my event", user_id: user.id)}
    let(:name) { "update event" }
    let(:body) { { email: user.email, userId: user.id, id: 0, eventName: name } }

    it "makes a request to the third-party API and returns a response" do
      uri = URI('https://api.iterable.com/api/events/track')
      headers = {
        'Content-Type' => 'application/json',
        'Api-Key' => 'PLACEHOLDER_API_KEY'
      }

      http_double = double(Net::HTTP)
      post_double = double(Net::HTTP::Post)
      response_double = double("Response", code: '200')
      expect(URI).to receive(:parse).with('https://api.iterable.com/api/events/track').and_return(uri)
      allow(Net::HTTP).to receive(:new).and_return(http_double)
      allow(http_double).to receive(:use_ssl=)
      allow(Net::HTTP::Post).to receive(:new).and_return(post_double)
      allow(post_double).to receive(:body=)
      allow(http_double).to receive(:request).and_return(response_double)
      expect(subject.send(:track_event_for_user, user, name, event.id)).to eq(response_double)
    end
  end
end
