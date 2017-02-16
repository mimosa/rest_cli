# -*- encoding: utf-8 -*-
require 'rest_cli'

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
    if data.nil? || data[:face].empty?
      data = { is_face: false }
    else
      data.merge!(data.delete(:face)[0]) # 只获取最大的一张脸
      # 数据扁平化处理
      data.merge!(data.delete(:attribute))
      data.merge!(data.delete(:position))

      extra = landmark(data[:face_id])
      if extra.nil? || extra[:result].empty?
        data[:is_landmark] = false
      else
        extra.merge!(extra.delete(:result)[0]) # 只获取最大的一张脸
        # 数据扁平化处理
        extra.merge!(extra.delete(:landmark))

        data.merge!(extra)

        # 像谁，明星脸
        similar = search(data[:face_id])
        unless similar.nil? || similar[:candidate].empty?
          data[:similar_stars] = similar[:candidate].map{ |f| f[:tag].split('|').last }.uniq
        end
      end
    end
    data
  end

  # private

    def detect(url)
      self.post('detection/detect', @params.merge(
        url: url, 
        mode: 'oneface', 
        attribute: 'gender,age,race,smiling,glass,pose'
      ))
    end

    def landmark(face_id)
      self.post('detection/landmark', @params.merge(face_id: face_id) )
    end

    def search(face_id, limit = 8)
      self.post('recognition/search', @params.merge(
        key_face_id: face_id,
        faceset_name: 'starlib3',
        count: limit
      ))
    end
end