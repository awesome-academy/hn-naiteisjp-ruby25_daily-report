function setupAvatarUpload() {
  $('.js-avatar-upload').on('change', function() {
    $(this).closest('form').submit();
  });
}

$(document).on('turbo:load', function () {
  setupAvatarUpload();
});
