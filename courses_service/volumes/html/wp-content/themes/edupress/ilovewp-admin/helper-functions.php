<?php
//

// Post Next/Previous navigation
if( ! function_exists( 'ilovewp_helper_display_post_navigation' ) ) {
	function ilovewp_helper_display_post_navigation($post) {

		if( ! is_object( $post ) ) return;

		if ( get_post_type($post->ID) == 'post' ) { 

			$output = '';
			$output .= '<div class="post-navigation">';
			$output .= '<div class="site-post-nav-item site-post-nav-prev">' . get_previous_post_link( '<span class="post-navigation-label">' . __('Previous Article', 'edupress') . '</span>' . '%link', '%title', false ) . '</div><!-- .site-post-nav-item -->';
			$output .= '<div class="site-post-nav-item site-post-nav-next">' . get_next_post_link( '<span class="post-navigation-label">' . __('Next Article', 'edupress') . '</span>' . '%link', '%title', false ) . '</div><!-- .site-post-nav-item -->';
			$output .= '</div><!-- .post-navigation -->';

			return $output;

		}

	}
}

// Get Header Style
if( ! function_exists( 'ilovewp_helper_get_header_style' ) ) {
	function ilovewp_helper_get_header_style() {

		$themeoptions_header_style = esc_attr(get_theme_mod( 'theme-header-style', 'default' ));

		if ( $themeoptions_header_style == 'default' ) {
			$default_position = 'page-header-default';
		} elseif ( $themeoptions_header_style == 'centered' ) {
			$default_position = 'page-header-centered';
		}

		return $default_position;
	}
}

// Get Sidebar Position for Current Page or Post
if( ! function_exists( 'ilovewp_helper_get_sidebar_position' ) ) {
	function ilovewp_helper_get_sidebar_position() {

		global $post;

		$themeoptions_sidebar_position = esc_attr(get_theme_mod( 'theme-sidebar-position', 'left' ));

		if ( $themeoptions_sidebar_position == 'left' ) {
			$default_position = 'page-sidebar-left';
		} elseif ( $themeoptions_sidebar_position == 'right' ) {
			$default_position = 'page-sidebar-right';
		}

		if ( is_page() ) {
			$page_template = get_page_template_slug( $post->ID );
			if ( $page_template && $page_template == 'page-templates/sidebar-page.php' ) {
				$default_position = 'page-sidebar-right';
			}
		}

		return $default_position;
	}
}

/**
 * Adds custom classes to the array of body classes.
 *
 * @param array $classes Classes for the body element.
 * @return array
 */

function edupress_body_classes( $classes ) {
	// Adds a class of group-blog to blogs with more than 1 published author.
	if ( is_multi_author() ) {
		$classes[] = 'group-blog';
	}

    if ( is_page() && !comments_open() && '0' == get_comments_number() ) {
		$classes[] = 'comments-closed';
    }

    $classes[] = ilovewp_helper_get_header_style();
    $classes[] = ilovewp_helper_get_sidebar_position();

	return $classes;
}

add_filter( 'body_class', 'edupress_body_classes' );

/**
 * Adds a Sub Nav Toggle to the Expanded Menu and Mobile Menu.
 *
 * @param stdClass $args  An object of wp_nav_menu() arguments.
 * @param WP_Post  $item  Menu item data object.
 * @param int      $depth Depth of menu item. Used for padding.
 * @return stdClass An object of wp_nav_menu() arguments.
 */
function edupress_add_sub_toggles_to_main_menu( $args, $item, $depth ) {

	// Add sub menu toggles to the Expanded Menu with toggles.
	if ( isset( $args->show_toggles ) && $args->show_toggles ) {

		$args->after  = '';

		if ( in_array( 'menu-item-has-children', $item->classes, true ) ) {

			$args->after .= '<button class="sub-menu-toggle toggle-anchor"><span class="screen-reader-text">' . __( 'Show sub menu', 'edupress' ) . '</span><i class="icon-icomoon academia-icon-chevron-down"></i></span></button>';

		}
	} 

	return $args;

}

add_filter( 'nav_menu_item_args', 'edupress_add_sub_toggles_to_main_menu', 10, 3 );