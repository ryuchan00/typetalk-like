Resque.redis = 'localhost:6379'
Resque.redis.namespace = "resque"

# 補足：アプリ & 環境 でネームスペースを決めた方がいいらしい
# Resque.redis.namespace = "resque:app_name:#{Rails.env}"

class WorkerForResque
  @queue = :resque
  def self.perform(text)
    sleep 5
    p "resque: #{text}"
  end
end

# Sidekiq と同じで必要情報は全て引数で perform メソッドに渡す必要あり

# http://jetglass.hatenablog.jp/entry/2015/07/15/181145