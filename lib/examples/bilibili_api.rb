# -*- encoding: utf-8 -*-
require 'rest_cli'

class BilibiliApi < RestCli

  def initialize(date = Date.today-1)
    @date_range = date.to_time..Time.parse("#{date} 23:59:59")
    super('http://api.bilibili.cn')
    puts "目前支持的分类：#{self.names.join('、')}。"
  end

  def episodes_by_name(name)
    episodes_by_id(taxonomies[name]) if self.names.include?(name)
  end

  def comments_by_id(oid, page = 1, result = []) # 返回评论
    raw = self.get('/x/v2/reply', { type: 1, oid: oid.match(/\d+/)[0], pn: page })
    
    if raw && raw[:code] == 0
      raw = raw[:data]
      raw[:replies].map do |reply|
        date = Time.at(reply[:ctime])
        result << {
          author: {
            nickname:   reply[:member][:uname],
            avatar_url: reply[:member][:avatar],
          }, 
          content: reply[:content][:message],
          created_at: date,
          updated_at: date
        }
      end
      # 分页
      if page < num_pages(raw[:page][:count], raw[:page][:size])
        self.comments_by_id(oid, page+1, result)
      else
        result
      end
    else
      puts '_' * 88 + raw[:message]
    end
  end

  def names
    taxonomies.keys
  end

  private

    def taxonomies
      {
        '广告' => 166,
        '搞笑' => 138,
        '日常' => 21,
        '美食圈' => 76,
        '动物圈' => 75,
        '手工' => 161,
        '绘画' => 162,
        '运动' => 163,
        '纪录片' => 37,
        '趣味科普人文' => 124,
        '野生技术协会' => 122,
        '演讲•公开课' => 39,
        '星海' => 96,
        '数码' => 95,
        '机械' => 98,
        '单机联机' => 17,
        '网游·电竞' => 65,
        '音游' => 136,
        'Mugen' => 19,
        'GMV' => 121,
        '美妆' => 157, 
        '服饰' => 158, 
        '健身' => 164, 
        '资讯' => 159, 
        '电影相关' => 82, 
        '短片' => 85, 
        '欧美电影' => 145, 
        '日本电影' => 146, 
        '国产电影' => 147, 
        '其他国家' => 83, 
      }
    end

    # 仅支持二级分类，如：科技 -> 数码(95)
    def episodes_by_id(tid, page = 1, result = []) # 返回当日某分类发布的视频
      params = {
        type: :json,
        tid: tid,
        pn: page
      }

      raw = self.get('/archive_rank/getarchiverankbypartion', params)
      if raw && raw[:code] == 0
        raw = raw[:data]
        raw[:archives].map do |archive|
          created_at = Time.parse(archive[:create]) rescue @date_range.last

          return result if created_at < @date_range.first # 倒叙结果，小于0点即跳出

          unless created_at > @date_range.last # 只取当天记录
            result << { 
              episode_id: "av#{archive[:aid]}",
                   title: archive[:title],
                oneliner: archive[:description],
               cover_url: archive[:pic],
                tag_list: archive[:tags],
              created_at: created_at,
              updated_at: created_at
            }
          end
        end
        # 分页
        if page < num_pages(raw[:page][:count], raw[:page][:size])
          episodes_by_id(tid, page+1, result)
        else
          result
        end
      else
        puts '_' * 88 + raw[:message]
      end
    end
end