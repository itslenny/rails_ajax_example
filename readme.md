#AJAX in rails

##Option 1 - JSON

One option for ajax is to have the target route respond with json data and then manually update the DOM based on that data.

####frontend javascript

In javascript we need to listen for a click event, prevent the default action, and then make a call to the server with the `dataType` set to json to tell the server that we expect json data.

```javascript
$('.tasks-list tbody').on('click','.ajax-task-delete',function(e){
  var btn = $(this);
  e.preventDefault();
  
  //ajax call
  $.ajax({
    url: btn.attr('href'),
    method:'DELETE',
    dataType:'json'
  }).done(function(data){
    console.log(data);
    //on success update the DOM
    btn.closest('tr').remove();
  }).error(function(err){
    console.log(err);
    alert('Unable to delete item.')
  })
  
})
```

####controller

In the controller we need to set up the action to respond to requests for json data using the `respond_to` method.

```ruby
def destroy
  result = Task.destroy params[:id]
  respond_to do |format|
    format.html {redirect_to :tasks}
    format.json {render json: result}
  end
end
```

##Option 2 - HTML

Often it makes more sense to just have the server pass back HTML content instead of JSON. This content is generally a partial or at the very least a view file with the layout disabled. If this is done correctly we can easily inject this HTML in to the existing page with a single line of javascript.



####controller

In the controller we render a partial that IS the updated list of tasks.

####Using partial in index.html.erb

```html
<table class="table tasks-list">
  <tbody>
    <%= render partial: 'tasks' %>
  </tbody>
</table>
```

####Tasks partial

This partial contains the loop that displays all of the table rows. We can use this partial for both the inital index page AND the update ajax action.

```html
<% @tasks.each do |t| %>
  <tr>
    <td><%= t.sort %></td>
    <td><%= t.title %></td>
    <td><%= link_to '<i class="glyphicon glyphicon-pencil"></i>'.html_safe, edit_task_path(t), :data=>{toggle:'modal',target:'#myModal'} %></td>
    <td><%= link_to '<i class="glyphicon glyphicon-trash"></i>'.html_safe, t, :class=>'ajax-task-delete' %></td>
    <td><%= link_to '<i class="glyphicon glyphicon-arrow-up"></i>'.html_safe, sort_up_task_path(t), :class=>'ajax-task-sort' %></td>
    <td><%= link_to '<i class="glyphicon glyphicon-arrow-down"></i>'.html_safe, sort_down_task_path(t), :class=>'ajax-task-sort' %></td>
  </tr>
<% end %>
```

####Controller

The update action needs to render JUST the table body contents (the partial we already created). This allows us to use AJAX to swap out the table contents.

```ruby
def update
  Task.update params[:id], title: params[:task][:title]
  # redirect_to :tasks
  @tasks = Task.all.order(sort: :asc)
  render partial: 'tasks'
end
```

####Frontend Javascript

For the javascript we need to catch the submit action of a form (and prevent default) then make an ajax call using the data stored in the form. Because of the configuration done in the controller we will get a response in the form of an updated table body which we can simply inject into the page.

```javascript
$.ajax({
  url:form.attr('action'),
  method:form.attr('method'),
  data:form.serialize()
}).done(function(data){
  //update dom
  $('.tasks-list tbody').html(data);
  // console.log(data);
}).error(function(err){
  alert('something broke.');
  console.log(err);
})
```

##Option 3 - The rails way

There is also a "rails way™" to do this and it's fairly simple, but tends to be too limiting for real-world situations. If you'd like to learn more about this method you can read these resources

