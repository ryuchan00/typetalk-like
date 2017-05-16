# encoding: utf-8

namespace :past_user do
    desc "posts中created_atから１週間が経過していれば削除" #=> 説明

# $ rake inactive_user:destroy_unconfirmed のように使う
# :environmentは超大事。ないとモデルにアクセスできない

    task :destroy_unconfirmed => :environment do 
        Post.all.each do |post|
            user.destroy if (Time.now > user.confirm_at + 1.weeks.ago)
        end
    end
end
