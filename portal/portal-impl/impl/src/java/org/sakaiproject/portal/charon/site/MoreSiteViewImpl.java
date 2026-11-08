/**********************************************************************************
 * $URL$
 * $Id$
 ***********************************************************************************
 *
 * Copyright (c) 2003, 2004, 2005, 2006, 2007, 2008 The Sakai Foundation
 *
 * Licensed under the Educational Community License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *       http://www.opensource.org/licenses/ECL-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 **********************************************************************************/

package org.sakaiproject.portal.charon.site;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

import jakarta.servlet.http.HttpServletRequest;

import org.sakaiproject.portal.api.Portal;
import org.sakaiproject.site.api.Site;
import org.sakaiproject.site.api.SitePage;
import org.sakaiproject.site.api.ToolConfiguration;
import org.sakaiproject.tool.api.Session;
import org.sakaiproject.util.Web;

import static org.sakaiproject.portal.api.PortalConstants.PAGE_URL_SEGMENT;
import static org.sakaiproject.portal.api.PortalConstants.SITE_URL_SEGMENT;
import static org.sakaiproject.portal.api.PortalConstants.TOOL_URL_SEGMENT;

public class MoreSiteViewImpl extends AbstractSiteViewImpl
{
	/**
	 * @param siteHelper
	 * @param request
	 * @param session
	 * @param currentSiteId
	 */
	public MoreSiteViewImpl(PortalSiteHelperImpl siteHelper, HttpServletRequest request, Session session, String currentSiteId) {
		super(siteHelper, request, session, currentSiteId);
	}

	public Object getRenderContextObject()
	{
		// Pinned + recent (+ workspace + current) for sidebar/launcher organize; full site list
		// comes from GET /api/users/{id}/sites when the sites launcher opens.
		List<Site> favoritesSites;
		if (loggedIn) {
			favoritesSites = getPinnedAndRecentFavorites();
		} else {
			// Gateway: the public site list is small; keep the prior behavior of ensuring the
			// current site is represented and rendering the full tab list (includeGatewayNav.vm).
			ensureCurrentSiteIncluded();
			favoritesSites = getMySites();
		}

		moreSites = new ArrayList<>();

		String calendarToolId = serverConfigurationService.getString("portal.calendartool","sakai.schedule");
		String worksiteToolId = serverConfigurationService.getString("portal.worksitetool","sakai.sitesetup");

		String calendarToolUrl = null;
 		String worksiteToolUrl = null;
 		String mrphs_worksiteToolUrl = null;
 		String mrphs_worksiteUrl = null;
        if ( myWorkspaceSiteId != null ) {
            for (Site s : favoritesSites) {
                if (myWorkspaceSiteId.equals(s.getId()) ) {
                    mrphs_worksiteUrl = Web.returnUrl(request, SITE_URL_SEGMENT + Web.escapeUrl(siteHelper.getSiteEffectiveId(s)));
                    List<SitePage> pages = siteHelper.getPermittedPagesInOrder(s);
                    for (SitePage p : pages) {
                        List<ToolConfiguration> pTools = p.getTools();
                        for (ToolConfiguration placement : pTools) {
                            if ( calendarToolId.equals(placement.getToolId()) ) {
                                calendarToolUrl = Web.returnUrl(request, SITE_URL_SEGMENT + Web.escapeUrl(siteHelper.getSiteEffectiveId(s)) + PAGE_URL_SEGMENT + Web.escapeUrl(p.getId()));
                            } else if ( worksiteToolId.equals(placement.getToolId()) ) {
                                worksiteToolUrl = Web.returnUrl(request, SITE_URL_SEGMENT + Web.escapeUrl(siteHelper.getSiteEffectiveId(s)) + PAGE_URL_SEGMENT + Web.escapeUrl(p.getId()));
                                mrphs_worksiteToolUrl = Web.returnUrl(request, SITE_URL_SEGMENT + Web.escapeUrl(siteHelper.getSiteEffectiveId(s)) + TOOL_URL_SEGMENT + Web.escapeUrl(placement.getId()));
                            }
                        }
                    }
                }
            }
        }

		if ( mrphs_worksiteUrl != null ) {
			renderContextMap.put("mrphs_worksiteUrl", mrphs_worksiteUrl);
        }
		if ( calendarToolUrl != null ) {
			renderContextMap.put("calendarToolUrl", calendarToolUrl);
		}
		if ( worksiteToolUrl != null ) {
			renderContextMap.put("worksiteToolUrl", worksiteToolUrl);
			renderContextMap.put("mrphs_worksiteToolUrl", mrphs_worksiteToolUrl);
		}
		if (serverConfigurationService.getBoolean("portal.use.tutorial", true)) {
			renderContextMap.put("tutorial", true);
		} else {
			renderContextMap.put("tutorial", false);
		}

		renderContextMap.put("themeSwitcher", serverConfigurationService.getBoolean("portal.themes.switcher", true));

		int tabsToDisplay = serverConfigurationService.getInt(Portal.CONFIG_DEFAULT_TABS, 15);
		// The favorites bar shows tabsToDisplay sites plus one leading slot for the user's workspace.
		int favoritesBarSize = tabsToDisplay + 1;

		Set<String> pinnedSiteIds = new HashSet<>(siteHelper.getPinnedSites());
		List<Site> sitesForFavorites = favoritesSites.stream()
				.filter(site -> favoritesSites.indexOf(site) < favoritesBarSize || pinnedSiteIds.contains(site.getId()) || site.getId().equals(currentSiteId))
				.toList();

		List<Map<String, Object>> l = siteHelper.convertSitesToMaps(request, sitesForFavorites, prefix, currentSiteId, myWorkspaceSiteId, false, false,
				serverConfigurationService.getBoolean(Portal.CONFIG_AUTO_RESET, false), true, null, loggedIn);

		renderContextMap.put("maxFavoritesShown", tabsToDisplay);
		List<Map<String, Object>> pinned
			= l.stream().filter(map -> map.containsKey("isPinned") && (Boolean) map.get("isPinned"))
				.collect(Collectors.toList());

		renderContextMap.put("pinned", pinned);

		if (l.size() > favoritesBarSize) {
			List<Map<String, Object>> sublist = l.subList(0, favoritesBarSize);

			boolean listContainsCurrentSite = false;
			for (Map<String, Object> entry : sublist) {
				if (entry.get("isCurrentSite") instanceof Boolean ? (Boolean) entry.get("isCurrentSite") : false) {
					listContainsCurrentSite = true;
				}
			}

			if (!listContainsCurrentSite) {
				// If the current site wouldn't have been shown in the
				// subset of sites we're showing, swap it for the last
				// in the list.
				List<Map<String, Object>> modifiedList = new ArrayList<>(sublist);

				for (Map<String, Object> entry : l) {
					if (entry.get("isCurrentSite") instanceof Boolean ? (Boolean) entry.get("isCurrentSite") : false) {
						modifiedList.set(favoritesBarSize - 1, entry);
						break;
					}
				}

				sublist = modifiedList;
			}

			renderContextMap.put("tabsSites", sublist);
		} else {
		    renderContextMap.put("tabsSites", l);
		}

		boolean displayActive = serverConfigurationService.getBoolean("portal.always.display.active_sites",false);
		//If we don't always want to display it anyway, check to see if we need to display it
		if (!displayActive) {
			displayActive=Boolean.valueOf(moreSites.size() > 0);
		}

		renderContextMap.put("tabsMoreSitesShow", displayActive);

		// more dropdown
		if (!moreSites.isEmpty()) {
			List<Map<String, Object>> m = siteHelper.convertSitesToMaps(request, moreSites, prefix, currentSiteId, myWorkspaceSiteId, false, false,
					serverConfigurationService.getBoolean(Portal.CONFIG_AUTO_RESET, false), true, null, loggedIn);

			renderContextMap.put("tabsMoreSites", m);
		}

		return renderContextMap;
	}

