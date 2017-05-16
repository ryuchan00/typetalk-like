# encoding: utf-8

namespace :past_user do
    desc "Users中confirm_atから１週間が経過していれば削除" #=> 説明

# $ rake inactive_user:destroy_unconfirmed のように使う
# :environmentは超大事。ないとモデルにアクセスできない

    task :destroy_unconfirmed => :environment do 
        User.all.each do |user|
            user.destroy if (Time.now > user.confirm_at + 1.weeks.ago)
        end
    end
end