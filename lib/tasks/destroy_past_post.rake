# encoding: utf-8

require 'time'

namespace :destroy_past_post do
    desc "posts中postedから１週間が経過していれば削除"

# $ rake inactive_user:destroy_unconfirmed のように使う
# :environmentは超大事。ないとモデルにアクセスできない

    task :destroy => :environment do 
        Post.all.each do |post|
            logger = Logger.new('log/past_post.log')
            logger.info "#{Time.now} -- destroy_past_post -- #{post.to_yaml}"
            # t = Time.new(post.posted)
            # post.destroy if (Time.now > post.posted + 1.weeks.ago)
            p Time.now
            p post.posted
            p Time.parse(post.posted.to_s)
            p post.posted + 1.weeks.ago
            post.destroy if (Time.now > t + 1.weeks.ago)
        end
    end
end
