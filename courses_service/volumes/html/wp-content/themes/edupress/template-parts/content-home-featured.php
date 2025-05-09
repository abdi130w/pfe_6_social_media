<?php
/**
 * The template used for displaying featured pages on the Front Page.
 *
 * @package EduPress
 */

$page_ids = array();
$page_ids[] = absint(get_theme_mod( 'edupress_featured_page_1', false ));
$page_ids[] = absint(get_theme_mod( 'edupress_featured_page_2', false ));
$page_ids[] = absint(get_theme_mod( 'edupress_featured_page_3', false ));
$page_ids[] = absint(get_theme_mod( 'edupress_featured_page_4', false ));

$custom_loop = new WP_Query( array( 'post_type' => 'page', 'post__in' => $page_ids, 'orderby' => 'post__in' ) );
?>

<?php if ( $custom_loop->have_posts() ) : $i = 0; ?>

	<div id="ilovewp-featured-content" class="site-flexslider">
		<ul class="site-slideshow-list academia-slideshow">
	
			<?php 
			while ( $custom_loop->have_posts() ) : $custom_loop->the_post();
			$image_loading = 'lazy';
			if ( $i == 0 ) {
				$image_loading = 'eager';
			}
			$i++;
			?>

			<li class="site-slideshow-item"<?php if ( $i > 1 ) { echo ' style="display: none;"';} ?>>
				<div class="ilovewp-post-wrapper">
					<?php if ( has_post_thumbnail() ) { ?>
					<a href="<?php the_permalink(); ?>" title="<?php the_title_attribute(); ?>"><?php the_post_thumbnail('edupress-large-thumbnail', array('loading' => $image_loading)); ?></a>
					<?php } ?>
					<?php if ( 1 == get_theme_mod( 'edupress_front_featured_pages_title', 1 ) ) { ?>
					<div class="post-preview">
						<div class="post-preview-wrapper">
							<?php the_title( sprintf( '<h2 class="title-post"><a href="%s" rel="bookmark">', esc_url( get_permalink() ) ), '</a></h2>' ); ?>
							<?php the_excerpt(); ?>
						</div><!-- .post-preview-wrapper -->
					</div><!-- .post-preview -->
					<?php } ?>
				</div><!-- .ilovewp-post-wrapper -->
			</li><!-- .site-slideshow-item -->

            <?php endwhile; ?>
	
		</ul><!-- .site-slideshow-list academia-slideshow -->

	</div><!-- #ilovewp-featured-content .site-flexslider -->

<?php if ( count($page_ids) > 0 ) { ?>
	<script type="text/javascript">
	jQuery(document).ready(function() {
		
		jQuery(".site-flexslider").flexslider({
			selector: ".site-slideshow-list > .site-slideshow-item",
			animation: "slide",
			animationLoop: true,
			initDelay: 0,
			smoothHeight: false,
			slideshow: false,
			pauseOnAction: false,
			pauseOnHover: false,
			controlNav: false,
			directionNav: true,
			useCSS: false,
			touch: false,
			animationSpeed: 300,
			rtl: false,
			reverse: false,
			prevText: '<span class="icon-icomoon academia-icon-chevron-left"></span>',
			nextText: '<span class="icon-icomoon academia-icon-chevron-right"></span>',
			start: function(slider) { slider.addClass('site-flexslider-loaded'); }
		});
	
	});
	</script>
<?php } ?>

<?php else : ?>

	 <?php if ( current_user_can( 'publish_posts' ) && is_customize_preview() ) : ?>

		<div id="ilovewp-featured-content">

			<div class="ilovewp-page-intro ilovewp-nofeatured">
				<h1 class="title-page"><?php esc_html_e( 'No Featured Pages Found', 'edupress' ); ?></h1>
				<div class="taxonomy-description">

					<p><?php printf( esc_html__( 'This section will display your featured pages. Configure (or disable) it via the Customizer.', 'edupress' ) ); ?></p>
					<p><strong><?php printf( esc_html__( 'Important: This message is NOT visible to site visitors, only to admins and editors.', 'edupress' ) ); ?></strong></p>

				</div><!-- .taxonomy-description -->
			</div><!-- .ilovewp-page-intro .ilovewp-nofeatured -->

		</div><!-- #ilovewp-featured-content -->

	<?php endif; ?>

<?php endif; ?>