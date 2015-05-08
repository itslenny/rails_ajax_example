$(function(){

  //clear modal when it's hidden.
  $('#myModal').on('hidden.bs.modal', function() {
      $(this).removeData('bs.modal');
  });

  $('#myModal').on('submit','form',function(e){
    e.preventDefault();
    var form = $(this);
    $.ajax({
      url:form.attr('action'),
      method:form.attr('method'),
      data:form.serialize()
    }).done(function(data){
      $('.tasks-list tbody').html(data);
      $('#myModal').modal('hide')
      // console.log(data);
    }).error(function(err){
      alert('something broke.');
      console.log(err);
    })
  })

  $('.tasks-list tbody').on('click','.ajax-task-sort',function(e){
    e.preventDefault();
    var btn = $(this);
    $.ajax({
      url: btn.attr('href'),
      method: 'PATCH'
    }).done(function(data){
      $('.tasks-list tbody').html(data);
      console.log(data);
    }).error(function(err){
      alert('something broke.');
      console.log(err);
    })
  });

  $('.tasks-list tbody').on('click','.ajax-task-delete',function(e){
    var btn = $(this);
    e.preventDefault();
    $.ajax({
      url: btn.attr('href'),
      method:'DELETE',
      dataType:'json'
    }).done(function(data){
      console.log(data);
      btn.closest('tr').remove();
    }).error(function(err){
      console.log(err);
      alert('Unable to delete item.')
    })
  })

})