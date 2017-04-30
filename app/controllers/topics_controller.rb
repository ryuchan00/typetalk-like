class TopicsController < ApplicationController
  before_action :require_user_logged_in, only: [:index, :show, :new, :create, :destroy, :all, :user]
  # この↓一文がないとCSRFチェックでこけるので、APIをやりとりしているControllerには必要
  skip_before_filter :verify_authenticity_token

  # ajax処理のため
  # respond_to :html, :js

  def receive
    # 読み込み時に一度パースが必要
    json_request = JSON.parse(request.body.read)

    # パース後のデータを表示
    # p "json_request => #{json_request}"
    # p "#{json_request.to_hash}"

    # 各要素へのアクセス方法
    # p "glossary => #{json_request["glossary"]}"
    # p "glossary.title => #{json_request["glossary"]["title"]}"

    # この後、postされたデータをDBに突っ込むなり、必要な処理を記述してください。
    if !json_request.blank?
      post = json_request
      @post = Post.new
      topic = Topic.find_or_initialize_by(topicId: post["topic"]["id"].to_s)
      if topic.new_record?
        # 新規作成の場合は保存
        # 新規作成時に行いたい処理を記述
        if topic.save
          p 'トピックを登録しました。'
        else
          p 'トピックの登録に失敗しました。'
        end
      end
      @post.topic = topic
      @post.post_id = post["post"]["id"].to_s
      @post.post_user_name = post["post"]["account"]["name"].to_s
      if @post.save
        p '投稿を登録しました。'
      else
        p '投稿の登録に失敗しました。'
      end
    else
      post = {'status' => 500}
    end

    render :json => post
  end

  def index
    @user = current_user
    @topics = Topic.all

    require 'net/https'
    require 'uri'
    require 'json'
    require 'time'

    client_id = ENV['CLIENT_ID']
    client_secret = ENV['CLIENT_SECRET']

    # setup a http client
    http = Net::HTTP.new('typetalk.in', 443)
    http.use_ssl = true

    # get an access token
    res = http.post(
        '/oauth2/access_token',
        "client_id=#{client_id}&client_secret=#{client_secret}&grant_type=client_credentials&scope=topic.read"
    )

    @name = Array.new
    @imageUrl = Array.new

    if res.code == '200'
      json = JSON.parse(res.body)
      access_token = json['access_token']

      @topics.each do |topic|
        req = Net::HTTP::Get.new("https://typetalk.in/api/v1/topics/#{topic.topicId}/details")
        req['Authorization'] = "Bearer #{access_token}"
        return_json = http.request(req)

        if return_json.code == '200'
          topic_info = JSON.parse(return_json.body)
          @name.push({"id" => topic_info['topic']['id'].to_s,
                      "name" => topic_info['topic']['name'].to_s})
        end
      end
    end
  end

  def show
    param_topic_id = params[:id]
    if Topic.where(topicId: param_topic_id).exists?
      topic = Topic.find_by(topicId: param_topic_id)
      @posts = Post.where(topic: topic)
    end

    require 'net/https'
    require 'uri'
    require 'json'
    require 'time'

    client_id = ENV['CLIENT_ID']
    client_secret = ENV['CLIENT_SECRET']

    # setup a http client
    http = Net::HTTP.new('typetalk.in', 443)
    http.use_ssl = true

    # get an access token
    res = http.post(
        '/oauth2/access_token',
        "client_id=#{client_id}&client_secret=#{client_secret}&grant_type=client_credentials&scope=topic.read"
    )
    json = JSON.parse(res.body)
    access_token = json['access_token']

    # post a message
    @post_data = Array.new
    http = Net::HTTP.new('typetalk.in', 443)
    http.use_ssl = true
    @posts.each do |post|
      req = Net::HTTP::Get.new("/api/v1/topics/#{topic.topicId}/posts/#{post.post_id.to_i}")
      req['Authorization'] = "Bearer #{access_token}"
      return_json = http.request(req)

      if return_json.code == '200'
        post_json = JSON.parse(return_json.body)
        if @post_data.empty?
          @topic_name = post_json['topic']['name']
        end

        if post_json['post']['likes'].count != 0 then
          created_time = post_json['post']['createdAt']
          created_time_to_time = Time.parse(created_time).in_time_zone

          post_data = {
              "post_id" => post_json['post']['id'],
              "topic_id" => post_json['post']['topicId'],
              "name" => post_json['post']['account']['fullName'],
              "message" => post_json['post']['message'],
              "like" => post_json['post']['likes'].count,
              "imageUrl" => post_json['post']['account']['imageUrl'],
              "created_at" => created_time_to_time.to_s
          }
          @post_data.push(post_data)
        end
      else
        p "#{post.post_id.to_i} is empty"
        # post_id = post.post_id.to_i
        # destropy_post = Post.where(post_id: post_id)
        # Post.destroy(destropy_post)
      end
    end
    @post_data = @post_data.sort { |a, b| b['like'] <=> a['like'] }
  end

  def ajax_action
    @time = Time.now().in_time_zone
    topics = Topic.all
    access_token = get_access_token
    @post_data = Array.new

    topics.each do |topic|
      require 'net/https'
      require 'uri'
      require 'json'
      require 'time'

      posts = Post.where(topic: topic)
      http = Net::HTTP.new('typetalk.in', 443)
      http.use_ssl = true

      posts.each do |post|
        req = Net::HTTP::Get.new("/api/v1/topics/#{topic.topicId}/posts/#{post.post_id.to_i}")
        req['Authorization'] = "Bearer #{access_token}"
        return_json = http.request(req)
        if return_json.code == '200'
          post_json = JSON.parse(return_json.body)
          if post_json['post']['likes'].count != 0 then
            created_time = post_json['post']['createdAt']
            created_time_to_time = Time.parse(created_time).in_time_zone

            post_data = {
                "post_id" => post_json['post']['id'],
                "topic_id" => post_json['post']['topicId'],
                "name" => post_json['post']['account']['fullName'],
                "message" => post_json['post']['message'],
                "like" => post_json['post']['likes'].count,
                "imageUrl" => post_json['post']['account']['imageUrl'],
                "created_at" => created_time_to_time.to_s
            }
            @post_data.push(post_data)
          end
        else
          p "#{post.post_id.to_i} is empty"
          # post_id = post.post_id.to_i
          # destropy_post = Post.where(post_id: post_id)
          # Post.destroy(destropy_post)
        end
      end
    end
    @post_data = @post_data.sort { |a, b| b['like'] <=> a['like'] }
  end

  def all
    # topics = Topic.all
    # access_token = get_access_token
    @topic_name = 'すべてのトピックの集計'
    @post_data = Array.new
    require 'time'
    @time = Time.now()


    # topics.each do |topic|
    #   require 'net/https'
    #   require 'uri'
    #   require 'json'
    #   require 'time'
    #
    #   posts = Post.where(topic: topic)
    #   http = Net::HTTP.new('typetalk.in', 443)
    #   http.use_ssl = true
    #
    #   posts.each do |post|
    #     req = Net::HTTP::Get.new("/api/v1/topics/#{topic.topicId}/posts/#{post.post_id.to_i}")
    #     req['Authorization'] = "Bearer #{access_token}"
    #     return_json = http.request(req)
    #     if return_json.code == '200'
    #       post_json = JSON.parse(return_json.body)
    #       if post_json['post']['likes'].count != 0 then
    #         created_time = post_json['post']['createdAt']
    #         created_time_to_time = Time.parse(created_time).in_time_zone
    #
    #         post_data = {
    #             "post_id" => post_json['post']['id'],
    #             "topic_id" => post_json['post']['topicId'],
    #             "name" => post_json['post']['account']['fullName'],
    #             "message" => post_json['post']['message'],
    #             "like" => post_json['post']['likes'].count,
    #             "imageUrl" => post_json['post']['account']['imageUrl'],
    #             "created_at" => created_time_to_time.to_s
    #         }
    #         @post_data.push(post_data)
    #       end
    #     else
    #       p "#{post.post_id.to_i} is empty"
    #       # post_id = post.post_id.to_i
    #       # destropy_post = Post.where(post_id: post_id)
    #       # Post.destroy(destropy_post)
    #     end
    #   end
    # end
    # @post_data = @post_data.sort { |a, b| b['like'] <=> a['like'] }
  end

  def user
    topics = Topic.all
    access_token = get_access_token
    @topic_name = 'ユーザーごとの集計'
    @post_data = Array.new

    require 'ostruct'
    # like_count = OpenStruct.new
    like_count = {}

    topics.each do |topic|
      require 'net/https'
      require 'uri'
      require 'json'
      require 'time'

      posts = Post.where(topic: topic)
      http = Net::HTTP.new('typetalk.in', 443)
      http.use_ssl = true

      posts.each do |post|
        req = Net::HTTP::Get.new("/api/v1/topics/#{topic.topicId}/posts/#{post.post_id.to_i}")
        req['Authorization'] = "Bearer #{access_token}"
        return_json = http.request(req)

        if return_json.code == '200'
          post_json = JSON.parse(return_json.body)
          if post_json['post']['likes'].count != 0 then
            if like_count[post_json['post']['account']['name'].to_sym] == nil then
              like_count[post_json['post']['account']['name'].to_sym] = 0
              p like_count
            else
              like_count[post_json['post']['account']['name'].to_sym] += post_json['post']['likes'].count
              # end
            end
            key = @post_data.index { |item| item["name"] == post_json['post']['account']['fullName'] }

            if key.nil? then
              post_data = {
                  "name" => post_json['post']['account']['fullName'],
                  "like" => like_count[post_json['post']['account']['name'].to_sym].to_i,
                  "imageUrl" => post_json['post']['account']['imageUrl']
              }
              @post_data.push(post_data)
            else
              @post_data[key] = {
                  "name" => post_json['post']['account']['fullName'],
                  "like" => like_count[post_json['post']['account']['name'].to_sym].to_i,
                  "imageUrl" => post_json['post']['account']['imageUrl']
              }
            end
          end
        else
          p "#{post.post_id.to_i} is empty"
          # post_id = post.post_id.to_i
          # destropy_post = Post.where(post_id: post_id)
          # Post.destroy(destropy_post)
        end
      end
    end
    @post_data = @post_data.sort { |a, b| b['like'] <=> a['like'] }
  end

  def new
    @topic = Topic.new
  end

  def create
    @topic = current_user.topics.build(topic_params)
    @topic.topicId = @topic.topicId.split('/').last
    if @topic.save
      flash[:success] = 'トピックを登録しました。'
      redirect_to @topic
    else
      flash.now[:danger] = 'トピックの登録に失敗しました。'
      render :new
    end
  end

  def destroy
  end

  private

  def topic_params
    params.require(:topic).permit(:topicId)
  end

  def get_access_token
    require 'net/https'
    require 'uri'
    require 'json'

    client_id = ENV['CLIENT_ID']
    client_secret = ENV['CLIENT_SECRET']

    # setup a http client
    http = Net::HTTP.new('typetalk.in', 443)
    http.use_ssl = true

    # get an access token
    res = http.post(
        '/oauth2/access_token',
        "client_id=#{client_id}&client_secret=#{client_secret}&grant_type=client_credentials&scope=topic.read"
    )
    json = JSON.parse(res.body)
    return json['access_token']
  end
end
