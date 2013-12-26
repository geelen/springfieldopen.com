'use strict'
app = angular.module 'homerApp'

app.factory 'TournamentManager', ($rootScope, RedditApi) ->
  TournamentManager = $rootScope.$new(true)

  load_battle = (comments) ->
    battle = {}
    battle.ep1 = load_battle_episode(comments[0].data)
    battle.ep2 = load_battle_episode(comments[1].data)
    battle.ep1.other_item = battle.ep2
    battle.ep2.other_item = battle.ep1
    battle

  load_battle_episode = (comment) ->
    battle_ep = comment
    ep_details = comment.body.split("\n")
    battle_ep.ep_name = ep_details[0]
    battle_ep.ep_image_url = ep_details[1]
    title_pieces = ep_details[2].split(" ")
    battle_ep.ep_num = title_pieces[0]
    battle_ep.ep_title = title_pieces[1..title_pieces.length-1].join(" ")
    battle_ep

  TournamentManager.update_battles = () ->
    RedditApi.get("/r/SpringfieldOpen.json").then (response) ->
      rounds = response.data.data.children
      open_round = (rounds.filter (c) -> c.data.selftext == "open")[0]
      round_post = open_round.data.id
      RedditApi.get("/comments/#{round_post}.json").then (response) ->
        TournamentManager.battles = response.data[1].data.children.map (c) -> 
          load_battle(c.data.replies.data.children)  

  TournamentManager.battles = []
  TournamentManager.update_battles()
  TournamentManager
