<!DOCTYPE html>
<html <?php language_attributes(); ?>>
<head>
<meta charset="<?php bloginfo( 'charset' ); ?>">
<meta http-equiv="X-UA-Compatible" content="IE=edge" />
<meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="profile" href="http://gmpg.org/xfn/11">

<?php wp_head(); ?>
</head>

<body <?php body_class(); ?>>

<?php wp_body_open(); ?>

<div id="container">

	<a class="skip-link screen-reader-text" href="#site-main"><?php esc_html_e( 'Skip to content', 'edupress' ); ?></a>
	<header class="site-header" role="banner">
	
		<div class="wrapper wrapper-header">

			<div id="site-header-main">
			
				<div class="site-branding"><?php 
					if ( function_exists( 'has_custom_logo' ) && has_custom_logo() ) {
						edupress_the_custom_logo();
					} else { ?>
					<p class="site-title"><a href="<?php echo esc_url( home_url( '/' ) ); ?>" rel="home"><?php bloginfo( 'name' ); ?></a></p>
					<p class="site-description"><?php bloginfo( 'description' ); ?></p><?php } ?></div><!-- .site-branding -->
			</div><!-- #site-header-main -->

			<?php if (has_nav_menu( 'primary' )) { ?>

			<?php
				if (has_nav_menu( 'primary' ) || has_nav_menu( 'mobile' )) {
					get_template_part( 'template-parts/mobile-menu-toggle' );
					get_template_part( 'template-parts/mobile-menu' );
				}
			?>

			<div id="site-header-navigation">
	
				<nav id="menu-main">
					<?php
					wp_nav_menu( array(
						'container' => '', 
						'container_class' => '', 
						'menu_class' => 'dropdown', 
						'menu_id' => 'menu-main-menu', 
						'sort_column' => 'menu_order', 
						'theme_location' => 'primary', 
						'link_after' => '', 
						'items_wrap' => '<ul id="site-primary-menu" class="large-nav sf-menu">%3$s</ul>' ) );
					?>
				</nav><!-- #menu-main -->
			
			</div><!-- #site-header-navigation -->
			<?php } ?>
			
		</div><!-- .wrapper .wrapper-header -->

	</header><!-- .site-header -->