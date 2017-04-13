class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  
  include SessionsHelper

  private

  def require_user_logged_in
    unless logged_in?
      redirect_to login_url
    end
  end

  def counts(user)
    @count_typetalks = user.typetalks.count
    @count_followings = user.followings.count
    @count_followers = user.followers.count
  end
  
  def favorite_post_counts(user)
    @count_favoritenows = user.favoritenows.count
    @count_post_users = user.post_users.count
  end
end