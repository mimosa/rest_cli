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
      
      @app.call(env).on_complete do |env|
        # 
        set_cookies(env, domain)
        
        # 解压
        case env.response_headers['Content-Encoding']
        when /gzip/i
          decode_body(env, &method(:uncompress))
        when /deflate/i
          decode_body(env, &method(:inflate))
        end

        # 解析
        case env.request_headers['Accept'] || env.response_headers['Content-Type']
        when /^text\/html/
          reset_body(env, &method(:parse_html))
        when /^application\/(vnd\..+\+)?json/
          reset_body(env, &method(:parse_json))
        end if env.status.between?(200, 201)
      end
    end

    private

      def ip?(uri)
        uri.host =~ /\d+{1,3}\.\d+{1,3}\.\d+{1,3}\.\d+{1,3}/
      end

      def reset_user_agent(env)
        if env[:request_headers]['User-Agent'] =~ /Faraday/
          env[:request_headers]['User-Agent'] = 'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/34.0.1847.116 Safari/537.36'
        end
      end

      def set_cookies(env, domain)
        if env.response_headers.has_key?('Set-Cookie')
          @jar.parse(env.response_headers['Set-Cookie'], domain)
        end
      end

      def restore_cookies(env, domain)
        cookies = @jar.cookies(domain)
        unless cookies.empty?
          cookie_value = HTTP::Cookie.cookie_value(cookies)

          env[:request_headers]['Cookie'] = if env[:request_headers].has_key?('Cookie') && env[:request_headers]['Cookie'] != cookie_value
            cookie_value + ';' + env[:request_headers]['Cookie']
          else
            cookie_value
          end
        end
      end

      def uri_parse(env)
        Addressable::URI.parse(env[:url])
      end

      def reset_body(env)
        env.body = yield(env.body)
      end

      def decode_body(env)
        env.body = yield(env.body)
        env.response_headers.delete('Content-Encoding')
        env.response_headers['Content-Length'] = env.body.length
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
  Faraday::Middleware.register_middleware awesome: -> { Faraday::Awesome }
end