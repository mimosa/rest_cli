# -*- encoding: utf-8 -*-
require 'rest_cli'

class BilibiliSite < RestCli

  def initialize
    super('http://www.bilibili.com')
  end

  def aid2cid(aid) # 返回 CID
    raw = self.get('/widget/getPageList', { aid: aid }, { accept: 'application/json;level=1' })
    raw.shift.delete(:cid) unless raw.nil?
  end
end