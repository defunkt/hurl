var Hurl = {
  // apply label hints to inputs based on their
  // title attribute
  labelHints: function(el) {
    $(el).each(function() {
      var self = $(this), title = self.attr('title')

      // indicate inputs using defaults
      self.addClass('defaulted')

		  if (self.val() === '' || self.val() === title) {
			  self.val(title).css('color', '#E9EAEA')
		  } else {
				self.addClass('focused')
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
  },

  removeEmptyData: function(data) {
    var keepers = [], value

    // remove empty arrays and any default titular data
    for (key in data) {
      if (value = data[key].value) {
        if ($('input[name=' + data[key].name +'].defaulted:not(.focused)').val() != value) {
          keepers.push(data[key])
        }
      }
    }

    data.splice(0, data.length)

    for (key in keepers)
      data.push( keepers[key] )

    return true
  },

  pony: function() {
    if (!this.ponyLoaded) return this.loadPony()
    if (this.ponying) return
    this.ponying = true

    var width = 668

    var pony = $("<div />").css({
      width:       width,
      height:      422,
      background: 'url(/img/pony.png) top center',
      position:   'fixed',
      bottom:     0,
      right:      0-width,
      "z-index":  1000,
      cursor:     'pointer'
    }).appendTo($("body"))

    pony.show().animate({right: 0}, 1500, function() {
      setTimeout(function() {
        pony.css('background', 'url(/img/pony-hurl.png) top center')
        setTimeout(function() {
          pony.animate({right: 0-width}, 1500, function() {
            Hurl.ponying = false
          })
        }, 500)
      }, 1000)
    })
  },

  loadPony: function() {
    $(new Image()).load(function() {
      Hurl.loadOtherPony()
    }).attr('src', '/img/pony.png');
  },

  loadOtherPony: function() {
    $(new Image()).load(function() {
      Hurl.ponyLoaded = true
      Hurl.pony()
    }).attr('src', '/img/pony-hurl.png');
  }
}

$.fn.hurlAjaxSubmit = function(callback) {
  return $(this).ajaxSubmit({
    beforeSubmit: Hurl.removeEmptyData,
    success: callback
  })
}

$(document).ready(function() {
  // select method
  $('#select-method').change(function() {
    $('#select-method option:selected').each(function() {
      var method = $(this).attr('value')
      if (method == 'POST' || method == 'PUT'){
        $('#post-params').show()
      } else {
        $('#post-params').hide()
      }
    })
  })
  $('#select-method').change()

  // add auth
  $('input[name=auth]').change(function() {
    if ($(this).attr('value') == 'basic') {
      $('#basic-auth-fields').show()
      $('#basic-auth-fields .form-alpha').focus()
    } else {
      $('#basic-auth-fields').hide()
    }
  })
  $('#auth-selection :checked').change()

  // add post param
  $('#add-param').click(function() {
    // toggle if post body is being shown
    if ( $('#set-post-body .link-icon').text() == '-' ) {
      $('#set-post-body').click()
      return false
    }

    var newField = $('#param-fields').clone()
    newField.toggle().attr('id', '')
    newField.addClass('param-field')
    newField.find('.form-alpha').attr('title', 'name')
    newField.find('.form-beta').attr('title', 'value')
    Hurl.labelHints( newField.find('input[title]') )
    registerRemoveHandlers( newField, '.param-delete' )
    $(this).parent().append( newField )
    return false
  })

  // set post body
  $('#set-post-body').click(function() {
    var icon = $(this).find('.link-icon')

    if ( icon.text() == '+' ) {
      icon.text('-')
      $('.param-field').hide()
      $('#post-body').show().find('textarea').attr('disabled', false)
    } else {
      icon.text('+')
      $('.param-field').show()
      $('#post-body').hide().find('textarea').attr('disabled', true)
    }

    return false
  })

  if ( $('#post-body').is(':visible') ) {
    $('#set-post-body').click()
  }

  // add header
  $('#add-header').click(function() {
    var newField = $('#header-fields').clone()
    newField.toggle().attr('id', '')
    newField.find('.form-alpha').hurlHeaders()
    newField.find('.form-alpha').attr('title', 'name')
    newField.find('.form-beta').attr('title', 'value')
    Hurl.labelHints( newField.find('input[title]') )
    registerRemoveHandlers( newField, '.header-delete' )
    $(this).parent().append( newField )
    return false
  })

  // remove header / param
  function registerRemoveHandlers(el, klass) {
    $(el).find(klass).click(function() {
      $(this).parents('p:first').remove()
      return false
    })
  }

  registerRemoveHandlers( document, '.header-delete' )
  registerRemoveHandlers( document, '.param-delete' )

  // hurl it!
  $('#hurl-form').submit(function() {
    $('#send-wrap').children().toggle()
    $('.flash-error, .flash-notice').fadeOut()
    $('#request-and-response').hide()

    $(this).hurlAjaxSubmit(function(res) {
      var data = JSON.parse(res)

      if (data.error) {
        $('#flash-error-msg').html(data.error)
        $('.flash-error').show()
      } else if (/hurl/.test(location.pathname) && data.hurl_id && data.view_id) {
        window.location = '/hurls/' + data.hurl_id + '/' + data.view_id
      } else if (data.header && data.body && data.request) {
        if ( /railsrumble/.test($('input[name=url]').val()) ) Hurl.pony()
        if (data.prev_hurl) {
          $('#page-prev').attr('href', '/hurls/' + data.prev_hurl).show()
          $('#page-next').attr('href', '/').show()
        }
        $('.permalink').attr('href', '/hurls/'+data.hurl_id+'/'+data.view_id)
        $('.full-size-link').attr('href', '/views/' + data.view_id)
        $('#request').html(data.request)
        $('#response').html('<pre>' + data.header + '</pre>' + data.body)
        $('.help-blurb').hide()
        $('#request-and-response').show()
      } else {
        $('#flash-error-msg').html("Weird response. Sorry.")
        $('.flash-error').show()
      }

      $('#send-wrap').children().toggle()
    })

    return false
  })

  // delete hurl
  $('.hurl-delete').click(function() {
    $(this).parents('tr:first').remove()
    $.ajax({type: 'DELETE', url: $(this).attr('href')})
    return false
  })

  // toggle request/response display
  $('.toggle-reqres-link').click(function(){
    $('.toggle-reqres').toggle()
    $('#code-request').toggle()
    $('#code-response').toggle()
    return false
  })

  // flash close
  $('.flash-close').click(function (){
    $(this).parent().fadeOut()
    return false
  })

  // facebox
  $('a[rel*=facebox]').facebox({ opacity: 0.4 })
  $(document).bind('reveal.facebox', function() {
    Hurl.labelHints('#facebox input[title]')
    $('#facebox .footer').remove()
  })

  // in-field labels
	Hurl.labelHints('input[title]')

  // relatize dates
  $('.relatize').relatizeDate()
});
