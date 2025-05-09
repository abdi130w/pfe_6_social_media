<?php
if ( 'posts' == get_option( 'show_on_front' ) ) :

	get_template_part( 'index' );

else :

?>

	<?php get_header(); ?>

	<div id="site-main" class="content-home">

		<div class="wrapper wrapper-main">
			
			<div class="wrapper-frame">
			
				<main id="site-content" class="site-main" role="main">
				
					<div class="site-content-wrapper">
	
						<?php
						if ( 1 == get_theme_mod( 'edupress_front_featured_pages', 1 ) ) {
							get_template_part( 'template-parts/content', 'home-featured' );
						}
						
						if ( 1 == get_theme_mod( 'edupress_front_featured_pages_columns', 1 ) ) {
							get_template_part( 'template-parts/content', 'home-pages' );
						}
						?>

						<?php while ( have_posts() ) : the_post(); ?>
						
						<?php get_template_part( 'template-parts/content', 'home' ); ?>
							
						<?php endwhile; // End of the loop. ?>

					</div><!-- .site-content-wrapper -->
				
				</main><!-- #site-content -->
				
				<?php get_sidebar(); ?>
			
			</div><!-- .wrapper-frame -->
		
		</div><!-- .wrapper .wrapper-main -->

	</div><!-- #site-main -->

	<?php get_footer(); ?>

<?php endif; ?>