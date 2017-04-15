class TopicsController < ApplicationController
  def index
    @topics = Topic.where(user: session[:user_id])
  end

  def show
    # @topic = Topic.find(params[:id])
    require 'net/https'
    require 'uri'
    require 'json'
    require 'time'

    client_id = ENV['CLIENT_ID']
    client_secret = ENV['CLIENT_SECRET']
    topic_id = topic.topidId

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
    JSON.parse(return_json.body)['posts'].each { |post|
      # puts post['account']['fullName']
      # puts post['message']
      # puts post['likes'].count
      if post['likes'].count != 0 then
        created_time = post['createdAt']
        created_time_to_time = Time.parse(created_time).in_time_zone
        puts created_time_to_time

        post_data = {
            "name" => post['account']['fullName'],
            "message" => post['message'],
            "like" => post['likes'].count,
            "imageUrl" => post['account']['imageUrl'],
            "created_at" => created_time_to_time.to_s
        }
        puts post['account']['fullName']
        puts post_data['like']
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
    # p @topic.topicId.split('/').last
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
