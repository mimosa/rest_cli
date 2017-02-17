# -*- encoding: utf-8 -*-
require 'rest_cli'
require 'parallel'

class Facexx < RestCli
  def initialize(key = 'DEMO_KEY', secret = 'DEMO_SECRET')
    @params = {
      api_key: key,
      api_secret: secret
    }

    super('https://apicn.faceplusplus.com/v2')
  end

  def get(url)
    data = detect(url)
    return {is_face: false} if data.nil? || data[:face].empty?
    data.merge!(data.delete(:face)[0]) # 只获取最大的一张脸
    # flatten
    data.merge!(data.delete(:attribute))
    data.merge!(data.delete(:position))
    if data.key?(:face_id)
      parallel_methods = [:landmark_merge, :similar_merge]
      Parallel.each(parallel_methods, in_threads: parallel_methods.size) do |method|
        data.merge! send(method, data)
      end
    end
    data
  end

  def landmark_merge(data)
    extra = landmark(data[:face_id])
    if extra.nil? || extra[:result].empty?
      {is_landmark: false}
    else
      extra.merge!(extra.delete(:result)[0]) # 只获取最大的一张脸
      extra.merge!(extra.delete(:landmark)) # flatten
    end
  end

  def similar_merge(data) # 像谁，明星脸
    similar = search(data[:face_id])
    return {} if similar.nil? || similar[:candidate].empty?
    {similar_stars: similar[:candidate].map {|f| f[:tag].split('|').last}.uniq}
  end

  # private

  def detect(url)
    params = {
      url: url,
      mode: 'oneface',
      attribute: 'gender,age,race,smiling,glass,pose'
    }

    self.post('detection/detect', @params.merge(params))
  end

  def landmark(face_id)
    self.post('detection/landmark', @params.merge(face_id: face_id))
  end

  def search(face_id, limit = 8)
    params = {
      key_face_id: face_id,
      faceset_name: 'starlib3',
      count: limit
    }

    self.post('recognition/search', @params.merge(params))
  end
end
