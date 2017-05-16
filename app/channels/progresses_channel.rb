class ProgressesChannel < ApplicationCable::Channel
  def follow(data)
    stream_from("progresses:#{data['progress_id'].to_i}")
  end
end
