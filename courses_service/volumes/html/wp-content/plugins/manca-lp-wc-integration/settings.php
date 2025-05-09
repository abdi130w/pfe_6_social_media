<?php
/*****************************************************************************************
*
* MANCA - Cool Integration for LearnPress & WooCommerce 1.0 - 12/05/2020 - settings.php
* Pluggin Settings
*
*****************************************************************************************/

if ( ! defined( 'ABSPATH' ) ) {	die( '-1' ); };

if ( is_admin() ) {
	require_once LPWCI_PLUGIN_DIR . '/admin/admin.php';
} else {
	require_once LPWCI_PLUGIN_DIR . '/public/public.php';
}

?>
