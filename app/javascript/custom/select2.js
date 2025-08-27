import "jquery"
import "select2"

document.addEventListener('turbo:load', function() {
  $('.select2').select2({
    allowClear: true,
    width: '100%'
  });
});

document.addEventListener('turbo:before-cache', function() {
  $('.select2').select2('destroy');
});
