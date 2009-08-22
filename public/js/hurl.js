var Hurl = {}

$(document).ready(function() {
  // add auth
  $('#select-auth').change(function() {
    $('#select-auth option:selected').each(function() {
      var auth_type = $(this).attr('value')
      if (auth_type == 'basic'){
        $('#basic-auth-fields').show()
      } else {
        $('#basic-auth-fields').hide()
      }
    })
  })
  $('#select-auth').change()

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

  // in-field labels
	$('input[title]').each(function() {
		if($(this).val() === '') {
			$(this).val($(this).attr('title')).css('color', '#E9EAEA')
		}
		$(this).focus(function() {
			if($(this).val() === $(this).attr('title')) {
				$(this).val('').addClass('focused').css('color', '#333')
			}
		})
		$(this).blur(function() {
			if($(this).val() === '') {
				$(this).val($(this).attr('title')).removeClass('focused').css('color', '#E9EAEA')
			}
		})
	})
})