* [http://www.alfajango.com/blog/rails-3-remote-links-and-forms/](http://www.alfajango.com/blog/rails-3-remote-links-and-forms/)
* [http://edgeguides.rubyonrails.org/working_with_javascript_in_rails.html](http://edgeguides.rubyonrails.org/working_with_javascript_in_rails.html)

##modals, Modals, MODALS!!!

Basic modals with bootstrap are extremely simple to get started you can simply copy an example from the [Bootstrap docs](http://getbootstrap.com/javascript/#modals-examples) and it should work.

####Simple modal example

```
<!-- Button trigger modal -->
<button type="button" class="btn btn-primary btn-lg" data-toggle="modal" data-target="#myModal">
  Launch demo modal
</button>

<!-- Modal -->
<div class="modal fade" id="myModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
  ... get additional html from the bootstrap link above ...
</div>
```

**The parts that make this function are**

* in the link / button
    * `data-toggle="modal"` - This tells bootstrap that the link should open a modal
    * `data-target="#myModal"` - this points to the id of the modal that the link should show (remember the '#' css selector)
* in the actual modal
    * `class="modal"` - This sets the styling for the modal AND makes it hidden when the page loads (until you click the link to show it).
    * `id="myModal` - This must match the `data-target` value in the link / button that will show this modal.


####Load modal content via AJAX

It's often useful / better to load modal content via AJAX. This is a built in feature of bootstrap. To make this work you need to use an `<a>` tag instead of a `<button>` tag and set the `href` property to the URL you want loaded in to the modal.

```
#rails link_to helper:
<%= link_to '<i class="glyphicon glyphicon-plus"></i>'.html_safe,new_task_path, :class=>'btn btn-success pull-right', :data=>{toggle:'modal',target:'#myModal'} %>

#resulting html:
<a href="/tasks/new" class="btn btn-success pull-right" data-toggle="modal" data-target="#myModal"><i class="glyphicon glyphicon-plus"></i></a>
```


####Loading modal content from rails

If you go to a route within rails the page is automatically wrapped in the `layouts/application.html.erb` contents. This will not work for loading modal content because it will include the html, head, body, container, etc. Luckily, removing the layout in rails is very simple.

**tasks_controller.rb**
```ruby
def edit
  @task = Task.find_by_id params[:id]
  render layout: false
end
```

Then in our view (edit.html.erb) we put the whole HTML contents of the modal. To allow the buttons to be in the footer we need to wrap the whole modal in the `bootstrap_form_for` tag.

**tasks/edit.html.erb**

```html
<%= bootstrap_form_for @task do |f| %>
  <div class="modal-header">
    <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
    <h4 class="modal-title" id="myModalLabel">Modal title</h4>
  </div>
  <div class="modal-body">
    <%= f.text_field :title %>
  </div>
  <div class="modal-footer">
    <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
    <%= f.primary %>
  </div>
<% end %>
```

####Catching modal form events

The form in the modal is just a normal so when it is submitted it will navigate to the route specified in the action/method attributes of the form tag (not via AJAX). To convert it to fully ajax (no page refresh) we need to catch the form submit event, but the form doesn't exist when the page loads so we have to use event bubbling to listen for the submit event on something higher up in the DOM hierarchy. In this case we can just listen to the actual modal itself.

```javascript
$('#myModal').on('submit','form',function(e){
  e.preventDefault();
  var form = $(this);
  $.ajax({
    url:form.attr('action'),
    method:form.attr('method'),
    data:form.serialize()
  }).done(function(data){
    //populate the html content
    $('.tasks-list tbody').html(data);
    //hide the modal
    $('#myModal').modal('hide')
    // console.log(data);
  }).error(function(err){
    alert('something broke.');
    console.log(err);
  })
})
```

The first line in the above code listens for the `submit` event on the `#myModal` div. Using the parameter `form` in the event listener makes it only fire if the event originates from something matching that selector (this could also be a specific class or any css selector) AND makes `$(this)` point to the form tag that originated the event instead of the `#myModal` div.

After that we're just doing an ajax request to the server with the form data. In this example the route is responding with html so we're just injecting it into the DOM directly. Then calling `.modal('hide')` on the modal to dismiss it.

####Sending html partial (again)

The route this points to uses the exact same method as we used above to render just the HTML content for the table body.

To do this we're replacing the `redirect_to` with a `render` and passing in a partial (because it's a partial it has no layout by default).

```ruby
def update
  Task.update params[:id], title: params[:task][:title]
  # redirect_to :tasks
  @tasks = Task.all.order(sort: :asc)
  render partial: 'tasks'
end
```
