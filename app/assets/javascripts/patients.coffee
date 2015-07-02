# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$ ->
  return $('table#patients').dataTable({
    processing: true,
    serverSide: true,
    ajax: $('table#patients').data('source'),
    displayLength: 100,
    columns: [
      {data: '0' },
      {data: '1' },
      {data: '2' }

    ],
    columnDefs: [
      { targets: 0, visible: false }
    ]
  });
