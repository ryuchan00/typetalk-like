class TopicsController < ApplicationController
  before_action :require_user_logged_in, only: [:index, :show, :new, :create, :destroy, :all, :all_post, :user, :past_post, :update_latest]
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
      @post.like = post['likes'].count
      @post.posted = Time.parse(post['createdAt']).in_time_zone
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
    http = setup_http
    access_token = get_access_token(http)

    @name = Array.new
    @imageUrl = Array.new

    if access_token != false
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
      @posts = Post.where(["`like` >= :like and `topic_id` = :topic", {like: 1, topic: topic.id}]).order("`like` DESC").page(params[:page]).per(10)
    end

    # setup a http client
    http = setup_http

    # get an access token
    access_token = get_access_token(http)

    # post a message
    @post_data = Array.new
    @posts.each do |post|
      post_json = call_api(access_token, http, "/api/v1/topics/#{topic.topicId}/posts/#{post.post_id.to_i}")

      if post_json != false
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
              "like" => post.like,
              "imageUrl" => post_json['post']['account']['imageUrl'],
              "created_at" => created_time_to_time.to_s
          }
          @post_data.push(post_data)
        end
      else
        topic.delete_post(post)
        p "#{post.post_id.to_i} is empty"
      end
    end
  end

  # def all
  #   @topic_name = 'すべてのトピックの集計'
  #   @post_data = Array.new
  #   @time = Time.now()
  # end

  # def all_post
  #   topics = Topic.all
  #   http = setup_http
  #   access_token = get_access_token(http)
  #   @post_data = Array.new
  #   @time = Time.now().in_time_zone
  #
  #   topics.each do |topic|
  #     posts = Post.where(topic: topic)
  #
  #     posts.each do |post|
  #       req = Net::HTTP::Get.new("/api/v1/topics/#{topic.topicId}/posts/#{post.post_id.to_i}")
  #       req['Authorization'] = "Bearer #{access_token}"
  #       return_json = http.request(req)
  #       if return_json.code == '200'
  #         post_json = JSON.parse(return_json.body)
  #         if post_json['post']['likes'].count != 0 then
  #           created_time = post_json['post']['createdAt']
  #           created_time_to_time = Time.parse(created_time).in_time_zone
  #
  #           post_data = {
  #               "post_id" => post_json['post']['id'],
  #               "topic_id" => post_json['post']['topicId'],
  #               "name" => post_json['post']['account']['fullName'],
  #               "message" => post_json['post']['message'],
  #               "like" => post_json['post']['likes'].count,
  #               "imageUrl" => post_json['post']['account']['imageUrl'],
  #               "created_at" => created_time_to_time.to_s
  #           }
  #           @post_data.push(post_data)
  #         end
  #       else
  #         topic.delete_post(post)
  #         p "#{post.post_id.to_i} is empty"
  #       end
  #     end
  #   end
  #   @post_data = @post_data.sort { |a, b| b['like'] <=> a['like'] }
  # end

  def all
    @topic_name = 'すべてのトピックの集計'
    @post_data = Array.new
    @time = Time.now()
    http = setup_http
    access_token = get_access_token(http)
    @posts = Post.where(["`like` >= :like", {like: 1}]).order("`like` DESC").page(params[:page]).per(10)

    @posts.each do |post|
      topic = Topic.find(post.topic_id)
      res = call_api(access_token, http, "/api/v1/topics/#{topic.topicId}/posts/#{post.post_id.to_i}")
      if res != false
        created_time = res['post']['createdAt']
        created_time_to_time = Time.parse(created_time).in_time_zone

        post_data = {
            "post_id" => res['post']['id'],
            "topic_id" => res['post']['topicId'],
            "name" => res['post']['account']['fullName'],
            "message" => res['post']['message'],
            "like" => post.like,
            "imageUrl" => res['post']['account']['imageUrl'],
            "created_at" => created_time_to_time.to_s
        }
        @post_data.push(post_data)
      else
        topic.delete_post(post)
        p "#{post.post_id.to_i} is empty"
      end
    end
  end

  def user
    # topics = Topic.all
    @topic_name = 'ユーザーごとの集計'
    @post_data = Array.new
    http = setup_http
    access_token = get_access_token(http)
    like_count = {}

    # topics.each do |topic|
    #   posts = Post.where(topic: topic)
    @posts = Post.order("sum_like DESC").group(:post_user_name).sum(:like)
    p @posts

      # posts.each do |post|
      #   req = Net::HTTP::Get.new("/api/v1/topics/#{topic.topicId}/posts/#{post.post_id.to_i}")
      #   req['Authorization'] = "Bearer #{access_token}"
      #   return_json = http.request(req)
      #
      #   if return_json.code == '200'
      #     post_json = JSON.parse(return_json.body)
      #     if post_json['post']['likes'].count != 0 then
      #       if like_count[post_json['post']['account']['name'].to_sym] == nil then
      #         like_count[post_json['post']['account']['name'].to_sym] = post_json['post']['likes'].count
      #       else
      #         like_count[post_json['post']['account']['name'].to_sym] += post_json['post']['likes'].count
      #       end
      #       key = @post_data.index { |item| item["name"] == post_json['post']['account']['fullName'] }
      #
      #       if key.nil? then
      #         post_data = {
      #             "name" => post_json['post']['account']['fullName'],
      #             "like" => like_count[post_json['post']['account']['name'].to_sym].to_i,
      #             "imageUrl" => post_json['post']['account']['imageUrl']
      #         }
      #         @post_data.push(post_data)
      #       else
      #         @post_data[key] = {
      #             "name" => post_json['post']['account']['fullName'],
      #             "like" => like_count[post_json['post']['account']['name'].to_sym].to_i,
      #             "imageUrl" => post_json['post']['account']['imageUrl']
      #         }
      #       end
      #     end
      #   else
      #     # topic.delete_post(post)
      #     p "#{post.post_id.to_i} is empty"
      #   end
      # end
    # end
    # @post_data = @post_data.sort { |a, b| b['like'] <=> a['like'] }
  end

  #対象トピックの過去200件のいいね数を取得
  def past_post
    topic = Topic.find_by(topicId: params[:id])
    http = setup_http
    access_token = get_access_token(http)
    res = call_api(access_token, http, "https://typetalk.in/api/v1/topics/#{topic.topicId}?count=200&direction=backward")
    if res != false
      res['posts'].each do |post|
        if Post.where(post_id: post['id']).exists? then
          @post = Post.find_by(post_id: post['id'])
          p @post
          @post.like = post['likes'].count
        else
          @post = Post.new
          @post.topic = topic
          @post.post_id = post['id'].to_s
          @post.post_user_name = post['account']['name'].to_s
          @post.like = post['likes'].count
          @post.posted = Time.parse(post['createdAt']).in_time_zone
        end
        @post.save
      end
      flash[:success] = '処理が終了しました。'
    else
      flash[:success] = 'トピックが見つかりません、管理者に問い合わせてください。'
    end
    redirect_to :back
  end

  def update_latest
    topics = Topic.all
    http = setup_http
    access_token = get_access_token(http)

    topics.each do |topic|
      posts = Post.where(topic: topic)

      posts.each do |post|
        res_body = call_api(access_token, http, "/api/v1/topics/#{topic.topicId}/posts/#{post.post_id.to_i}")
        if res_body != false
          post.like = res_body['post']['likes'].count
          post.posted = Time.parse(res_body['post']['createdAt']).in_time_zone
          post.save
        else
          topic.delete_post(post)
          p "#{post.post_id.to_i} is empty"
        end
      end
    end
    flash[:success] = '処理が終了しました。'
    redirect_to :back
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

  #typetalkのアクセストークンを生成する。
  def get_access_token(http)
    client_id = ENV['CLIENT_ID']
    client_secret = ENV['CLIENT_SECRET']

    # get an access token
    res = http.post(
        '/oauth2/access_token',
        "client_id=#{client_id}&client_secret=#{client_secret}&grant_type=client_credentials&scope=topic.read"
    )
    if res.code != '200'
      return false
    end
    json = JSON.parse(res.body)
    return json['access_token']
  end

  #httpインスタンスを生成する。
  def setup_http
    http = Net::HTTP.new('typetalk.in', 443)
    http.use_ssl = true
    return http
  end

  #accesstokenとhttpオブジェクトからapiを呼び出す。
  def call_api(access_token, http, url)
    req = Net::HTTP::Get.new(url.to_s)
    req['Authorization'] = "Bearer #{access_token}"
    res = http.request(req)
    if res.code != '200'
      return false
    end
    return JSON.parse(res.body)
  end

end
