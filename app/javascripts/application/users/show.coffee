window.UsersShow =
  init: ->
    this.clickDeleteRule()
    
  clickDeleteRule: () ->
    $("#users_show").delegate "a.delete_rule", 'click', ->
      $a    = $(this)
      $li   = $a.parent('li')
      if confirm("Are you sure you want to delete this?")
        $li.remove()
        
        $.ajax
          type:     "DELETE"
          url:      $a.attr('href')
          dataType: "json"
          error: () ->
            alert('There was an error deleting from the server.')
          success: (data, textstatus, XMLHTTPRequest) ->
            # window.location.reload()
      return false
    
window.UsersShow.init()