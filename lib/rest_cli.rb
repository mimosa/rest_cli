# -*- encoding: utf-8 -*-
require 'faraday'
require 'typhoeus/adapters/faraday'
require 'faraday/awesome'
require 'utils/hash' unless Hash.respond_to?(:to_query)

class RestCli
  def initialize(endpoint)
    connection.url_prefix = endpoint
  end

  def get(path, params = nil, headers = nil)
    self.request(:get, path, params, headers)
  end

  def post(path, params = nil, headers = nil)
    self.request(:post, path, params, headers)
  end

  def request(method, url, body, headers = nil)
    resp = connection.send(method, url, body, headers)
    resp.body if resp.status.between?(200, 201)
  rescue Faraday::TimeoutError, Faraday::ConnectionFailed => e
    puts e.message
    puts e.backtrace.inspect
    puts '_' * 88
  end

  def connection
    @connection ||= Faraday.new(ssl: {verify: false}) do |conn|
      #
      conn.request  :multipart
      conn.request  :url_encoded
      conn.request  :retry, max: 2,
                            interval: 0.05,
                            interval_randomness: 0.5,
                            backoff_factor: 2,
                            exceptions: [
                              Faraday::TimeoutError, Timeout::Error
                            ]
      #
      conn.use      :awesome
      # conn.response :logger
      conn.adapter  :typhoeus
      # timeout
      # conn.options.open_timeout = 10
      # conn.options.timeout = 10
    end
  end

  private

  def num_pages(total, size)
    (total.to_f / size).ceil
  end
end
