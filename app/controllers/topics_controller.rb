class TopicsController < ApplicationController
  before_action :require_user_logged_in, only: [:index, :show, :new, :create, :destroy]

  def index
    @user = current_user
    @topics = Topic.where(user: session[:user_id])

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
        # "client_id=#{client_id}&client_secret=#{client_secret}&grant_type=client_credentials&scope=topic.read"
        "client_id=#{client_id}&client_secret=#{client_secret}&grant_type=client_credentials&scope=my"
    )
    json = JSON.parse(res.body)
    access_token = json['access_token']
    req = Net::HTTP::Get.new("/api/v1/topics")
    req['Authorization'] = "Bearer #{access_token}"
    return_json = http.request(req)

    @name = Array.new
    @imageUrl = Array.new
# p JSON.parse(return_json.body)['topics']
    JSON.parse(return_json.body)['topics'].each { |topic|
      p topic
      # if key == 'topic' then
      # @name[topic['topic']['id']] = topic['topic']['name'].to_s
      @name.push({"id" => topic['topic']['id'].to_s,
                  "name" => topic['topic']['name'].to_s})
      # end
    }
    p @name

    # @topics.each do |topic|
    #   p topic.topicId
    #   topic_id = topic.topicId.to_s
    #   # req = Net::HTTP::Get.new("/api/v1/topics/#{topic_id}/details")
    #   req = Net::HTTP::Get.new("/api/v1/topics")
    #   req['Authorization'] = "Bearer #{access_token}"
    #   return_json = http.request(req)
    #   @name[topic.id] = JSON.parse(return_json.body)['topic']['name']
    #   p JSON.parse(return_json.body)['mySpace']['imageUrl']
    #   @imageUrl[topic.id] = JSON.parse(return_json.body)['mySpace']['space']['imageUrl']
    # end
  end

  def show
    # @topic = Topic.find(params[:id])
    param_topic_id = params[:id]

    require 'net/https'
    require 'uri'
    require 'json'
    require 'time'

    client_id = ENV['CLIENT_ID']
    client_secret = ENV['CLIENT_SECRET']
    # topic_id = @topic.topicId.to_s
    topic_id = param_topic_id

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
    req = Net::HTTP::Get.new("/api/v1/topics/#{topic_id}?direction=backward&count=200")
    req['Authorization'] = "Bearer #{access_token}"
    return_json = http.request(req)
    @posts = Array.new
    @topic_name = JSON.parse(return_json.body)['topic']['name'].to_s
    JSON.parse(return_json.body)['posts'].each { |post|
      # puts post['account']['fullName']
      # puts post['message']
      # puts post['likes'].count
      if post['likes'].count != 0 then
        created_time = post['createdAt']
        created_time_to_time = Time.parse(created_time).in_time_zone

        post_data = {
            "post_id" => post['id'],
            "name" => post['account']['fullName'],
            "message" => post['message'],
            "like" => post['likes'].count,
            "imageUrl" => post['account']['imageUrl'],
            "created_at" => created_time_to_time.to_s
        }
        # puts post['account']['fullName']
        # puts post_data['like']
        @posts.push(post_data)
      end
      @posts = @posts.sort { |a, b| b['like'] <=> a['like'] }
    }
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

end
