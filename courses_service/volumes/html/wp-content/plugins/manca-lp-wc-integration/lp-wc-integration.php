<?php
/*
* Plugin Name: Cool Integration for LearnPress & WooCommerce
* Plugin URI: https://manca.com.ar/lp-&-wc-integration
* Description: LearnPress & WooCommerce Integration. LearnPress Courses & WooCommerce Product Sync. User Auto Enrollment on Payment Complete.
* Author: MANCA
* Autho URI: https://www.manca.com
* Version: 1.1.3
* Requires at least: 5.3
* Tested up to: 6.3.1
*/

define( 'LPWCI_VERSION', '1.1.2' );

define( 'LPWCI_REQUIRED_WP_VERSION', '5.3' );

define( 'LPWCI_PLUGIN', __FILE__ );

define( 'LPWCI_PLUGIN_BASENAME', plugin_basename( LPWCI_PLUGIN ) );

define( 'LPWCI_PLUGIN_NAME', trim( dirname( LPWCI_PLUGIN_BASENAME ), '/' ) );

define( 'LPWCI_PLUGIN_DIR', untrailingslashit( dirname( LPWCI_PLUGIN ) ) );

require_once LPWCI_PLUGIN_DIR . '/settings.php';
?>
