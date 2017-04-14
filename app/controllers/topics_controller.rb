class TopicsController < ApplicationController
  def index
    @users = Topic.all.page(params[:page])
    Topic.find_by(user_id: session[:user_id]
  end

  def show
    @user = User.find(params[:id])
  end

  def new
    @topic = Topic.new
  end

  def create
    @topic = Topic.new(user_params)
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

  def user_params
    params.require(:user).permit(:name, :password, :password_confirmation)
  end

  def topic_params
    params.require(:topic).permit(:topicId, :user_id)
  end
end
