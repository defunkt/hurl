$(document).ready(function() {
  // add header
  $('#add-header').click(function() {
    var newField = $('#header-fields').clone()
    newField.toggle().attr('id', '')
    $(this).after(newField)
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
  $('.toggle-reqres-link').click(function(){
    $('.toggle-reqres').toggle()
    $('#code-request').toggle()
    $('#code-response').toggle()
    return false
  })
})