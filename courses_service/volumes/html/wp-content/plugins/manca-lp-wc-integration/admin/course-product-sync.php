<?php
/*****************************************************************************************
*
* MANCA - Cool Integration for LearnPress & WooCommerce 1.0 - 12/05/2020 - admin/course-product-sync.php
* Mantein WooCommerce Product & LearnPress Course Sync
*
*****************************************************************************************/

if ( ! defined( 'ABSPATH' ) ) {
  die( '-1' );
};

require_once LPWCI_PLUGIN_DIR . '/admin/includes/wp-admin-functions.php';
require_once LPWCI_PLUGIN_DIR . '/admin/includes/wc-admin-functions.php';
require_once LPWCI_PLUGIN_DIR . '/admin/includes/lp-admin-functions.php';

/*
* Function: lpwci_sync_product_on_save_post_lp_course
* Description: Syncronize Post (Post_Type-> 'lp_course') with WooCommerce Product
* The following attributes are on Sync: post_author, post_date, post_content, post_title,
* post_excerpt, post_status, post_type, comment_status,
* _mlpwc_xref (new cross reference meta data), thumbnail, tags
*
* Set WooCoomerce Defaults:
* _virtual -> yes
* _regular_price -> _lp_price
* _price -> _lp_price
* _sale_price -> _lp_sale_price
* _sale_price_dates_from -> _lp_sale_start
* _sale_price_dates_to -> _lp_sale_end
* _sold_individually -> yes
* 
* TODO:post_category are differents from Prodcuts to Courses
*/
function lpwci_sync_product_on_save_post_lp_course( $Post_ID, $WPPost, $Update ) {
  //If this is a reevision -> exit
  if ( wp_is_post_revision( $Post_ID ) ) {
    return;
  };

  //If this is autosave -> exit
  if ( wp_is_post_autosave( $Post_ID ) ) {
    return;
  };

  //Another autosave check -> exit
  if( defined( 'DOING_AUTOSAVE' ) && DOING_AUTOSAVE ) {
    return;
  }

  //If this is not a post -> exit
  if ( $WPPost->post_type != 'lp_course' ) {
    return;
  };

  //Define product information
  $ProductData = array(
    'ID'              => '',
    'post_author'     => $WPPost->post_author,
    'post_date'       => $WPPost->post_date,
    'post_content'    => $WPPost->post_content,
    'post_title'      => $WPPost->post_title,
    'post_excerpt'    => $WPPost->post_excerpt,
    'post_status'     => $WPPost->post_status,
    'post_type'       => 'product',
    'comment_status'  => 'closed',
    'post_category'   => $WPPost->post_category,
    'tags_input'      => $WPPost->tags_input,
  );

  //Check if product exists
  if ( !( empty( get_post_meta( $WPPost->ID, '_mlpwc_xref' ) ) ) ) {
    $WPProduct = get_post( get_post_meta( $WPPost->ID, '_mlpwc_xref' )[0] );
  }

  //Avoid infinite loop
  remove_action( 'save_post', 'lpwci_sync_product_on_save_post_lp_course', 10, 3 );
  remove_action( 'save_post', 'lpwci_syn_course_from_product_on_save_post', 10, 3 );

  //Evaluates if product should be updated or created
  if ( empty( $WPProduct ) or ( $WPProduct->post_status == 'auto-draft' ) ) {
    //Create new product
    $NewProductId = wp_insert_post( $ProductData, $wp_error = null );

    //Update xref
    lpwci_add_update_post_meta( $WPPost->ID, '_mlpwc_xref', strval( $NewProductId ), true );
    lpwci_add_update_post_meta( $NewProductId, '_mlpwc_xref', strval( $WPPost->ID ), true );

    //Refresh WPProduct object
    $WPProduct = get_post( $NewProductId );

  } else {

    //update existing product
    $ProductData['ID'] = $WPProduct->ID;

    //Update product
    wp_update_post( $ProductData, $wp_error = null );

    //Refresh WPProduct object
    $WPProduct = get_post( $WPProduct->ID );
  }

  //Update product thumbnail
  if( has_post_thumbnail( $WPPost->ID ) ) {
    set_post_thumbnail( $WPProduct->ID, get_post_thumbnail_id( $WPPost->ID ) );
  }

  //Update Tags
  lpwci_set_product_tags( $WPProduct->ID, lpwci_get_course_tags( $WPPost->ID ), false );

  //TODO:Update Category
  //lpwci_set_product_cat( $WPProduct->ID, lpwci_get_course_cat( $WPPost->ID ), false );

  //Add default WooCommerce Metadata
  lpwci_add_update_post_meta( $WPProduct->ID, '_virtual', 'yes', true);
  lpwci_add_update_post_meta( $WPProduct->ID, '_regular_price', lpwci_get_post_meta_or_null( $WPPost->ID, '_lp_price' ) , true );
  lpwci_add_update_post_meta( $WPProduct->ID, '_price', lpwci_get_post_meta_or_null( $WPPost->ID, '_lp_price' ) , true );
  lpwci_add_update_post_meta( $WPProduct->ID, '_sale_price', lpwci_get_post_meta_or_null( $WPPost->ID, '_lp_sale_price' ) , true );
  lpwci_add_update_post_meta( $WPProduct->ID, '_sale_price_dates_from', lpwci_get_post_meta_or_null( $WPPost->ID, '_lp_sale_start' ) , true );
  lpwci_add_update_post_meta( $WPProduct->ID, '_sale_price_dates_to', lpwci_get_post_meta_or_null( $WPPost->ID, '_lp_sale_end' ) , true );

  //Change Log 1.1 - Set WooCommerce Sold Individually value to 'yes'
  lpwci_add_update_post_meta( $WPProduct->ID, '_sold_individually', 'yes', true);

  add_action( 'save_post', 'lpwci_sync_product_on_save_post_lp_course', 10, 3 );
  add_action( 'save_post', 'lpwci_syn_course_from_product_on_save_post',10, 3 );

};

