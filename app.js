(function() {
  $(document).ready(function() {
    window.ws = new WebSocket("ws://b.the.tl:9998/");
    ws.onopen = function() {
      return console.log("open");
    };
    ws.onmessage = function(e) {
      var data;
      data = JSON.parse(e.data);
      return app[data[0]](data[1]);
    };
    ws.onclose = function(e) {
      return console.log("closed!!");
    };
    return ws.onerror = function(e) {
      return console.log("error");
    };
  });
  window.app = {};
  app.addField = function() {
    var clicky;
    app.field = document.createElement("div");
    $(app.field).css({
      height: "320px",
      width: "320px"
    });
    $(app.field).attr("id", "field");
    $('#wrapper').append(app.field);
    if ($.os.ios || $.os.android || $.os.webos) {
      clicky = "touchstart";
    } else {
      clicky = "click";
    }
    return $('#field').bind(clicky, function(e) {
      e.preventDefault();
      if (e.touches) {
        e = e.touches[0];
      }
      return ws.send(JSON.stringify([
        "repos", {
          x: e.clientX,
          y: e.clientY
        }
      ]));
    });
  };
  app.getByCid = {};
  app.renderUser = function(user) {
    var oldUser;
    if (!(user.__cid in app.getByCid)) {
      app.users.push(user);
      user.dom = document.createElement("div");
      $(user.dom).html(user.__cid);
      $(user.dom).css({
        "position": "absolute",
        top: "0",
        left: "0"
      });
      app.getByCid[user.__cid] = user;
      $('#field').append(user.dom);
    } else {
      oldUser = app.getByCid[user.__cid];
      user = _.extend(oldUser, user);
    }
    return $(user.dom).anim({
      translateX: user.x + "px",
      translateY: user.y + "px"
    });
  };
  app.users = [];
  app.updateUsers = function(data) {
    var user, _i, _len, _results;
    _results = [];
    for (_i = 0, _len = data.length; _i < _len; _i++) {
      user = data[_i];
      _results.push(app.renderUser(user));
    }
    return _results;
  };
  app.log = function(str) {};
  app.tileWidth = 32;
  app.tileHeight = 32;
  app.renderScreen = function(tiles) {
    var cell, row, str, tile, x, y, _i, _j, _len, _len2, _results;
    app.addField();
    x = 0;
    y = 0;
    if (_.isString(tiles)) {
      tiles = tiles.split("\n");
    }
    _results = [];
    for (_i = 0, _len = tiles.length; _i < _len; _i++) {
      row = tiles[_i];
      if (_.isString(row)) {
        row = row.split("");
      }
      for (_j = 0, _len2 = row.length; _j < _len2; _j++) {
        cell = row[_j];
        if (_.isString(cell)) {
          str = cell;
          cell = {};
          if (str === "-") {
            cell.color = "green";
          } else if (str === "o") {
            cell.color = "#aaaaaa";
          }
        }
        tile = document.createElement("div");
        if ("color" in cell) {
          $(tile).css({
            "background-color": cell.color
          });
        }
        $(tile).attr("data-pos", "" + x + "," + y).css({
          position: "absolute",
          left: app.tileWidth * x + "px",
          top: app.tileHeight * y + "px",
          width: app.tileWidth + "px",
          height: app.tileHeight + "px"
        });
        $('#field').append(tile);
        x++;
      }
      x = 0;
      _results.push(y++);
    }
    return _results;
  };
}).call(this);
