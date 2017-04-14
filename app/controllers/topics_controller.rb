class TopicsController < ApplicationController
  def index
    @topics = Topic.where(user: session[:user_id])
    # @topic = Topic.find(params[:id])
    # @tasks = Task.order(id: :asc).page(params[:page]).per(10)
  end

  def show
    @topic = Topic.find(params[:id])
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
