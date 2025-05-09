var edupress = edupress || {},
  $ = jQuery;

/** Global Variables */

var $edupressDocument = $(document);

/** Activate primary menu toggles */

edupress.headerMenuToggles = {
  init: function () {
    $(".site-toggle-anchor").click(function () {
      $("#site-mobile-menu").toggleClass("is-visible");
      $(".site-toggle-anchor").toggleClass("is-visible");
      $(".site-toggle-label").toggleClass("is-visible");
      $(".site-toggle-icon").toggleClass("is-visible");
    });

    $(".sub-menu-toggle").click(function () {
      $(this).next().toggleClass("is-visible");
      $(this).toggleClass("is-visible");
    });
  },
}; // edupress.headerMenuToggles

/** Activate superfish menu */

edupress.menuSuperfish = {
  init: function () {
    $(".sf-menu").superfish({
      speed: "fast",
      delay: 0,
      animation: {
        height: "show",
      },
    });
  },
}; // menuSuperfish

$edupressDocument.ready(function () {
  edupress.menuSuperfish.init();
  edupress.headerMenuToggles.init();
});
