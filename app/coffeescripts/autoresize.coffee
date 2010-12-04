# Typing on textareas will resize the box to fit the text, but not outside the viewport

Element.addMethods
  resizeToText: (area, force) ->
    area = $(area)
    if (area.scrollHeight > area.clientHeight)
      wanted = area.getHeight() + (area.scrollHeight - area.clientHeight) + 15
      available = document.viewport.getHeight() - area.viewportOffset().top - 60
      
      possible = if force then wanted else Math.min(wanted, available)
      area.setStyle height: possible + 'px'

resizeLimited = Element.resizeToText.debounce(100)

document.on 'keyup', 'textarea', (e, area) ->
  if e.keyCode == Event.KEY_RETURN
    Element.resizeToText.defer(area, false)
  else
    resizeLimited(area, false)

document.on 'facebox:opened', ->
  $$('.facebox-content textarea').each (element) ->
    element.resizeToText(false)
