# -*- encoding: utf-8 -*-
require 'benchmark'
require 'rest_cli'
require 'parallel'
require 'typhoeus'
require 'nokogiri'

hydra  = Typhoeus::Hydra.new(max_concurrency: 3)
client = RestCli.new('http://www.ipeen.com.tw')
responses = []
Benchmark.bm do |bm|
  [10].each do |pages|

    puts "[ #{pages} requests ]"

    bm.report('RestCLI + Parallel       ') do
      responses += Parallel.map(1..pages, in_threads: 3) do |page|
        client.get('/rank/member.php', p: page)
      end
    end

    bm.report('Typhoeus Hydra           ') do
      requests = (1..pages).map do |page|
        request = Typhoeus::Request::new('http://www.ipeen.com.tw/rank/member.php?p=' + page.to_s, followlocation: true)
        hydra.queue(request)
        request
      end
      hydra.run
      responses += requests.map do |request|
        next unless request.response.code.between?(200, 201)
        Nokogiri::HTML.parse(request.response.body)
      end
    end
  end
end

responses.each do |resp|
  puts resp.class.name
end
