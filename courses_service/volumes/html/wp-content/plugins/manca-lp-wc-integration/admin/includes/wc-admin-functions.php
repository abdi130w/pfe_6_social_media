<?php
/*****************************************************************************************
*
* MANCA - Cool Integration for LearnPress & WooCommerce 1.0 - 12/05/2020 - admin/includes/wc-admin-functions.php
* Functions & Wrappers related to WooCommerce API
*
*****************************************************************************************/

if ( ! defined( 'ABSPATH' ) ) {
  die( '-1' );
}

/*
* Function: lpwci_set_product_tags
* Description: Set WooCommerce Product Tags
*/
function lpwci_set_product_tags( $post_id = 0, $tags= '', $append = false ) {
  return wp_set_post_terms( $post_id, $tags, 'product_tag', $append );
}

/*
* Function: lpwci_get_product_tags
* Description: Get WooCommerce Product Tags
*/
function lpwci_get_product_tags( $post_id = 0, $args = array() ) {
  $return = "";
  $tags = wp_get_post_terms( $post_id, 'product_tag', $args );
  foreach( $tags as $tag ) {
    $return .= "," . $tag->name;
  }
  return $return;
}

/*
* Function: lpwci_set_product_cat
* Description: Set WooCommerce Product Category
*/
function lpwci_set_product_cat( $post_id = 0, $tags= '', $append = false ) {
  return wp_set_post_terms( $post_id, $tags, 'product_cat', $append );
}

/*
* Function: lpwci_get_product_cat
* Description: Get WooCommerce Product Category
*/
function lpwci_get_product_cat( $post_id = 0, $args = array() ) {
  $return = "";
  $tags = wp_get_post_terms( $post_id, 'product_cat', $args );
  foreach( $tags as $tag ) {
    $return .= "," . $tag->name;
  }
  return $return;
}
?>
