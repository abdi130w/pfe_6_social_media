<?php
/*****************************************************************************************
*
* MANCA - Cool Integration for LearnPress & WooCommerce 1.0 - 12/05/2020 - admin/includes/wp-admin-functions.php
* Functions & Wrappers related to WordPress API
*
*****************************************************************************************/

if ( ! defined( 'ABSPATH' ) ) {
  die( '-1' );
}

/*
* Function: lpwci_get_post_meta_or_null
* Description: Returns Post Meta Value or Empty String if not exists
*/
function lpwci_get_post_meta_or_null(int $post_id, string $meta_key ){
  if ( !( empty( get_post_meta( $post_id, $meta_key ) ) ) ) {
    return get_post_meta( $post_id, $meta_key )[0];
  }
  return '';
};

/*
* Function: lpwci_add_update_post_meta
* Description: Adds a new custom field if the key does not already exist, or updates the value of the custom field with that key otherwise.
*/
function lpwci_add_update_post_meta(int $post_id, string $meta_key, string $meta_value, bool $unique = false ){
  if ( ! add_post_meta( $post_id, $meta_key, $meta_value, $unique ) ) {
    update_post_meta ( $post_id, $meta_key, $meta_value );
  }
};
?>
