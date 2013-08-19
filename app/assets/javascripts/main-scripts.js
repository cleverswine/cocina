/* Author:
Kevin Noone
*/
$(document).ready(function () {

    // enable cool stuff
    $('.dropdown-toggle').dropdown();
    $('.recipe-actions > a').tooltip()
    
    // index - drag and drop recipe -> category/tag
    $('.draggable_recipe_category').draggable({ cursor: 'move', opacity: 0.4, revert: true, helper: 'clone' }); 
    $('.left_nav_category').droppable( { drop: handleDropEvent, accept: '.draggable_recipe_category', hoverClass: 'active' });    
    
    function handleDropEvent( event, ui ) {
        var recipe = ui.draggable;
        var cat = $(this);
        var recipe_id = recipe.data('id');
        var recipe_cat_id = recipe.data('catid');
        var cat_id = cat.data('id');
        var cat_tag = cat.data('tag');
        
        // dropped into category, already in this category
        if((recipe_cat_id == cat_id) && cat_tag == ''){ 
            recipe.draggable( 'option', 'revert', true );
            return; 
        }                
        // keep it from jumping back
        recipe.draggable( 'option', 'revert', false );        
        // ajax - update recipe with cat id and tag...        
        $.ajax({
          type: 'POST',
          url: '/recipes/' + recipe_id + '/move?cat_id=' + cat_id + '&tag=' + cat_tag,
          success: function(data){                   
            if(recipe_cat_id != cat_id){
                // if the recipe doesn't belong in the current list anymore, just remove it  
                $('#recipe-list-row-' + recipe_id).hide();
            }  
            else {
                // replace with updated recipe
                $('#recipe-list-row-' + recipe_id).replaceWith(data);                
                // we have to make the title draggable again since it's new content
                $('.draggable_recipe_category').draggable({ cursor: 'move', opacity: 0.4, revert: true, helper: 'clone' }); 
                // re-enable action buttons on hover
                $('#recipe-list-row-' + recipe_id).hover( 
                    function(){ $('#recipe_actions_' + recipe_id).show(); },
                    function(){ $('#recipe_actions_' + recipe_id).hide(); }            
                );
            }
          },
          error: function(){ alert("Oops, that didn't work..."); }
        });            

        // update count in left nav...
        $.ajax({
          type: 'GET',
          url: '/recipes/cats',
          success: function(data){
            $('#left_nav_cats').html(data);
            // make it droppable again...
            $('.left_nav_category').droppable( { drop: handleDropEvent, accept: '.draggable_recipe_category', hoverClass: 'active' });    
          }
        });
    }
  
    // index - shows action buttons on hover
    $('#recipe-list tr').hover(
        function(){         
            var id_parts = this.id.split('-');
            var id = id_parts[id_parts.length - 1];
            $('#recipe_actions_' + id).show();        
        },
        function(){         
            var id_parts = this.id.split('-');
            var id = id_parts[id_parts.length - 1];
            $('#recipe_actions_' + id).hide();        
        }
    );
    
    // helper to get id from end of dom id (ex something_21)
    function get_id(str, delim){
        var id_parts = str.split(delim);
        return id_parts[id_parts.length - 1];    
    }
    
    // global search autocomplete (in nav)
    $("input#globalterm").autocomplete({
        source: '/recipes/search_title',
        minLength: 2, delay: 500, autoFocus: false,
        select: function(event, ui) { 
            $("#search_form_global").val(ui.item.label);
            $("#search_form_global").submit(); }    
    });
    
    // sort dropdown (on list view)
    $("#sort").change(function(){
        $("#search_form").submit();
    });    
    
    // remove recipe (from list view)
    $('.delete-button').click(function(){
        if(confirm('Are you sure?')){
            var id = $(this).attr('id').split('_')[1];
            
            var success = function()
                { $('#recipe-list-row-' + id).hide('explode', {}, 800); };
            var error = function()
                { alert("Oops, the recipe couldn't be removed. \nPlease try again."); };
            
            $.ajax({
              type: 'DELETE',
              url: '/recipes/' + id + '.json',
              success: success,
              error: error
            });
        }
    });
    
    // New recipe import dialog
    $('#new-recipe-import').dialog({ autoOpen: false, width: 500 })
    $('#import_nav_btn').click(function(){ $('#new-recipe-import').dialog('open'); });
    
    $('#recipe_from_url').click(function(){
        window.location.href = '?url=' + encodeURI($('#recipe_from_url_url').val());
        return false;
    });
    
    // Recipe details thumbnail gallery
    $('.thumb-link').click(function() {
        newsrc = $(this).attr("rel");
        $('#bigimage').attr('src', newsrc);
        return false;
    });    
    
    // star rating
    $('.star').raty({
        path: "/assets/",
        starOn:   'star-on.png',
        starOff:  'star-off.png',
        space: false,
        start: function() {
            return $(this).attr('data-rating');
        },
        click: function(score, evt) {
            var id = $(this).attr('id').split('_')[1];
            $.post('/recipes/' + id + '/rate', {rating: score})
                .error(function() { alert("Oops, the rating couldn't be updated. \nPlease try again."); });
        }
    });    

    // category drag/drop reorder
    $('#admin-categories-list').sortable({
      axis: 'y',
      dropOnEmpty: false,
      handle: '.handle',
      cursor: 'crosshair',
      items: 'li',
      opacity: 0.4,
      scroll: true,
      update: function(){
        $.ajax({
          type: 'post',
          data: $('#admin-categories-list').sortable('serialize'),
          dataType: 'script',
          complete: function(request){
            $('#admin-categories-list').effect('highlight');
          },
          url: '/admin/categories/reorder'
        })
      }
    });
    
    // scarfer import dialog
    $('#admin-scarfer-import').dialog({ autoOpen: false, width: 500 })
    $('#admin-scarfer-import-btn').click(function(){ $('#admin-scarfer-import').dialog('open'); });
    
    // scarfer Test buttons
    $('#admin-scarfer-testresults').dialog({ autoOpen: false })
    
    $('.test-btn').click(function(){    
      $('#admin-scarfer-testresults-val').text("Loading test results. Please wait..."); 
      $('#admin-scarfer-testresults').dialog('open');
      
      var section = this.id;
      var postdata = { jsonstr: $('#scarfer_' + section).val(), url: $('#testurl').val() }
      
      $.ajax({
        type: 'POST',
        url: '<%=dotest_admin_scarfers_path%>',
        data: $.param(postdata),
        error : function() { alert("error"); },
        dataType: 'text'
      }).done(function ( data ) { 
          $('#admin-scarfer-testresults-val').text(data); 
        });  
      
      return false;
    });   
    
});



