<?php
/*****************************************************************************************
*
* MANCA - Cool Integration for LearnPress & WooCommerce 1.0 - 12/05/2020 - public/public.php
* Public Plugin Hooks
*
*****************************************************************************************/

if ( ! defined( 'ABSPATH' ) ) {
  die( '-1' );
};

require_once LPWCI_PLUGIN_DIR . '/admin/enrollment-sync.php';

add_action('woocommerce_order_status_completed', 'lpwci_lp_enroll_on_wc_payment_complete', 10, 1 );

?>
