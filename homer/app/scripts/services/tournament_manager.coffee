'use strict'
app = angular.module 'homerApp'

load_battle = (comments) ->
  battle = {}
  battle.ep1 = load_battle_episode(comments[0].data)
  battle.ep2 = load_battle_episode(comments[1].data)
  battle.ep1.other_item = battle.ep2
  battle.ep2.other_item = battle.ep1
  battle

load_battle_episode = (comment) ->
  battle_ep = comment
  battle_ep.ep_name = angular.fromJson(comment.body)['name']
  battle_ep.ep_image_url = angular.fromJson(comment.body)['image']
  battle_ep.ep_full_title = angular.fromJson(comment.body)['title']
  title_pieces = battle_ep.ep_full_title.split(" ")
  battle_ep.ep_num = title_pieces[0]
  battle_ep.ep_title = title_pieces[1..title_pieces.length-1].join(" ")
  battle_ep

app.factory 'TournamentManager', (RedditApi) ->
  TournamentManager = {
    battles: []
  }

  TournamentManager.update_battles = ->
    RedditApi.get("/r/SpringfieldOpenTest.json").then (response) ->
      setTimeout(TournamentManager.update_battles, 10 * 1000)
      rounds = response.data.data.children
      open_round = (rounds.filter (c) -> 
        angular.fromJson(c.data.selftext)['status'] == "open"
      )[0]
      ready_round = (rounds.filter (c) -> 
        angular.fromJson(c.data.selftext)['status'] == "ready"
      )[0]
      if open_round
        round_post = open_round.data.id
        # console.log(open_round.data.title)
        end_time = angular.fromJson(open_round.data.selftext)['end_time']
        # console.log(end_time)
        TournamentManager.time_of_next_event = end_time
        TournamentManager.status = "round_in_progress"
        RedditApi.get("/comments/#{round_post}.json").then (response) ->
          TournamentManager.battles = response.data[1].data.children.map (c) ->
            load_battle(c.data.replies.data.children)
      else if ready_round
        start_time = angular.fromJson(ready_round.data.selftext)['start_time']
        TournamentManager.time_of_next_event = start_time
        # console.log(start_time)
        TournamentManager.status = "between_rounds"
      else
        TournamentManager.status = "tournament_over"
        console.log("Tournament is over")

  TournamentManager.round_in_progress = () ->
    TournamentManager.status == "round_in_progress"

  TournamentManager.between_rounds = () ->
    TournamentManager.status == "between_rounds"

  TournamentManager.tournament_over = () ->
    TournamentManager.status == "tournament_over"

  TournamentManager.update_battles()
  TournamentManager
