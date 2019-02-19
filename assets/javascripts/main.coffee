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
