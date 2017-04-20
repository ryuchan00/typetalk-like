class TopicsController < ApplicationController
  before_action :require_user_logged_in, only: [:index, :show, :new, :create, :destroy]
  # この↓一文がないとCSRFチェックでこけるので、APIをやりとりしているControllerには必要
  skip_before_filter :verify_authenticity_token

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
      @topic = Topic.new
      @post = Post.new
      @topic.topicId = post["topic"]["id"].to_s
      @post.topic = @topic
      @post.post_id = post["post"]["id"].to_s
      p post["post"]["account"]["name"].to_s
      @post.post_user_id = post["post"]["account"]["name"].to_s
      p post["topic"]["id"]
      if @topic.save
        p 'トピックを登録しました。'
      else
        p 'トピックの登録に失敗しました。'
      end
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
            "topic_id" => post['topicId'],
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
