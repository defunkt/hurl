var Hurl = {
  headers: [
    "Accept",
    "Accept-Charset",
    "Accept-Encoding",
    "Accept-Language",
    "Accept-Ranges",
    "Authorization",
    "Cache-Control",
    "Connection",
    "Cookie",
    "Content-Length",
    "Content-Type",
    "Date",
    "Expect",
    "From",
    "Host",
    "If-Match",
    "If-Modified-Since",
    "If-None-Match",
    "If-Range",
    "If-Unmodified-Since",
    "Max-Forwards",
    "Pragma",
    "Proxy-Authorization",
    "Range",
    "Referer",
    "Upgrade",
    "User-Agent",
    "Via",
    "Warn"
  ],

  autocompleteHeaders: function(el) {
    $(el).autocompleteArray(this.headers, {
      delay: 40,
      onItemSelect: function() {
        $(el).siblings('input').focus()
      }
    })
  }
}

$(document).ready(function() {
  // add auth
  $('#select-auth').change(function() {
    $('#select-auth option:selected').each(function() {
      var auth_type = $(this).attr('id')
      if (auth_type == 'basic'){
        $('#basic-auth-fields').show()
      } else {
        $('#basic-auth-fields').hide()
      }
    })
  })

  // add header
  $('#add-header').click(function() {
    var newField = $('#header-fields').clone()
    newField.toggle().attr('id', '')
    Hurl.autocompleteHeaders( newField.find('.form-alpha') )
    $(this).parent().append( newField )
    return false
  })

  // hurl it!
  $('#hurl-form').submit(function() {
    $('#send-wrap').children().toggle()

    $(this).ajaxSubmit(function(res) {
      var data = JSON.parse(res)

      if (data.error) {
        $('#response').html(data.error)
      } else if (data.header && data.body && data.request) {
        $('#request').html(data.request)
        $('#response').html('<pre>' + data.header + '</pre>' + data.body)
      } else {
        $('#response').html("Weird response. Sorry.")
      }

      $('#send-wrap').children().toggle()
    })

    return false
  })

  // toggle request/response display
  $('.toggle-reqres-link').click(function(){
    $('.toggle-reqres').toggle()
    $('#code-request').toggle()
    $('#code-response').toggle()
    return false
  })
})