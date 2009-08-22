$(document).ready(function() {
  $('#hurl-form').submit(function() {
    $('#send-wrap').children().toggle()
    
    $(this).ajaxSubmit(function(body) {
      $('#response').html(body)
      $('#send-wrap').children().toggle()
    })

    return false
  })
})