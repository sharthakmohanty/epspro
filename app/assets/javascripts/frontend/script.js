function include(scriptUrl) {
    document.write('<script src="' + scriptUrl + '"></script>');
}

function isIE() {
    var myNav = navigator.userAgent.toLowerCase();
    return (myNav.indexOf('msie') != -1) ? parseInt(myNav.split('msie')[1]) : false;
};

/* cookie.JS
 ========================================================*/
include('/assets/frontend/jquery.cookie.js');

/* Easing library
 ========================================================*/
include('/assets/frontend/jquery.easing.1.3.js');

/* PointerEvents
 ========================================================*/
;
(function ($) {
    if (isIE() && isIE() < 11) {
        include('/assets/frontend/pointer-events.js');
        $('html').addClass('lt-ie11');
        $(document).ready(function () {
            PointerEventsPolyfill.initialize({});
        });
    }
})(jQuery);

/* Stick up menus
 ========================================================*/
;
(function ($) {
    var o = $('html');
    if (o.hasClass('desktop')) {
        include('/assets/frontend/tmstickup.js');

        $(document).ready(function () {
            $('#stuck_container').TMStickUp({})
        });
    }
})(jQuery);

/* ToTop
 ========================================================*/
;
(function ($) {
    var o = $('html');
    if (o.hasClass('desktop')) {
        include('/assets/frontend/jquery.ui.totop.js');

        $(document).ready(function () {
            $().UItoTop({
                easingType: 'easeOutQuart',
                containerClass: 'toTop fa fa-angle-up'
            });
        });
    }
})(jQuery);

/* EqualHeights
 ========================================================*/
;
(function ($) {
    var o = $('[data-equal-group]');
    if (o.length > 0) {
        include('/assets/frontend/jquery.equalheights.js');
    }
})(jQuery);

/* RD Smoothscroll
 =============================================*/
;
(function ($) {
    include('/assets/frontend/rd-smoothscroll.min.js');
})(jQuery);

/* Copyright Year
 ========================================================*/
;
(function ($) {
    var currentYear = (new Date).getFullYear();
    $(document).ready(function () {
        $("#copyright-year").text((new Date).getFullYear());
    });
})(jQuery);


/* Superfish menus
 ========================================================*/
;
(function ($) {
    include('/assets/frontend/superfish.js');
})(jQuery);

/* Navbar
 ========================================================*/
;
(function ($) {
    include('/assets/frontend/jquery.rd-navbar.js');
})(jQuery);


/* Google Map
 ========================================================*/
;
(function ($) {
    var o = document.getElementById("google-map");
    if (o) {
        include('//maps.google.com/maps/api/js?sensor=false');
        include('/assets/frontend/jquery.rd-google-map.js');

        $(document).ready(function () {
            var o = $('#google-map');
            if (o.length > 0) {
                o.googleMap({
                    styles: [{
                        "featureType": "landscape",
                        "stylers": [{"saturation": -100}, {"lightness": 65}, {"visibility": "on"}]
                    }, {
                        "featureType": "poi",
                        "stylers": [{"saturation": -100}, {"lightness": 51}, {"visibility": "simplified"}]
                    }, {
                        "featureType": "road.highway",
                        "stylers": [{"saturation": -100}, {"visibility": "simplified"}]
                    }, {
                        "featureType": "road.arterial",
                        "stylers": [{"saturation": -100}, {"lightness": 30}, {"visibility": "on"}]
                    }, {
                        "featureType": "road.local",
                        "stylers": [{"saturation": -100}, {"lightness": 40}, {"visibility": "on"}]
                    }, {
                        "featureType": "transit",
                        "stylers": [{"saturation": -100}, {"visibility": "simplified"}]
                    }, {
                        "featureType": "administrative.province",
                        "stylers": [{"visibility": "off"}]
                    }, {
                        "featureType": "water",
                        "elementType": "labels",
                        "stylers": [{"visibility": "on"}, {"lightness": -25}, {"saturation": -100}]
                    }, {
                        "featureType": "water",
                        "elementType": "geometry",
                        "stylers": [{"hue": "#ffff00"}, {"lightness": -25}, {"saturation": -97}]
                    }]
                });
            }
        });
    }
})
(jQuery);

/* WOW
 ========================================================*/
;
(function ($) {
    var o = $('html');

    if ((navigator.userAgent.toLowerCase().indexOf('msie') == -1 ) || (isIE() && isIE() > 9)) {
        if (o.hasClass('desktop')) {
            include('/assets/frontend/wow.js');

            $(document).ready(function () {
                new WOW().init();
            });
        }
    }
})(jQuery);

