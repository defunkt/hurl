var Hurl = {
  // apply label hints to inputs based on their
  // title attribute
  labelHints: function(el) {
    $(el).each(function() {
      var self = $(this), title = self.attr('title')

		  if (self.val() === '' || self.val() === title) {
			  self.val(title).css('color', '#E9EAEA')
		  }

		  self.focus(function() {
			  if (self.val() === title) {
				  self.val('').addClass('focused').css('color', '#333')
			  }
		  })

		  self.blur(function() {
			  if (self.val() === '') {
				  self.val(title).removeClass('focused').css('color', '#E9EAEA')
			  }
		  })
    })
  }
}

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
    Hurl.labelHints( newField.find('input[title]') )
    registerRemoveHeaderHandlers( newField )
    $(this).parent().append( newField )
    return false
  })

  // remove header
  function registerRemoveHeaderHandlers(el) {
    $(el).find('.header-delete').click(function() {
      $(this).parents('p:first').remove()
      return false
    })
  }

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

      $('#request-and-response').show()
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
	Hurl.labelHints('input[title]')
})