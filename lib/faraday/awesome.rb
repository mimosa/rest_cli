# -*- encoding: utf-8 -*-
require 'faraday' unless defined?(::Faraday)

module Faraday
  class Awesome < Faraday::Middleware
    dependency 'zlib'
    dependency 'nokogiri'
    dependency 'multi_json'
    dependency 'http/cookie_jar'
    dependency 'addressable/uri'

    def initialize(app, opts = {})
      super(app)
      @jar = opts[:jar] || HTTP::CookieJar.new
    end

    def call(env)
      uri = uri_parse(env)
      domain = ip?(uri) ? uri.host : uri.domain

      restore_cookies(env, domain)
      reset_user_agent(env)

      env[:request_headers]['Referer'] ||= 'http://www.' + domain
      @app.call(env).on_complete do |response_env|
        # Follow redirects
        if response_env.response_headers.key?('Location')
          response_env[:url] = response_env.response_headers['Location']
          call(response_env)
        else
          set_cookies(response_env, domain) # Cookie
          awesome_decode(response_env) # 解压
          awesome_parse(response_env)  # 解析
        end
      end
    end

    private

    # 解析
    def awesome_parse(response_env)
      case response_env.request_headers['Accept'] || response_env.response_headers['Content-Type']
      when /^text\/html/
        reset_body(response_env, &method(:parse_html))
      when /^application\/(vnd\..+\+)?json/
        reset_body(response_env, &method(:parse_json))
      end if response_env.status.between?(200, 201)
    end

    # 解压
    def awesome_decode(response_env)
      case response_env.response_headers['Content-Encoding']
      when /gzip/i
        decode_body(response_env, &method(:uncompress))
      when /deflate/i
        decode_body(response_env, &method(:inflate))
      end
    end

    def ip?(uri)
      uri.host.match?(/\d+{1,3}\.\d+{1,3}\.\d+{1,3}\.\d+{1,3}/)
    end

    def reset_user_agent(env)
      if env[:request_headers]['User-Agent'].match?(/Faraday/)
        env[:request_headers]['User-Agent'] = 'Mozilla/5.0 (Windows NT 6.1; WOW64) '\
                                              'AppleWebKit/537.36 (KHTML, like Gecko) '\
                                              'Chrome/34.0.1847.116 Safari/537.36'
      end
    end

    def set_cookies(response_env, domain)
      if response_env.response_headers.key?('Set-Cookie')
        @jar.parse(response_env.response_headers['Set-Cookie'], domain)
      end
    end

    def restore_cookies(env, domain)
      cookies = @jar.cookies(domain)
      unless cookies.empty?
        cookie_value = HTTP::Cookie.cookie_value(cookies)

        if env[:request_headers].key?('Cookie') && env[:request_headers]['Cookie'] != cookie_value
          env[:request_headers]['Cookie'] = cookie_value + ';' + env[:request_headers]['Cookie']
        else
          env[:request_headers]['Cookie'] = cookie_value
        end
      end
    end

    def uri_parse(env)
      Addressable::URI.parse(env[:url])
    end

    def reset_body(response_env)
      response_env.body = yield(response_env.body)
    end

    def decode_body(response_env)
      response_env.body = yield(response_env.body)
      response_env.response_headers.delete('Content-Encoding')
      response_env.response_headers['Content-Length'] = response_env.body.length
    end

    # 解压
    def uncompress(raw)
      Zlib::GzipReader.new(StringIO.new(raw), encoding: 'ASCII-8BIT').read
    end

    # 还原
    def inflate(raw)
      Zlib::Inflate.inflate(raw)
    end

    # 构建HTML
    def parse_html(raw)
      Nokogiri::HTML.parse(raw)
    end

    # 解析 Json
    def parse_json(raw)
      MultiJson.load(raw, use_bigdecimal: false, symbolize_keys: true)
    end
  end
end

if Faraday::Middleware.respond_to? :register_middleware
  Faraday::Middleware.register_middleware awesome: -> {Faraday::Awesome}
end
