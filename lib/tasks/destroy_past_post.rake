# encoding: utf-8
# http://konboi.hatenablog.com/entry/2013/11/22/182151

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
            puts Time.now.class
            p post.posted
            t = Time.parse(post.posted.to_s)
            puts t.class
            p t
            p t - 2.week
            post.destroy if (Time.now > t + 1.weeks.ago)
        end
    end
end
