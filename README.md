# Springfield Open

The main site is Homer (of course), Mr Burns and Brockman are little services that run on Heroku, but they're up on Heroku already.

Homer is just a yeoman app, so:

    cd homer
    npm install
    bower install
    grunt server

You should be prompted to log in, so do it. Reddit will auth you, redirect you back to Mr Burns on heroku and that'll redirect to localhost:9000.

Then you can jump onto a Battle page, which actually pulls the data from Reddit, and you can look at an episode too, with comments!!

## Cron stuff

```
* * * * * cd ~/Documents/springfieldopen.com/lisa; ruby tasks/update_tournament.rb
```
