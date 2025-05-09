<?php

if ( ! isset( $content_width ) ) $content_width = 780;

/**
 * Define some constats
 */
if( ! defined( 'ILOVEWP_VERSION' ) ) {
	define( 'ILOVEWP_VERSION', '1.7.1' );
}
if( ! defined( 'ILOVEWP_THEME_LITE' ) ) {
	define( 'ILOVEWP_THEME_LITE', true );
}
if( ! defined( 'ILOVEWP_THEME_PRO' ) ) {
	define( 'ILOVEWP_THEME_PRO', false );
}
if( ! defined( 'ILOVEWP_DIR' ) ) {
	define( 'ILOVEWP_DIR', trailingslashit( get_template_directory() ) );
}
if( ! defined( 'ILOVEWP_DIR_URI' ) ) {
	define( 'ILOVEWP_DIR_URI', trailingslashit( get_template_directory_uri() ) );
}

/**
 * EduPress functions and definitions.
 *
 * @link https://codex.wordpress.org/Functions_File_Explained
 *
 * @package EduPress
 */

if ( ! function_exists( 'edupress_setup' ) ) :

function edupress_setup() {

	load_theme_textdomain( 'edupress', get_template_directory() . '/languages' );

	add_theme_support( 'automatic-feed-links' ); 

	add_theme_support( 'title-tag' );

	add_theme_support( 'post-thumbnails' );

	set_post_thumbnail_size( 240, 180, true );
	
	// Featured Post Main Thumbnail on the front page & single page template
	add_image_size( 'edupress-large-thumbnail', 780, 400, true );

	// This theme uses wp_nav_menu() in one location.
	register_nav_menus( array(
		'primary'	=> esc_html__( 'Primary Menu', 'edupress' ),
		'mobile'	=> esc_html__( 'Mobile Menu', 'edupress' )
	) );

	/*
	 * Switch default core markup for search form, comment form, and comments
	 * to output valid HTML5.
	 */
	add_theme_support( 'html5', array(
		'search-form',
		'comment-form',
		'gallery',
		'caption',
	) );

	// Custom background color.
	add_theme_support( 'custom-background', array(
		'default-color'	=> 'f2f0ed'
	) );

    add_theme_support( 'custom-logo', array(
	   'height'      => 50,
	   'width'       => 300,
	   'flex-width'  => true,
	   'flex-height' => true,
	) );

	/* Remove support for Block Based Widgets 
	==================================== */
    remove_theme_support( 'widgets-block-editor' );

	add_theme_support( 'responsive-embeds' );

	/*
	 * This theme styles the visual editor to resemble the theme style,
	 * specifically font, colors, icons, and column width.
	 */
	add_action( 'customize_controls_print_styles', 'edupress_customizer_stylesheet' );

}
endif; // edupress_setup
add_action( 'after_setup_theme', 'edupress_setup' );

add_filter( 'image_size_names_choose', 'edupress_custom_sizes' );
 
function edupress_custom_sizes( $sizes ) {
	return array_merge( $sizes, array(
		'edupress-large-thumbnail' => __( 'EduPress: Slideshow Size (780x400)', 'edupress' ),
		'post-thumbnail' => __( 'EduPress: Thumbnail (240x180)', 'edupress' ),
	) );
}

/* Custom Archives titles.
=================================== */

if ( ! function_exists( 'edupress_get_the_archive_title' ) ) :
	function edupress_get_the_archive_title( $title ) {
	    if ( is_category() ) {
	        $title = single_cat_title( '', false );
	    }

	    return $title;
	}
endif;

add_filter( 'get_the_archive_title', 'edupress_get_the_archive_title' );

/* Custom Excerpt Length
==================================== */

add_filter( 'excerpt_length', 'edupress_new_excerpt_length' );

function edupress_new_excerpt_length( $length ) {
	return is_admin() ? $length : 30;
}

/**
 * Add a pingback url auto-discovery header for singularly identifiable articles.
 */
function edupress_pingback_header() {
	if ( is_singular() && pings_open() ) {
		printf( '<link rel="pingback" href="%s">' . "\n", esc_url(get_bloginfo( 'pingback_url' )) );
	}
}
add_action( 'wp_head', 'edupress_pingback_header' );

if ( ! function_exists( 'edupress_theme_support_classic_widgets' ) ) :

