# -*- encoding: utf-8 -*-
require 'rest_cli'

class Ipeen < RestCli
  
  def initialize
    super('http://www.ipeen.com.tw')
  end

  def users(page=1)
    dom = self.get('/rank/member.php', { p: page }, { user_agent: user_agent })
    rows = dom.at_css('div.member_list table')

    if page == 1 # 取总页数
      pagination = dom.at_css('div.allschool_pagearea div.next_page_area label.next_p_s a')
      @pages = pagination.attribute('href').value.sub('/rank/member.php?p=', '').to_i 
    end
    
    result = find_user(rows)
    # 分页
    if page >= @pages
      result
    else
      result.merge! self.users(page+1)
    end
  end

  private

    def find_user(rows)
      result = {}
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
      'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/54.0.2840.71 Safari/537.36'
    end
end