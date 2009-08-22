$(document).ready(function() {
  $('#hurl-form').ajaxForm(function(body) {
    $('#response').text(body)
  })
})