	/**
	 * Ensure the current site is part of the (full) mySites list so it is represented in the
	 * rendered lists.
	 */
	private void ensureCurrentSiteIncluded() {
		List<Site> all = getMySites();
		if (all.stream().noneMatch(s -> s.getId().equals(currentSiteId))) {
			siteService.getOptionalSite(currentSiteId).ifPresent(all::add);
		}
	}

	/**
	 * Build the limited set of sites the favorites bar / organize-favorites list needs for a
	 * logged-in user: the workspace, the user's pinned sites (in pinned order), the recent sites,
	 * and the current site. Each is loaded individually (cached) instead of loading every site the
	 * user can access, mirroring {@link PortalSiteHelperImpl#getContextSitesWithPages}.
	 */
	private List<Site> getPinnedAndRecentFavorites() {
		List<Site> favorites = new ArrayList<>();
		Set<String> seen = new HashSet<>();
		// Match getSitesAtNode(showMyWorkspace): only include the workspace when it is configured
		// to be shown - it provides the leading slot and the worksite/calendar tool URLs.
		if (showMyWorkspace) {
			addSiteById(myWorkspaceSiteId, favorites, seen);
		}
		siteHelper.getPinnedSites().forEach(id -> addSiteById(id, favorites, seen));
		siteHelper.getRecentSites(session.getUserId()).forEach(id -> addSiteById(id, favorites, seen));
		addSiteById(currentSiteId, favorites, seen);
		return favorites;
	}

	/**
	 * Add the site with the given id to {@code sites}, skipping ids already seen (or null) so each
	 * site is loaded at most once.
	 */
	private void addSiteById(String siteId, List<Site> sites, Set<String> seen) {
		if (siteId == null || !seen.add(siteId)) {
			return;
		}
		siteService.getOptionalSite(siteId).ifPresent(sites::add);
	}

}
