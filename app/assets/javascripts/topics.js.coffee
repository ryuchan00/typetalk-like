$('.topics.all').ready ->
$.ajax
  url: 'topics/all_post'
  type: 'GET'
return
#onload = ->
#$.ajax
#  url: 'topics/all_post'
#  type: 'GET'
#return
#$ ->
#  timer = setInterval ->
#    update()
#  , 5000
#
#update = ->
#  $.ajax
#    url: 'topics/all_post'
#    type: 'GET'
#  return