class ToppagesController < ApplicationController
  def index
    if logged_in?
      @user = current_user
      @typetalk = current_user.typetalks.build  # form_for 用
      @typetalks = current_user.feed_typetalks.order('created_at DESC').page(params[:page])
    end
  end
end