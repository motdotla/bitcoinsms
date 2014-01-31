/* DO NOT MODIFY. This file was compiled Sat, 18 Jun 2011 22:32:21 GMT from
 * /Users/scottmotte/code/sinatra/bitcoinsms/app/javascripts/application/users/show.coffee
 */

(function() {
  window.UsersShow = {
    init: function() {
      return this.clickDeleteRule();
    },
    clickDeleteRule: function() {
      return $("#users_show").delegate("a.delete_rule", 'click', function() {
        var $a, $li;
        $a = $(this);
        $li = $a.parent('li');
        if (confirm("Are you sure you want to delete this?")) {
          $li.remove();
          $.ajax({
            type: "DELETE",
            url: $a.attr('href'),
            dataType: "json",
            error: function() {
              return alert('There was an error deleting from the server.');
            },
            success: function(data, textstatus, XMLHTTPRequest) {}
          });
        }
        return false;
      });
    }
  };
  window.UsersShow.init();
}).call(this);
