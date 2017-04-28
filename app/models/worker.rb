class WorkerForResque
  @queue = :resque
  def self.perform(text)
    sleep 5
    p "resque: #{text}"
  end
end

# Sidekiq と同じで必要情報は全て引数で perform メソッドに渡す必要あり
