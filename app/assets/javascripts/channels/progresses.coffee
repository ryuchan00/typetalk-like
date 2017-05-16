App.progresses = App.cable.subscriptions.create 'ProgressesChannel',
  connected: ->
    @install()
    @follow()

  received: (data) ->
    $('.progress-percentage').text("#{data.percent}%")
    $('progress').prop('value', data.percent)

  follow: ->
    # 例示のため、購読対象の識別子 (progress_id) は決め打ち
    @perform('follow', progress_id: 1)

  install: ->
    $(document).on('page:change', -> App.progresses.follow())
