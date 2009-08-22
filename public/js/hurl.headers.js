(function() {
  Hurl.autocompleteHeaders = function(el) {
    $(el).autocompleteArray(headerNames(), {
      delay: 40,
      onItemSelect: function(e) {
        var header = $(e).text(), next = $(el).siblings('input')
        var more = Hurl.Headers[header]

        if ( more == "date" ) {
          next.val( GetRFC822Date(new Date) )
        } else if ( more ) {
          next.autocompleteArray( more, { delay: 40 } )
        }

        next.focus()
      }
    })
  }

  function headerNames() {
    var names = []
    for (name in Hurl.Headers) {
      names.push(name)
    }
    return names
  }

  Hurl.Headers = {
    "Accept": ["*/*", "text/plain", "text/html, text/plain", "application/xml", "application/json"],
    "Accept-Encoding": [ "compress", "deflate", "gzip", "compress, gzip", "gzip, deflate"],
    "Accept-Language": [ "en", "es", "de", "fr", "*" ],
    "Cache-Control": [ "cache", "no-cache" ],
    "Connection": [ "close", "keep-alive" ],
    "Cookie": null,
    "Content-Length": null,
    "Content-Type": [ "application/octet-stream", "application/x-www-form-urlencoded", "application/xml", "application/json", "text/html", "text/plain", "text/xml" ],
    "From": null,
    "Host": null,
    "If-Match": [ "*" ],
    "If-Modified-Since": "date",
    "If-None-Match": [ "*" ],
    "If-Range": "date",
    "If-Unmodified-Since": "date",
    "Max-Forwards": null,
    "Pragma": [ "cache", "no-cache" ],
    "User-Agent": null
  }


  /*
   * Stolen without mercy nor remorse from
   * http://www.sanctumvoid.net/jsexamples/rfc822datetime/rfc822datetime.html
   */

  /*Accepts a Javascript Date object as the parameter;
  outputs an RFC822-formatted datetime string. */
  function GetRFC822Date(oDate)
  {
    var aMonths = new Array("Jan", "Feb", "Mar", "Apr", "May", "Jun",
                            "Jul", "Aug", "Sep", "Oct", "Nov", "Dec");

    var aDays = new Array( "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat");
    var dtm = new String();

    dtm = aDays[oDate.getDay()] + ", ";
    dtm += padWithZero(oDate.getDate()) + " ";
    dtm += aMonths[oDate.getMonth()] + " ";
    dtm += oDate.getFullYear() + " ";
    dtm += padWithZero(oDate.getHours()) + ":";
    dtm += padWithZero(oDate.getMinutes()) + ":";
    dtm += padWithZero(oDate.getSeconds()) + " " ;
    dtm += getTZOString(oDate.getTimezoneOffset());
    return dtm;
  }

  //Pads numbers with a preceding 0 if the number is less than 10.
  function padWithZero(val)
  {
    if (parseInt(val) < 10)
    {
      return "0" + val;
    }
    return val;
  }

  /* accepts the client's time zone offset from GMT in minutes as a parameter.
  returns the timezone offset in the format [+|-}DDDD */
  function getTZOString(timezoneOffset)
  {
    var hours = Math.floor(timezoneOffset/60);
    var modMin = Math.abs(timezoneOffset%60);
    var s = new String();
    s += (hours > 0) ? "-" : "+";
    var absHours = Math.abs(hours)
    s += (absHours < 10) ? "0" + absHours :absHours;
    s += ((modMin == 0) ? "00" : modMin);
    return(s);
  }
})();