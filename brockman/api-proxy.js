var http = require('http'),
  request = require('request');

var app = http.createServer(function (req, resp) {
  var origin, target = "oauth.reddit.com";
  if (req.headers.origin.match(/(localhost|\.dev|\.local|127\.0\.0\.1)\:\d+$/)) {
    origin = req.headers.origin;
  } else {
    origin = "http://springfieldopen.com";
  }

  resp.setHeader("Access-Control-Allow-Origin", origin);
  resp.setHeader("Access-Control-Allow-Headers", "X-Requested-With,Authorization,Content-Type");

  if (req.method === "OPTIONS") {
    resp.statusCode = 200;
    resp.setHeader("Access-Control-Allow-Methods", "POST, GET, OPTIONS");
    resp.end()
  } else {
    req.headers.host = target;
    req.pipe(request({
      url: "https://" + target + req.url,
      method: req.method,
      headers: req.headers
    })).pipe(resp);
  }
});

var port = process.env.PORT || 5001;
app.listen(port, function () {
  console.log("Listening on " + port);
});