function edupress_theme_support_classic_widgets() {
	remove_theme_support( 'widgets-block-editor' );
}
endif;
add_action( 'after_setup_theme', 'edupress_theme_support_classic_widgets' );

/**
 * --------------------------------------------
 * Enqueue scripts and styles for the backend.
 *
 * @package EduPress
 * --------------------------------------------
 */

if ( ! function_exists( 'edupress_scripts_admin' ) ) {
	/**
	 * Enqueue admin styles and scripts
	 *
	 * @since  1.0.0
	 * @return void
	 */
	function edupress_scripts_admin( $hook ) {
		// if ( 'widgets.php' !== $hook ) return;

		// Styles
		wp_enqueue_style(
			'edupress-style-admin',
			get_template_directory_uri() . '/ilovewp-admin/css/ilovewp_theme_settings.css',
			'', ILOVEWP_VERSION, 'all'
		);
	}
}
add_action( 'admin_enqueue_scripts', 'edupress_scripts_admin' );

/**
 * Enqueue scripts and styles.
 */
function edupress_scripts() {

	$theme_version = wp_get_theme()->get( 'Version' );

	wp_enqueue_style( 'edupress-style', get_stylesheet_uri(), array(), $theme_version );

	wp_enqueue_script(
		'jquery-superfish',
		get_template_directory_uri() . '/js/superfish.min.js',
		array('jquery'),
		null
	);

	wp_enqueue_script(
		'jquery-flexslider',
		get_template_directory_uri() . '/js/jquery.flexslider-min.js',
		array('jquery'),
		true
	);

	wp_register_script( 'edupress-scripts', get_template_directory_uri() . '/js/edupress.js', array( 'jquery' ), $theme_version, true );
	wp_enqueue_script( 'edupress-scripts' );

	/* Icomoon */
	wp_enqueue_style('ilovewp-icomoon', get_template_directory_uri() . '/css/icomoon.css', null, $theme_version);

	if ( is_singular() && comments_open() && get_option( 'thread_comments' ) ) {
		wp_enqueue_script( 'comment-reply' );
	}

}
add_action( 'wp_enqueue_scripts', 'edupress_scripts' );

/**
 * Custom template tags for this theme.
 */
require get_template_directory() . '/inc/template-tags.php';

/**
 * Customizer additions.
 */
require get_template_directory() . '/inc/customizer.php';

/**
 * Modifies tag cloud widget arguments to have all tags in the widget same font size.
 *
 * @since EduPress 1.0
 *
 * @param array $args Arguments for tag cloud widget.
 * @return array A new modified arguments.
 */
function edupress_widget_tag_cloud_args( $args ) {
	$args['largest'] = 1;
	$args['smallest'] = 1;
	$args['unit'] = 'em';
	return $args;
}
add_filter( 'widget_tag_cloud_args', 'edupress_widget_tag_cloud_args' );

if ( ! function_exists( 'wp_body_open' ) ) {
    function wp_body_open() {
        do_action( 'wp_body_open' );
    }
}

/* Include Additional Options and Components
================================== */

require_once( get_template_directory() . '/ilovewp-admin/sidebars.php');
require_once( get_template_directory() . '/ilovewp-admin/helper-functions.php');

/* Include Theme Options Page for Admin
================================== */

//require only in admin!
if( is_admin() ) {	
	require_once('ilovewp-admin/ilovewp-theme-settings.php');

	if (current_user_can( 'manage_options' ) ) {
		require_once(get_template_directory() . '/ilovewp-admin/admin-notices/ilovewp-notices.php');
		require_once(get_template_directory() . '/ilovewp-admin/admin-notices/ilovewp-notice-welcome.php');
		require_once(get_template_directory() . '/ilovewp-admin/admin-notices/ilovewp-notice-review.php');
		require_once(get_template_directory() . '/ilovewp-admin/admin-notices/ilovewp-notice-magma.php');

		// Remove theme data from database when theme is deactivated.
		add_action('switch_theme', 'edupress_db_data_remove');

		if ( ! function_exists( 'edupress_db_data_remove' ) ) {
			function edupress_db_data_remove() {

				delete_option( 'edupress_admin_notices');
				delete_option( 'edupress_theme_installed_time');

			}
		}

	}

}