/* Mailform
 =============================================*/
;(function ($) {
    var o = $('.mailform');
    if (o.length > 0) {
        include('/assets/frontend/mailform/jquery.form.min.js');
        include('/assets/frontend/mailform/jquery.rd-mailform.min.js');

        $(document).ready(function () {
            var o = $('.mailform');

            if (o.length) {
                o.rdMailForm({
                    validator: {
                        'constraints': {
                            '@LettersOnly': {
                                message: 'Please use letters only!'
                            },
                            '@NumbersOnly': {
                                message: 'Please use numbers only!'
                            },
                            '@NotEmpty': {
                                message: 'Field should not be empty!'
                            },
                            '@Email': {
                                message: 'Enter valid e-mail address!'
                            },
                            '@Phone': {
                                message: 'Enter valid phone number!'
                            },
                            '@Date': {
                                message: 'Use MM/DD/YYYY format!'
                            },
                            '@SelectRequired': {
                                message: 'Please choose an option!'
                            }
                        }
                    }
                }, {
                    'MF000': 'Sent',
                    'MF001': 'Recipients are not set!',
                    'MF002': 'Form will not work locally!',
                    'MF003': 'Please, define email field in your form!',
                    'MF004': 'Please, define type of your form!',
                    'MF254': 'Something went wrong with PHPMailer!',
                    'MF255': 'There was an error submitting the form!'
                });
            }
        });
    }
})(jQuery);

/* Orientation tablet fix
 ========================================================*/
$(function () {
    // IPad/IPhone
    var viewportmeta = document.querySelector && document.querySelector('meta[name="viewport"]'),
        ua = navigator.userAgent,

        gestureStart = function () {
            viewportmeta.content = "width=device-width, minimum-scale=0.25, maximum-scale=1.6, initial-scale=1.0";
        },

        scaleFix = function () {
            if (viewportmeta && /iPhone|iPad/.test(ua) && !/Opera Mini/.test(ua)) {
                viewportmeta.content = "width=device-width, minimum-scale=1.0, maximum-scale=1.0";
                document.addEventListener("gesturestart", gestureStart, false);
            }
        };

    scaleFix();
    // Menu Android
    if (window.orientation != undefined) {
        var regM = /ipod|ipad|iphone/gi,
            result = ua.match(regM);
        if (!result) {
            $('.sf-menus li').each(function () {
                if ($(">ul", this)[0]) {
                    $(">a", this).toggle(
                        function () {
                            return false;
                        },
                        function () {
                            window.location.href = $(this).attr("href");
                        }
                    );
                }
            })
        }
    }
});
var ua = navigator.userAgent.toLocaleLowerCase(),
    regV = /ipod|ipad|iphone/gi,
    result = ua.match(regV),
    userScale = "";
if (!result) {
    userScale = ",user-scalable=0"
}
document.write('<meta name="viewport" content="width=device-width,initial-scale=1.0' + userScale + '">');
/* Camera
 ========================================================*/
;
(function ($) {
    var o = $('#camera');
    if (o.length > 0) {
        if (!(isIE() && (isIE() > 9))) {
            include('/assets/frontend/jquery.mobile.customized.min.js');
        }

        include('/assets/frontend/camera.js');

        $(document).ready(function () {
            o.camera({
                autoAdvance: true,
                height: '46%',
                minHeight: '300px',
                pagination: false,
                thumbnails: false,
                playPause: false,
                hover: false,
                loader: 'none',
                navigation: true,
                navigationHover: false,
                mobileNavHover: false,
                fx: 'simpleFade'
            })
        });
    }
})(jQuery);



/* Owl Carousel
 ========================================================*/
;
(function ($) {
    var o = $('.owl-carousel');
    if (o.length > 0) {
        include('/assets/frontend/owl.carousel.min.js');
        $(document).ready(function () {
            o.owlCarousel({
                items: 1,
                smartSpeed: 450,
                loop: true,
                dots: true,
                dotsEach: 1,
                nav: false,
                navClass: ['owl-prev fa fa-angle-left', 'owl-next fa fa-angle-right'],

            });
        });
    }
})(jQuery);


/* Search.js
 ========================================================*/
;
(function ($) {
    var o = $('.search-form');
    if (o.length > 0) {
        include('/assets/frontend/TMSearch.js');
    }
})(jQuery);
/* Parallax
 =============================================*/
;
(function ($) {
    include('/assets/frontend/jquery.rd-parallax.js');
})(jQuery);