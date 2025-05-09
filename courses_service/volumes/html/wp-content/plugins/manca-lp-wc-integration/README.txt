=== Cool Integration for LearnPress & WooCommerce ===
Contributors: matiasanca
Tags: LearnPress, WooCommerce, Integration, Course, Product, Sync, Auto Enrollment
Requires at least: 5.3
Tested up to: 6.3.1
Stable tag: 1.1.3
Requires PHP: 7.1
License: GPLv2 or later
License URI: http://www.gnu.org/licenses/gpl-2.0.html

Lite plugin to get LearnPress Courses & WooCommerce Product on Sync. User Auto Enrollment on Payment Complete.

== Description ==

LearnPress Course integration with WooCommerce Products. Everytime a Course is added, a Product is added too ( and related to each other! ). This relationship allows to keep syncronized the Course & Product.
Also when an User purchases the Product from WooCommerce and the Payment is completed, the User will be auto enrolled in the Course related to this Product.
The main target is to handle purchases thought WooCommerce.

== Installation ==
1. Upload `lp-wc-integration.zip` to the `/wp-content/plugins/` directory
2. Activate the plugin through the 'Plugins' menu in WordPress

== Changelog ==
= 1.1.3 =
* Change the way to enroll student

= 1.1 =
* Set WooCommerce Sold Individually value to 'yes'
* Solved issues with LearnPress Versión 4.
* ONLY WORKS WITH LearnPress 4

= 1.0 =
* Add new Product when Course is added ( Hook: save_post )
* Update Product when Course is updated ( Hook: save_post )
* Update Course when Product is updated ( Hook: save_post )
* Create LearnPress Order when Product Payment is completed ( Hook: woocommerce_order_status_completed )
* Auto Enroll User when Product Payment is completed ( Hook: woocommerce_order_status_completed )

==BUGLIST==
* There is a problem when you duplicate a Product or Course. If you duplicate a Course, both courses are linked to the same product. BE CAREFULL.
