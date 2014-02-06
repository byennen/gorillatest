$ ->
  if $("ul.project").length == 0
    $("#add-project").modal("show")

  if $(".verify-script").length == 1
    $(".view-embed-code").trigger("click")


  $(".verify-script-modal-button").on "click", (e)->
    e.preventDefault()
    button = $(this)
    gif = button.prev(".loading-gif")
    button.hide()
    gif.show()
    $.ajax "#{window.apiUrl + $(this).attr("href")}",
      type: 'get'
      cache: false
      complete: (jqXHR, textStatus) ->
        if jqXHR.status == 200
          $(gif).hide()
          $(button).show()
          $(button).text("Verified!")
          setTimeout (->
            window.location.href = window.location.origin + $(button).attr('href')
            return
          ), 500
        else
          error = $.parseJSON(jqXHR.responseText).message
          $(gif).hide()
          $(button).show()
          $(button).text(error + " Click to try again.")
        return
