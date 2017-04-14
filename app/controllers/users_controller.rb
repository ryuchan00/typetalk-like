class UsersController < ApplicationController
  before_action :require_user_logged_in, only: [:index, :show, :followings, :followers, :favoritenows]

  def index
    @users = User.all.page(params[:page])
  end

  def show
    @user = User.find(params[:id])
    @typetalks = @user.typetalks.order('created_at DESC').page(params[:page])
    counts @user
    favorite_post_counts @user

    require 'net/https'
    require 'uri'
    require 'json'
    require 'time'

    client_id = ENV['CLIENT_ID']
    client_secret = ENV['CLIENT_SECRET']
    topic_id = '40628'

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
    req = Net::HTTP::Get.new("/api/v1/topics/#{topic_id}")
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
        puts post['account']['imageUrl']
        @posts.push(post_data)
      end
      @posts = @posts.sort { |a, b| b['like'] <=> a['like'] }
    }
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      flash[:success] = 'ユーザを登録しました。'
      redirect_to @user
    else
      flash.now[:danger] = 'ユーザの登録に失敗しました。'
      render :new
    end
  end

  def followings
    @user = User.find(params[:id])
    @followings = @user.followings.page(params[:page])
    counts(@user)
    favorite_post_counts @user
  end

  def followers
    @user = User.find(params[:id])
    @followers = @user.followers.page(params[:page])
    counts(@user)
    favorite_post_counts @user
  end

  def favoritenows
    @user = User.find(params[:id])
    @favoritenows = @user.favoritenows.page(params[:page])
    counts(@user)
    favorite_post_counts(@user)
  end

  private

  def user_params
    params.require(:user).permit(:name, :password, :password_confirmation)
  end
end
