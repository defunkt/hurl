$(document).ready(function() {
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
})