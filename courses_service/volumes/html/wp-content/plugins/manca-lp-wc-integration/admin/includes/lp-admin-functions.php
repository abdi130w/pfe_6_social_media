<?php
/*****************************************************************************************
*
* MANCA - Cool Integration for LearnPress & WooCommerce 1.0 - 12/05/2020 - admin/includes/lp-admin-functions.php
* Functions & Wrappers related to LearnPress API
*
*****************************************************************************************/

if ( ! defined( 'ABSPATH' ) ) {
  die( '-1' );
}

/*
* Function: lpwci_set_course_tags
* Description: Set Learnpress Course Tags
*/
function lpwci_set_course_tags( $post_id = 0, $tags = '', $append = false ) {
  return wp_set_post_terms( $post_id, $tags, 'course_tag', $append );
}

/*
* Function: lpwci_get_course_tags
* Description: Get Learnpress Course Tags
*/
function lpwci_get_course_tags( $post_id = 0, $args = array() ) {
  $return = "";
  $tags = wp_get_post_terms( $post_id, 'course_tag', $args );
  foreach( $tags as $tag ) {
    $return.=",".$tag->name;
  }
  return $return;
}

/*
* Function: lpwci_set_course_cat
* Description: Set Learnpress Course Category
*/
function lpwci_set_course_cat( $post_id = 0, $tags = '', $append = false ) {
  return wp_set_post_terms( $post_id, $tags, 'course_category', $append );
}

/*
* Function: lpwci_get_course_cat
* Description: GetLearnpress Course Category
*/
function lpwci_get_course_cat( $post_id = 0, $args = array() ) {
  $return = "";
  $tags = wp_get_post_terms( $post_id, 'course_category', $args );
  foreach( $tags as $tag ) {
    $return .= "," . $tag->name;
  }
  return $return;
}

?>
