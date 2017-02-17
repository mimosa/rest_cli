# -*- encoding: utf-8 -*-
require 'rest_cli'
require 'parallel'

class Ipeen < RestCli
  def initialize
    super('http://www.ipeen.com.tw')
  end

  def users(page = 1)
    dom = get(page)
    return {} if dom.nil?
    # 第一页结果
    result = parse_user(dom)
    # 分页
    page += 1
    @pages ||= parse_pagination(dom)
    return result if page > @pages
    # 并行分页
    Parallel.each(page..@pages, in_threads: 8) do |_page|
      dom = get(_page)
      unless dom.nil?
        result.merge! parse_user(dom)
      end
    end
    result
  end

  private

  def get(page)
    super('/rank/member.php', {p: page}, {user_agent: user_agent})
  end

  def parse_pagination(dom)
    pagination = dom.at_css('div.allschool_pagearea div.next_page_area label.next_p_s a')
    pagination.attribute('href').value.sub('/rank/member.php?p=', '').to_i
  end

  def parse_user(dom)
    result = {}
    rows   = dom.at_css('div.member_list table')

    rows.css('tr:not(:first-child)').each do |row|
      img = row.css('img')
      avatar_url = img.attribute('src').value
      unless avatar_url.include?('/unknown_') # 没有头像
        username = row.css('a').attribute('href').value.sub('/home/', '')
        result[username] = {
          avatar_url: avatar_url.sub('_72.', '_200.'),
          nickname: img.attribute('alt').value
        }
      end
    end
    result
  end

  def user_agent
    'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_1) '\
    'AppleWebKit/537.36 (KHTML, like Gecko) '\
    'Chrome/54.0.2840.71 Safari/537.36'
  end
end
