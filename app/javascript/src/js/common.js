$(document).on('turbolinks:load', function (){
    $(".clickable-row").click(function() {
        window.location = $(this).data("href");
    });

    $('.help-sign').click(function() {
        $(this).next().toggleClass('d-none');
    });
});