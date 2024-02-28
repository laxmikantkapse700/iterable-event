#frozen_string_literal: true

module IterableEventPerformService
  require 'webmock'
  class MainService
    include WebMock::API
    def mock_response(method, end_point, body_params)
      url = 'https://api.iterable.com'+end_point
      WebMock.enable!
      r = WebMock.stub_request(:post, url).with(body: body_params.to_json, headers: { 'Content-Type' => "application/json" }).and_return_json({body: 'success'})
      response = r.instance_variable_get(:@responses_sequences).map do |responses|
                        responses.instance_variable_get(:@responses).map(&:body)
                      end.flatten.first
      response
    end
  end
end