<?php
/*****************************************************************************************
*
* MANCA - Cool Integration for LearnPress & WooCommerce 1.0 - 12/05/2020 - admin/admin.php
* Admin Plugin Hooks
*
*****************************************************************************************/

if ( ! defined( 'ABSPATH' ) ) {
  die( '-1' );
};

require_once LPWCI_PLUGIN_DIR . '/admin/course-product-sync.php';
require_once LPWCI_PLUGIN_DIR . '/admin/enrollment-sync.php';

add_action( 'save_post', 'lpwci_sync_product_on_save_post_lp_course', 10, 3 );
add_action( 'save_post', 'lpwci_syn_course_from_product_on_save_post', 10, 3 );
add_action('woocommerce_order_status_completed', 'lpwci_lp_enroll_on_wc_payment_complete', 10, 1 );

?>
