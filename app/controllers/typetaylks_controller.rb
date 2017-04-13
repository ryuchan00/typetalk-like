class TypetalksController < ApplicationController
  before_action :require_user_logged_in
  before_action :correct_user, only: [:destroy]

  def create
    @typetalk = current_user.typetalks.build(typetalk_params)
    if @typetalk.save
      flash[:success] = 'メッセージを投稿しました。'
      redirect_to root_url
    else
      flash[:danger] = 'メッセージの投稿に失敗しました。'
      redirect_to root_url
      # render 'toppages/index'
    end
  end

  def destroy
    @typetalk.destroy
    flash[:success] = 'メッセージを削除しました。'
    redirect_back(fallback_location: root_path)
  end

  private

  def typetalk_params
    params.require(:typetalk).permit(:content)
  end

  def correct_user
    @typetalk = current_user.typetalks.find_by(id: params[:id])
    unless @typetalk
      redirect_to root_path
    end
  end
end