$(function() {
    $(".preload").fadeOut(2000, function() {
        $(".content").fadeIn(1000);
    });
});

window.onload = function(){
  $(function() {
    $(".preload").fadeOut();
    $(".content").fadeIn();
  });
}