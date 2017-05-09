class RecordController < ApplicationController
  def keywd
    @search = SearchKeyword.new
  end

  def keywd_process
    @search = SearchKeyword.new(params[:search_keyword].permit(:keyword))
    if @search.valid?
      render text: @search.keyword
    else
      render text: @search.errors.full_messages[0]
    end
  end
end
