<?php
/*****************************************************************************************
*
* MANCA - Cool Integration for LearnPress & WooCommerce 1.0 - 12/05/2020 - admin/enrollment-sync.php
* Enroll user into LearnPress Course when a Product Payment Completes
*
*****************************************************************************************/

if ( ! defined( 'ABSPATH' ) ) {
  die( '-1' );
};

require_once LPWCI_PLUGIN_DIR . '/admin/includes/wp-admin-functions.php';
require_once LPWCI_PLUGIN_DIR . '/admin/includes/wc-admin-functions.php';
require_once LPWCI_PLUGIN_DIR . '/admin/includes/lp-admin-functions.php';

/*
* Function: lpwci_lp_enroll_on_wc_payment_complete
* When a WooCommerce Order Payment is completed -> Creates a Learnpress Order and Enroll User
*/
function lpwci_lp_enroll_on_wc_payment_complete( $order_id ) {

  $WPOrder = wc_get_order( $order_id );
  $items = $WPOrder->get_items();
  $LPUser = learn_press_get_user( $WPOrder->get_user_id(), false );

  foreach ( $items as $item ) {
    //Check if lp_course exists
    if ( !( empty( get_post_meta( $item['product_id'], '_mlpwc_xref' ) ) ) ) {
      $WPCourse = get_post( get_post_meta( $item['product_id'], '_mlpwc_xref' )[0] );
    }

    if ( !empty( $WPCourse ) ) {
      $LPItemData = array(
        'order_item_name'   => $WPCourse->post_title,
        'item_id'           => $WPCourse->ID,
        'quantity'          => 1
      );

      /*$default_args = array(
       'status'        => '',
       'customer_id'   => null,
       'customer_note' => null,
       'order_id'      => 0,
       'created_via'   => 'external',
       'parent'        => 0
      );*/

      $WPLPOrder = new LP_Order();
      //$WPLPOrder = learn_press_create_order( $default_args );
      $WPLPOrder->set_created_via('external');
      //$WPLPOrder->set_status( 'lp-completed' );
      $WPLPOrder->set_user_ip_address(  $WPOrder->get_customer_ip_address() );
      $WPLPOrder->set_user_agent(  $WPOrder->get_customer_user_agent() );
      $WPLPOrder->set_user_id( $WPOrder->get_user_id() );
      $WPLPOrder->save();
      $WPLPOrder->add_item( $LPItemData );
      $WPLPOrder->save();
      $WPLPOrder->update_status(  'lp-completed', true );
      //$WPLPOrder->payment_complete();

      $user_course_data = $LPUser->get_course_data( $WPCourse->ID );
      $user_course_data->set_status( LP_COURSE_ENROLLED ); 
      $user_course_data->set_start_time( time() );
      $user_course_data->set_end_time();
      $user_course_data->set_graduation( LP_COURSE_GRADUATION_IN_PROGRESS );
      $user_course_data->update();
      //$ret =  $LPUser->enroll( $WPCourse->ID, $WPLPOrder->id, true );
    }
  }
  return $order_id;
}
?>
