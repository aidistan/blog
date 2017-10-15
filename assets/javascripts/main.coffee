---
---

$(->
  # Overwrite
  $('table').addClass('am-table am-table-compact')

  # Data attribute: data-am-smooth-scroll
  $('button[data-am-smooth-scroll]')
    .add $('a[data-am-smooth-scroll]')
    .each ->
      if /#/.test($(this).attr('href'))
        $(this).click ->
          target = $($(this).attr('href'))
          $(window).smoothScroll
            position: target.position().top
          false # Stop bubbling

  # Data attribute: data-stretch-full-width
  $('[data-stretch-full-width]')
    .add $('[data-stretch-full]')
    .each ->
      m = - ($(window).width() - $(this).width()) / 2
      $(this).css
        'margin-left':  m
        'margin-right': m
        width: $(window).width()

  # Data attribute: data-stretch-full-height
  $('[data-stretch-full-height]')
    .add $('[data-stretch-full]')
    .each ->
      m = - ($(window).height() - $(this).height()) / 2
      $(this).css
        'margin-left':  m
        'margin-right': m
        height: $(window).height()

  # Component: #feature
  $('#feature img').one 'load', ->
    # Triggers
    $('.feature-opener').click ->
      $('.feature-opener').fadeOut 'fast', -> $('.feature-closer').fadeIn 'slow'
      $('#feature').slideDown 'slow', -> $('#feature span').fadeIn('slow')
    $('.feature-closer').click ->
      $('.feature-closer').fadeOut 'fast', -> $('.feature-opener').fadeIn 'slow'
      $('#feature').slideUp('slow')
      $('#feature span').fadeOut('slow')

    all_ready = false
    $('.feature-trigger').slideDown 'slow', ->
      return all_ready = true unless all_ready # action after all done

      # Foreground
      forefeatureH = $(window).height() / 2
      $('#feature').height(forefeatureH)

      # Autoplay
      #   Make the feature div visible in order to get the feature
      #   image's width & height later
      $('.feature-opener').click()
      image =
        width: $('#feature img').width()
        height: $('#feature img').height()
        src: $('#feature img').attr('src')

      # Background
      backfeatureH = $('#feature~.feature-trigger').offset().top + forefeatureH
      ratio =
        width: $(window).width() / image.width
        height: backfeatureH / image.height
      ratio = if ratio.width > ratio.height then ratio.width else ratio.height
      $('#feature').css 'background-image', "url(#{ image.src })"
      $('#feature').css 'background-size',
        "#{ image.width * ratio }px #{ image.height * ratio }px"
      $(window)
        .scroll ->
          offset = (
            if $('#feature').css('display') == 'none'
            then $('#feature~.feature-trigger') else $('#feature')
          ).offset().top - $(document).scrollTop()
          $('#feature').css 'background-position',
            "50% #{(backfeatureH - image.height*ratio)/2 - offset}px"
        .trigger('scroll')
  $('#feature img').each -> $(this).load() if this.complete

  # Component: #top
  $('#banner').waypoint
    handler: (direction) ->
      if direction == 'down'
        $('#top').fadeIn("slow")
      else
        $('#top').fadeOut("slow")
    offset: '-25%'

  # Component: #toc
  if $('#toc').length > 0
    $('#content h2, #content h3, #content h4, #content h5, #content h6').each ->
      head = $(this)
      item = $('<div class="toc-' + this.tagName + '">' + this.textContent + '</div>')
      item.click ->
        $('#toc-sidebar').offCanvas('close')
        setTimeout ->
          $(window).smoothScroll
            position: head.position().top
        , 300
      $('#toc-sidebar .am-offcanvas-content').append item
)
