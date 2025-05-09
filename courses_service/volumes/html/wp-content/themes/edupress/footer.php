	<footer class="site-footer" role="contentinfo">
	
		<?php get_sidebar( 'footer' ); ?>
		
		<div class="wrapper-copy">
			<div class="wrapper">
				<p class="copy"><?php _e('Copyright &copy;','edupress');?> <?php echo date_i18n(__("Y","edupress")); ?> <?php bloginfo('name'); ?>. <?php _e('All Rights Reserved', 'edupress');?>. </p>
				<p class="copy-ilovewp"><span class="theme-credit"><?php _e( 'Powered by', 'edupress' ); ?> <a href="https://www.ilovewp.com/themes/edupress/" rel="external">EduPress</a></span></p>
			</div><!-- .wrapper -->
		</div><!-- .wrapper-copy -->
	
	</footer><!-- .site-footer -->

</div><!-- end #container -->

<?php wp_footer(); ?>

</body>
</html>