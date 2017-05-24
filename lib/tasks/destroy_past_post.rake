# encoding: utf-8
# http://konboi.hatenablog.com/entry/2013/11/22/182151

namespace :destroy_past_post do
  desc "posts中postedから１週間が経過していれば削除"

# $ rake inactive_user:destroy_unconfirmed のように使う
# :environmentは超大事。ないとモデルにアクセスできない

  task :destroy => :environment do
    Post.all.each do |post|
      logger = Logger.new('log/past_post.log')
      logger.info "#{Time.now} -- destroy_past_post -- #{post.to_yaml}"
      t = Time.parse(post.posted.to_s)
      post.destroy if (Time.now.in_time_zone > t + 3.month)
    end
  end
end
