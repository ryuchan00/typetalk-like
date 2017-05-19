# encoding: utf-8

namespace :post do
  desc "投稿データを取得する。"

# $ rake inactive_user:destroy_unconfirmed のように使う
# :environmentは超大事。ないとモデルにアクセスできない

  task :update => :environment do
    topics = Topic.all
    # setup a http client
    http = Net::HTTP.new('typetalk.in', 443)
    http.use_ssl = true
    # get an access token
    client_id = ENV['CLIENT_ID']
    client_secret = ENV['CLIENT_SECRET']

    # get an access token
    res = http.post(
        '/oauth2/access_token',
        "client_id=#{client_id}&client_secret=#{client_secret}&grant_type=client_credentials&scope=topic.read"
    )
    if res.code != '200'
      next
    end
    json = JSON.parse(res.body)
    access_token = json['access_token']

    topics.each do |topic|
      req = Net::HTTP::Get.new("/api/v1/topics/#{topic.topicId}?count=200&direction=backward")
      req['Authorization'] = "Bearer #{access_token}"
      res = http.request(req)
      if res.code != '200'
        next
      end
      res= JSON.parse(res.body)

      res['posts'].each do |post|
        if Post.where(post_id: post['id']).exists? then
          @post = Post.find_by(post_id: post['id'])
          if post['account']['isBot'] == true
            @post.destroy if @post
            next
          end
          if post['account']['name'] == "sys_registration" then
            user = post['message'].match(%r{(.+?)さん*})[1]
            @post.post_user_name = user
          else
            @post.post_user_name = post['account']['name'].to_s
          end
          @post.like = post['likes'].count
        else
          if post['account']['isBot'] == true
            next
          end
          @post = Post.new
          @post.topic = topic
          @post.post_id = post['id'].to_s
          
          #Cbase管理の人の一括管理を解消するため、名前だけを正規表現で抽出
          if post['account']['name'] == "sys_registration" then
            user = post['message'].match(%r{(.+?)さん*})[1]
            @post.post_user_name = user
          else
            @post.post_user_name = post['account']['name'].to_s
          end
          
          @post.like = post['likes'].count
          @post.posted = Time.parse(post['createdAt']).in_time_zone
        end
        @post.save
      end
      topic.updated_at = Time.now()
      topic.save
    end
  end
end
