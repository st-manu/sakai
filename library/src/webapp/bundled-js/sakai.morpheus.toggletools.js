/**
 * Legacy tool-menu collapse helpers.
 * The portal shell uses SidebarCollapseButton + class "sidebar-collapsed"
 * (see portal.sidebar.collapse.js). Mrphs-toolMenu-collapsed is kept as an
 * alias for older markup / CSS only.
 */

portal = portal || {};

if (portal.toolsCollapsed === undefined) {
	portal.toolsCollapsed = false;
}

portal.updateToolsCollapsedPref = function (collapsed) {
	if (portal.user.id) {
		var url = '/direct/userPrefs/updateKey/' + portal.user.id + '/sakai:portal:sitenav?toolsCollapsed=' + collapsed;
		$PBJQ.ajax(url, {method: 'PUT', cache: false});
	}
};

portal.toggleMinimizeNav = function () {

  $PBJQ("body").toggleClass("Mrphs-toolMenu-collapsed");
  $PBJQ(".portal-container, #portal-nav-sidebar").toggleClass("sidebar-collapsed");

  var el = $PBJQ("#toolsNav-toggle-li button");
  el.toggleClass('min max').parent().toggleClass('min max');

  if (portal.toolsCollapsed) {
    portal.updateToolsCollapsedPref(false);
    portal.toolsCollapsed = false;
    el.attr('aria-pressed', false);
  } else {
    portal.updateToolsCollapsedPref(true);
    portal.toolsCollapsed = true;
    el.attr('aria-pressed', true);
  }
};
