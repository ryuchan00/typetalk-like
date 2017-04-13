class FavoritepostsController < ApplicationController
    before_action :require_user_logged_in

  def create
    typetalk = Typetalk.find(params[:favorite_post_id])
    current_user.favorite(typetalk)
    flash[:success] = 'お気に入りに登録しました。'
    redirect_to :back 
  end

  def destroy
    typetalk = Typetalk.find(params[:favorite_post_id])
    current_user.unfavorite(typetalk)
    flash[:success] = 'お気に入りに解除しました。'
    redirect_to :back 
  end
end
