<?php
// Exit if accessed directly.
defined( 'ABSPATH' ) || exit;

class edupress_notice_magma extends edupress_notice {

	public function __construct() {

		add_action( 'wp_loaded', array( $this, 'magma_notice' ), 20 );
		add_action( 'wp_loaded', array( $this, 'hide_notices' ), 15 );

		$this->current_user_id       = get_current_user_id();

	}

	public function magma_notice() {
		
		$welcome_notice_was_dismissed = $this->get_notice_status('welcome');

		if ( ! get_option( 'edupress_theme_installed_time' ) ) {
			update_option( 'edupress_theme_installed_time', time() );
		}

		$this_notice_was_dismissed = $this->get_notice_status('magma-user-' . $this->current_user_id);
		
		if ( !$this_notice_was_dismissed && $welcome_notice_was_dismissed ) {
			add_action( 'admin_notices', array( $this, 'magma_notice_markup' ) ); // Display this notice.
		}

	}

	/**
	 * Show HTML markup if conditions meet.
	 */
	public function magma_notice_markup() {
		
		$dismiss_url = wp_nonce_url(
			remove_query_arg( array( 'activated' ), add_query_arg( 'edupress-hide-notice', 'magma-user-' . $this->current_user_id ) ),
			'edupress_hide_notices_nonce',
			'_edupress_notice_nonce'
		);

		$theme_data	 	= wp_get_theme();
		$current_user 	= wp_get_current_user();

		if ( ( get_option( 'edupress_theme_installed_time' ) > strtotime( '-3 days' ) ) ) {
			return;
		}

		?>
		<div id="message" class="notice notice-success ilovewp-notice ilovewp-upgrade-notice">
			<a class="ilovewp-message-close notice-dismiss" href="<?php echo esc_url( $dismiss_url ); ?>"></a>
			<div class="ilovewp-message-content">

				<div class="ilovewp-message-image">
					<a href="<?php echo esc_url( admin_url( 'themes.php?page=edupress-doc' ) ); ?>"><img class="ilovewp-screenshot" src="<?php echo esc_url( get_template_directory_uri() ); ?>/screenshot.png" alt="<?php esc_attr_e( 'EduPress', 'edupress' ); ?>" /></a>
				</div><!-- ws fix
				--><div class="ilovewp-message-text">
				
					<p>
						<?php
						printf(
							/* Translators: %1$s current user display name. */
							esc_html__(
								'Dear %1$s! %3$sIf you like using this theme, you’ll love Magma—a fantastic, high-performance theme designed to help you build a professional WordPress website with ease. %4$s is fast, flexible, and built for content-driven websites, giving you full control without unnecessary bloat.',
								'edupress'
							),
							'<strong>' . esc_html( $current_user->display_name ) . '</strong>',
							'<a href="' . esc_url( admin_url( 'themes.php?page=edupress-doc' ) ) . '">' . esc_html( $theme_data->Name ) . ' Theme</a>',
							'<br>',
							'<strong><a href="https://www.ilovewp.com/product/magma/?utm_source=dashboard&utm_medium=magma-notice&utm_campaign=edupress&utm_content=magma-notice">Magma</a></strong>');
						?>
					</p>

					<p class="notice-buttons"><a href="https://www.ilovewp.com/product/magma/?utm_source=dashboard&utm_medium=magma-notice&utm_campaign=edupress&utm_content=magma-notice" class="btn button button-primary ilovewp-button" target="_blank"><?php esc_html_e( 'Discover Magma today!', 'edupress' ); ?></a> <a href="https://www.youtube.com/watch?v=pxNKBXG4clY" target="_blank" rel="noopener" class="button button-primary ilovewp-button ilovewp-button-youtube"><span class="dashicons dashicons-youtube"></span> <?php esc_html_e( 'Magma Video Guide', 'edupress' ); ?></a></p>

				</div><!-- .ilovewp-message-text -->

			</div><!-- .ilovewp-message-content -->

		</div><!-- #message -->
		<?php
	}
}

new edupress_notice_magma();