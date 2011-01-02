//http://javascript.crockford.com/prototypal.html
if (typeof Object.create !== 'function') {
    Object.create = function (o) {
        function F() {}
        F.prototype = o;
        return new F();
    };
}
//newObject = Object.create(oldObject);

_.mixin({
  "s" : function (val, start, end) {
    var need_to_join = false;
    var ret = []
    if (typeof val == "string") {
      val = val.split("")
      need_to_join = true;
    }
    if (start >= 0) {
    } else {
        start = val.length + start
    }
    
    if (end == null) {
       ret = val.slice(start)
    } else {
        if (end < 0) {
          end = val.length + end; 
        } else {
          end = end + start
        }
        ret = val.slice(start, end)
    }
      
    if (need_to_join) {
        return ret.join("")
    } else {
        return ret;
    }
  }

  ,"startsWith" : function(str, with_what) {
    return _(str).s(0, with_what.length) == with_what
  }
  
  ,"rnd" : function(low, high) {
    return Math.floor(Math.random() * (high-low+1)) + low
  }
  ,"time": function time() {
    return (new Date()).getTime()
  }
  ,capitalize : function(str) {
    return str.charAt(0).toUpperCase() + str.substring(1).toLowerCase();
  }

})