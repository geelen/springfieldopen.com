var http = require('http'),
  request = require('request');

var app = http.createServer(function (req, resp) {
  resp.setHeader("Access-Control-Allow-Origin", "*");
  resp.setHeader("Access-Control-Allow-Headers", "X-Requested-With,Authorization");

  if (req.method === "OPTIONS") {
    resp.statusCode = 200;
    resp.setHeader("Access-Control-Allow-Methods", "POST, GET, OPTIONS");
    resp.end()
  } else {
    request({
      url: "https://oauth.reddit.com" + req.url,
      headers: {
        authorization: req.headers.authorization
      }
    }).pipe(resp);
  }
});

var port = process.env.PORT || 5001;
app.listen(port, function () {
  console.log("Listening on " + port);
});
