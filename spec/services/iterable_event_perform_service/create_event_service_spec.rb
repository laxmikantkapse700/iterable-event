#frozen_string_literal: true

require 'rails_helper'

RSpec.describe IterableEventPerformService::CreateEventService do
  describe "#user_event" do
    let(:user) { User.create(email: 'demo@demo.com', password: 'password') }
    let(:name) { "Test Event" }

    context "create event" do
      it "calls actual_user_event" do
        expect(subject).to receive(:actual_user_event).with(user, name)
        subject.user_event(user, name)
      end
    end
  end

  describe "#mock_user_event" do
    let(:user) { User.create(email: 'demo@demo.com', password: 'password') }
    let(:name) { "Test Event" }

    context "when mock response is success" do
      before { allow(subject).to receive(:mock_response).and_return('success') }

      it "creates event and returns event object" do
        expect(IterableEvent).to receive(:create).with(user_id: user.id, title: name).and_return(IterableEvent.new)
        expect(subject.send(:mock_user_event, user, name)).to be_a(IterableEvent)
      end
    end

    context "when mock response is failure" do
      before { allow(subject).to receive(:mock_response).and_return('failure') }

      it "logs error and returns false" do
        expect(Rails.logger).to receive(:error)
        expect(subject.send(:mock_user_event, user, name)).to be_falsey
      end
    end
  end

  describe "#actual_user_event" do
    let(:user) { User.create(email: 'demo@demo.com', password: 'password') }
    let(:name) { "Test Event" }
    context "when actual response is failure" do
      let(:response) { instance_double(Net::HTTPServerError, code: '500') }
      before { allow(subject).to receive(:call_event).and_return(response) }

      it "logs error and returns false" do
        expect(Rails.logger).to receive(:error)
        expect(subject.send(:actual_user_event, user, name)).to be_falsey
      end
    end
  end

  describe "#call_event" do
    let(:user) { User.create(email: 'demo@demo.com', password: 'password') }
    let(:name) { "Test Event" }
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
      # response = double(Net::HTTPSuccess, code: '200')

      expect(URI).to receive(:parse).with('https://api.iterable.com/api/events/track').and_return(uri)
      allow(Net::HTTP).to receive(:new).and_return(http_double)
      allow(http_double).to receive(:use_ssl=)
      allow(Net::HTTP::Post).to receive(:new).and_return(post_double)
      allow(post_double).to receive(:body=)
      allow(http_double).to receive(:request).and_return(response_double)
      

      expect(subject.send(:call_event, body)).to eq(response_double)
    end
  end
end