/*
* Function: lpwci_syn_course_from_product_on_save_post
* Description: Syncronize Post (Post_Type-> 'product') with LearnPress Course :
* The following attributes are on Sync: post_author, post_date, post_content,
* post_title, post_excerpt, post_status, post_type, comment_status
* _mlpwc_xref (new cross reference meta data), thumbnail, tags
*
* Metadata:
* _regular_price -> _lp_price
* _sale_price -> _lp_sale_price
* _sale_price_dates_from -> _lp_sale_start
* _sale_price_dates_to -> _lp_sale_end
*
* Note: Learnpress Course should exists
* TODO:post_category are differents from Prodcuts to Courses
*/
function lpwci_syn_course_from_product_on_save_post( $Post_ID, $WPPost, $Update ) {
  //If this is a reevision -> exit
  if ( wp_is_post_revision( $Post_ID ) ) {
    return;
  };

  //If this is autosave -> exit
  if ( wp_is_post_autosave( $Post_ID ) ) {
    return;
  };

  //Another autosave check -> exit
  if( defined( 'DOING_AUTOSAVE' ) && DOING_AUTOSAVE ) {
    return;
  }

  //If this is not a post -> exit
  if ( $WPPost->post_type != 'product' ) {
    return;
  };

  //Define product information
  $CourseData = array(
    'ID'              => '',
    'post_author'     => $WPPost->post_author,
    'post_date'       => $WPPost->post_date,
    'post_content'    => $WPPost->post_content,
    'post_title'      => $WPPost->post_title,
    'post_excerpt'    => $WPPost->post_excerpt,
    'post_status'     => $WPPost->post_status,
    'comment_status'  => 'closed',
    'post_category'   => $WPPost->post_category,
    'tags_input'      => $WPPost->tags_input,
  );

  //Check if lp_course exists
  if ( !( empty( get_post_meta( $WPPost->ID, '_mlpwc_xref' ) ) ) ) {
    $WPCourse = get_post( get_post_meta( $WPPost->ID, '_mlpwc_xref' )[0] );
  }

  //Avoid infinite loop
  remove_action( 'save_post', 'lpwci_syn_course_from_product_on_save_post', 10, 3 );
  remove_action( 'save_post', 'lpwci_sync_product_on_save_post_lp_course', 10, 3 );

  //Evaluates if product should be updated or created
  if ( !empty( $WPCourse ) and ( $WPCourse->post_status != 'auto-draft' ) ) {
    //Update existing course
    $CourseData['ID'] = $WPCourse->ID;

    //Update course
    wp_update_post( $CourseData, $wp_error = null );

    //Refresh WPCourse object
    $WPCourse = get_post( $WPCourse->ID );

    //Update product thumbnail
    if( has_post_thumbnail( $WPPost->ID ) ) {
      set_post_thumbnail( $WPCourse->ID, get_post_thumbnail_id( $WPPost->ID ) );
    }

    //Update tags
    lpwci_set_course_tags( $WPCourse->ID, lpwci_get_product_tags( $WPPost->ID ), false );

    //TODO: Update Category
    //lpwci_set_course_cat( $WPCourse->ID, lpwci_get_product_cat($WPPost->ID), false );

    //Update Metadata    
    lpwci_add_update_post_meta( $WPCourse->ID, '_lp_regular_price', lpwci_get_post_meta_or_null( $WPPost->ID, '_regular_price' ), true );
    lpwci_add_update_post_meta( $WPCourse->ID, '_lp_price', lpwci_get_post_meta_or_null( $WPPost->ID, '_regular_price' ), true );
    lpwci_add_update_post_meta( $WPCourse->ID, '_lp_sale_price', lpwci_get_post_meta_or_null( $WPPost->ID, '_sale_price' ), true );
    lpwci_add_update_post_meta( $WPCourse->ID, '_lp_sale_start', lpwci_get_post_meta_or_null( $WPPost->ID, '_sale_price_dates_from' ), true );
    lpwci_add_update_post_meta( $WPCourse->ID, '_lp_sale_end', lpwci_get_post_meta_or_null( $WPPost->ID, '_sale_price_dates_to' ), true );
  }

  add_action( 'save_post', 'lpwci_syn_course_from_product_on_save_post', 10, 3 );
  add_action( 'save_post', 'lpwci_sync_product_on_save_post_lp_course', 10, 3 );
};
?>
