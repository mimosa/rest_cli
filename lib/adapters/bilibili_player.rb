# -*- encoding: utf-8 -*-
require 'rest_cli'
require 'digest'
require 'time'                   unless Time.respond_to?(:parse)
require 'adapters/bilibili_site' unless defined?(::BilibiliSite)

class BilibiliPlayer < RestCli
  def initialize
    super('http://interface.bilibili.com')
  end

  # 服务器时间
  def timestamp
    raw = self.get('/serverdate.js', {ts: 1}, {accept: 'text/javascript;level=1'})
    Time.at(raw.to_i)
  end

  def video_url(aid) # 返回视频 url
    aid = aid.match(/\d+/)[0]
    cid = BilibiliSite.new.aid2cid(aid)

    params = { # 自动排序
      otype: 'json',
      quality: 2,
      type: 'mp4',
      appkey: current_key, # 获取当前 KEY
      cid: cid
    }

    # 签名
    params[:sign] = Digest::MD5.hexdigest(params.to_query + 'f7c926f549b9becf1c27644958676a21')
    raw = self.get('/playurl', params) if set_cookie(aid, cid)
    raw[:durl][0][:url] if raw && raw[:result] == 'suee'
  end

  private

  # 分配 Key
  def current_key
    case self.timestamp.hour
    when 0..3
      'f3bb208b3d081dc8'
    when 4..7
      '4fa4601d1caa8b48'
    when 8..11
      '452d3958f048c02a'
    when 12..15
      '86385cdc024c0f6c'
    when 16..19
      '5256c25b71989747'
    when 20..23
      'e97210393ad42219'
    end
  end

  def set_cookie(aid, cid)
    raw = self.get('/player', {id: "cid:#{cid}", aid: aid})
    !raw.nil?
  end
end
