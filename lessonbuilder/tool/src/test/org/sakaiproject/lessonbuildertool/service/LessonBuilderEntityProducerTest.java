/**
 * Copyright (c) 2003-2017 The Apereo Foundation
 *
 * Licensed under the Educational Community License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *             http://opensource.org/licenses/ecl2
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.sakaiproject.lessonbuildertool.service;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.xml.parsers.DocumentBuilderFactory;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertNull;
import static org.junit.Assert.assertTrue;
import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;
import org.mockito.Mock;
import org.mockito.Mockito;
import static org.mockito.Mockito.atLeastOnce;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;
import org.mockito.junit.MockitoJUnit;
import org.mockito.junit.MockitoRule;
import org.sakaiproject.entity.api.Reference;
import org.sakaiproject.lessonbuildertool.SimplePage;
import org.sakaiproject.lessonbuildertool.SimplePageImpl;
import org.sakaiproject.lessonbuildertool.SimplePageItem;
import org.sakaiproject.lessonbuildertool.SimplePageItemImpl;
import org.sakaiproject.lessonbuildertool.model.SimplePageToolDao;
import org.w3c.dom.Document;
import org.w3c.dom.Element;

public class LessonBuilderEntityProducerTest {

    private LessonBuilderEntityProducer producer;

    @Rule
    public MockitoRule rule = MockitoJUnit.rule();

    @Mock
    private SimplePageToolDao dao;

    @Mock
    private Reference ref;

    @Before
    public void setUp() {
        producer = new LessonBuilderEntityProducer();
        producer.setSimplePageToolDao(dao);
    }

    @Test
    public void testParseEntityReferenceNotOurs() {
        assertFalse(producer.parseEntityReference("/else", ref));
        assertFalse(producer.parseEntityReference("/", ref));
        assertFalse(producer.parseEntityReference("", ref));
    }

    @Test
    public void testParseEntityReferenceNoItem() {
        assertFalse(producer.parseEntityReference("/lessonbuilder/item", ref));
    }

    @Test
    public void testParseEntityReferenceNoSite() {
        assertFalse(producer.parseEntityReference("/lessonbuilder/site", ref));
    }

    @Test
    public void testParseEntityReferenceNoPage() {
        assertFalse(producer.parseEntityReference("/lessonbuilder/page", ref));
    }

    @Test
    public void testParseEntityReferencePageNotInt() {
        assertFalse(producer.parseEntityReference("/lessonbuilder/page/notNumber", ref));
    }

    @Test
    public void testParseEntityReferencePageMissingId() {
        assertFalse(producer.parseEntityReference("/lessonbuilder/page/10", ref));
    }

    @Test
    public void testParseEntityReferencePageWithId() {
        SimplePage page = Mockito.mock(SimplePage.class);
        Mockito.when(page.getSiteId()).thenReturn("siteId");
        Mockito.when(dao.getPage(10)).thenReturn(page);
        assertTrue(producer.parseEntityReference("/lessonbuilder/page/10", ref));
        Mockito.verify(ref).set("sakai:lessonbuilder", "page", "/page/10", null, "siteId");
    }

    @Test
    public void testParseEntityReferenceItemWithId() {
        SimplePageItem item = Mockito.mock(SimplePageItem.class);
        Mockito.when(dao.findItem(10)).thenReturn(item);
        Mockito.when(item.getPageId()).thenReturn(11L);
        SimplePage page = Mockito.mock(SimplePage.class);
        Mockito.when(page.getSiteId()).thenReturn("siteId");
        Mockito.when(dao.getPage(11)).thenReturn(page);
        assertTrue(producer.parseEntityReference("/lessonbuilder/item/10", ref));
        Mockito.verify(ref).set("sakai:lessonbuilder", "item", "/item/10", null, "siteId");
    }

    @Test
    public void testParseEntityReferenceSite() {
        assertTrue(producer.parseEntityReference("/lessonbuilder/site/siteId", ref));
        Mockito.verify(ref).set("sakai:lessonbuilder", "site", "/site/siteId", null, "/site/siteId");
    }

    /**
     * findReferencedPagesByItems identifies parent-child links from PAGE items.
     */
    @Test
    public void testFindReferencedPagesByItems() {
        String siteId = "test-site-1";

        SimplePage parentPage = newPage(100L, siteId, "Parent Page", "tool-abc", null, null);
        SimplePage subpage1 = newPage(101L, siteId, "Subpage 1", "tool-abc", 100L, 100L);
        SimplePage subpage2 = newPage(102L, siteId, "Subpage 2", "tool-abc", 100L, 100L);

        List<SimplePageItem> allItems = new ArrayList<>();
        allItems.add(pageItem(1L, 100L, "101"));
        allItems.add(pageItem(2L, 100L, "102"));
        SimplePageItem textItem = new SimplePageItemImpl();
        textItem.setId(3L);
        textItem.setPageId(100L);
        textItem.setType(SimplePageItem.TEXT);
        textItem.setHtml("Some text");
        allItems.add(textItem);

        when(dao.getSitePages(siteId)).thenReturn(List.of(parentPage, subpage1, subpage2));
        when(dao.findItemsOnPage(100L)).thenReturn(allItems);
        when(dao.getPage(101L)).thenReturn(subpage1);
        when(dao.getPage(102L)).thenReturn(subpage2);

        Map<Long, List<Long>> result = producer.findReferencedPagesByItems(siteId);

        assertNotNull(result);
        assertTrue(result.containsKey(100L));
        List<Long> referencedPages = result.get(100L);
        assertEquals(2, referencedPages.size());
        assertTrue(referencedPages.contains(101L));
        assertTrue(referencedPages.contains(102L));
    }

    /**
     * Pseudo-orphan intermediate pages (toolId "0") must still be scanned so nested
     * subpages are discovered when re-importing a previously broken site.
     */
    @Test
    public void testFindReferencedPagesByItemsIncludesPseudoOrphanIntermediates() {
        String siteId = "test-site-pseudo";

        // Broken import left Subpage 1 as toolId "0" with null parent, but it still has a PAGE item
        SimplePage page1 = newPage(200L, siteId, "Page 1", "sakai-page-tool", null, null);
        SimplePage sub1 = newPage(201L, siteId, "Subpage 1", "0", null, null);
        SimplePage nested = newPage(202L, siteId, "Nested", "0", null, null);

        when(dao.getSitePages(siteId)).thenReturn(List.of(page1, sub1, nested));
        when(dao.findItemsOnPage(200L)).thenReturn(List.of(pageItem(1L, 200L, "201")));
        when(dao.findItemsOnPage(201L)).thenReturn(List.of(pageItem(2L, 201L, "202")));
        when(dao.getPage(201L)).thenReturn(sub1);
        when(dao.getPage(202L)).thenReturn(nested);

        Map<Long, List<Long>> result = producer.findReferencedPagesByItems(siteId);

        assertTrue(result.containsKey(200L));
        assertEquals(List.of(201L), result.get(200L));
        assertTrue("Pseudo-orphan intermediate must contribute nested refs", result.containsKey(201L));
        assertEquals(List.of(202L), result.get(201L));
    }

    /**
     * Hierarchy maps from item references (including nested).
     */
    @Test
    public void testHierarchyCalculationFromReferences() {
        Map<Long, List<Long>> subpageRefs = new HashMap<>();
        subpageRefs.put(100L, List.of(101L, 102L));
        subpageRefs.put(101L, List.of(103L));

        Map<Long, Long> pageMap = new HashMap<>();
        pageMap.put(100L, 100L);
        pageMap.put(101L, 101L);
        pageMap.put(102L, 102L);
        pageMap.put(103L, 103L);

        Map<Long, Long> calculatedParentMap = new HashMap<>();
        Map<Long, Long> calculatedTopParentMap = new HashMap<>();

        producer.buildParentMapFromReferences(subpageRefs, pageMap, calculatedParentMap);
        producer.calculateTopParentMap(calculatedParentMap, calculatedTopParentMap);

        assertEquals(Long.valueOf(100L), calculatedParentMap.get(101L));
        assertEquals(Long.valueOf(100L), calculatedParentMap.get(102L));
        assertEquals(Long.valueOf(101L), calculatedParentMap.get(103L));

        assertEquals(Long.valueOf(100L), calculatedTopParentMap.get(101L));
        assertEquals(Long.valueOf(100L), calculatedTopParentMap.get(102L));
        assertEquals(Long.valueOf(100L), calculatedTopParentMap.get(103L));
    }

    /**
     * Selective import only links pages present in pageMap.
     */
    @Test
    public void testHierarchyCalculationWithSelectiveImport() {
        Map<Long, Long> pageMap = new HashMap<>();
        pageMap.put(100L, 5000L);
        pageMap.put(101L, 5001L);

        Map<Long, List<Long>> subpageRefs = new HashMap<>();
        subpageRefs.put(100L, List.of(101L, 102L));
        subpageRefs.put(200L, List.of(103L));

        Map<Long, Long> calculatedParentMap = new HashMap<>();
        producer.buildParentMapFromReferences(subpageRefs, pageMap, calculatedParentMap);

        assertEquals(Long.valueOf(100L), calculatedParentMap.get(101L));
        assertFalse(calculatedParentMap.containsKey(102L));
        assertFalse(calculatedParentMap.containsKey(103L));
    }

    /**
     * Cycles in the parent map must not hang and must not invent a topParent.
     */
    @Test
    public void testCalculateTopParentMapDetectsCycles() {
        Map<Long, Long> calculatedParentMap = new HashMap<>();
        calculatedParentMap.put(1L, 2L);
        calculatedParentMap.put(2L, 1L);

        Map<Long, Long> calculatedTopParentMap = new HashMap<>();
        producer.calculateTopParentMap(calculatedParentMap, calculatedTopParentMap);

        assertTrue(calculatedTopParentMap.isEmpty());
    }

    /**
     * XML parent attributes fill gaps when item refs are unavailable (cross-server archive).
     */
    @Test
    public void testFillUnresolvedParentsFromXml() throws Exception {
        Document doc = DocumentBuilderFactory.newInstance().newDocumentBuilder().newDocument();
        Element pageEl = doc.createElement("page");
        pageEl.setAttribute("parent", "100");

        Map<Long, Element> pageElementMap = new HashMap<>();
        pageElementMap.put(101L, pageEl);

        Map<Long, Long> pageMap = new HashMap<>();
        pageMap.put(100L, 5000L);
        pageMap.put(101L, 5001L);

        Map<Long, Long> calculatedParentMap = new HashMap<>();
        producer.fillUnresolvedParentsFromXml(pageElementMap, pageMap, calculatedParentMap);

        assertEquals(Long.valueOf(100L), calculatedParentMap.get(101L));
    }

    /**
     * parent="0" / empty must not invent relationships (matches the old broken export).
     */
    @Test
    public void testFillUnresolvedParentsFromXmlIgnoresZeroParent() throws Exception {
        Document doc = DocumentBuilderFactory.newInstance().newDocumentBuilder().newDocument();
        Element pageEl = doc.createElement("page");
        pageEl.setAttribute("parent", "0");

        Map<Long, Element> pageElementMap = new HashMap<>();
        pageElementMap.put(101L, pageEl);

        Map<Long, Long> pageMap = new HashMap<>();
        pageMap.put(100L, 5000L);
        pageMap.put(101L, 5001L);

        Map<Long, Long> calculatedParentMap = new HashMap<>();
        producer.fillUnresolvedParentsFromXml(pageElementMap, pageMap, calculatedParentMap);

        assertFalse(calculatedParentMap.containsKey(101L));
    }

    /**
     * SAK-52251: after import, subpages must not remain as pseudo-orphans
     * (toolId "0", parent/topParent null/0). They must share the top Lesson toolId
     * and point parent/topParent at the new top-level page.
     *
     * Expected shape (new IDs):
     *   Page 1:   toolId=sakai-page-xyz, parent=null, topParent=null
     *   Subpage1: toolId=sakai-page-xyz, parent=Page1, topParent=Page1
     *   Subpage2: toolId=sakai-page-xyz, parent=Page1, topParent=Page1
     */
    @Test
    public void testImportAppliesHierarchyAndToolIdLikeSiteImport() {
        String destSiteId = "site-2";
        String realToolId = "sakai-page-xyz";

        // Old source ids
        long oldPage1 = 7953115L;
        long oldSub1 = 7953116L;
        long oldSub2 = 7953117L;

        // New destination ids after makePage("0", site, title, null, null)
        long newPage1 = 9001L;
        long newSub1 = 9002L;
        long newSub2 = 9003L;

        SimplePage importedPage1 = newPage(newPage1, destSiteId, "Page 1", "0", null, null);
        SimplePage importedSub1 = newPage(newSub1, destSiteId, "Subpage 1", "0", null, null);
        SimplePage importedSub2 = newPage(newSub2, destSiteId, "Subpage 2", "0", null, null);

        Map<Long, Long> pageMap = new HashMap<>();
        pageMap.put(oldPage1, newPage1);
        pageMap.put(oldSub1, newSub1);
        pageMap.put(oldSub2, newSub2);

        Map<Long, List<Long>> subpageRefs = new HashMap<>();
        subpageRefs.put(oldPage1, List.of(oldSub1, oldSub2));

        Map<Long, Long> calculatedParentMap = new HashMap<>();
        Map<Long, Long> calculatedTopParentMap = new HashMap<>();
        producer.buildParentMapFromReferences(subpageRefs, pageMap, calculatedParentMap);
        producer.calculateTopParentMap(calculatedParentMap, calculatedTopParentMap);

        when(dao.getPage(newPage1)).thenReturn(importedPage1);
        when(dao.getPage(newSub1)).thenReturn(importedSub1);
        when(dao.getPage(newSub2)).thenReturn(importedSub2);
        when(dao.quickUpdate(Mockito.any())).thenReturn(true);

        int hierarchyUpdates = producer.applyCalculatedHierarchy(pageMap, calculatedParentMap, calculatedTopParentMap);
        assertEquals(2, hierarchyUpdates);

        // Simulate placement creation assigning the real toolId to the top-level page
        importedPage1.setToolId(realToolId);
        importedPage1.setParent(null);
        importedPage1.setTopParent(null);

        int toolIdUpdates = producer.updateChildPageToolIds(pageMap, calculatedTopParentMap);
        assertEquals(2, toolIdUpdates);

        // Top-level Lesson stays a root
        assertEquals(realToolId, importedPage1.getToolId());
        assertNull(importedPage1.getParent());
        assertNull(importedPage1.getTopParent());

        // Subpages are linked and share the Lesson toolId (not "0")
        assertEquals(Long.valueOf(newPage1), importedSub1.getParent());
        assertEquals(Long.valueOf(newPage1), importedSub1.getTopParent());
        assertEquals(realToolId, importedSub1.getToolId());

        assertEquals(Long.valueOf(newPage1), importedSub2.getParent());
        assertEquals(Long.valueOf(newPage1), importedSub2.getTopParent());
        assertEquals(realToolId, importedSub2.getToolId());

        verify(dao, atLeastOnce()).quickUpdate(importedSub1);
        verify(dao, atLeastOnce()).quickUpdate(importedSub2);
    }

    /**
     * Re-import from a site whose subpages are already pseudo-orphans: item refs on the
     * top Lesson (and on intermediate pseudo-orphans) still rebuild hierarchy + toolId.
     */
    @Test
    public void testReimportFromPseudoOrphanSourceRebuildsNestedHierarchy() {
        String sourceSiteId = "site-2-broken";
        String destSiteId = "site-3";
        String realToolId = "dest-tool-placement";

        // Source: Page1 OK; Sub1 and Nested are pseudo-orphans (toolId 0 / null parents)
        long srcPage1 = 100L;
        long srcSub1 = 101L;
        long srcNested = 102L;

        SimplePage srcPage1Page = newPage(srcPage1, sourceSiteId, "Page 1", "src-tool", null, null);
        SimplePage srcSub1Page = newPage(srcSub1, sourceSiteId, "Subpage 1", "0", null, null);
        SimplePage srcNestedPage = newPage(srcNested, sourceSiteId, "Nested", "0", null, null);

        when(dao.getSitePages(sourceSiteId)).thenReturn(List.of(srcPage1Page, srcSub1Page, srcNestedPage));
        when(dao.findItemsOnPage(srcPage1)).thenReturn(List.of(pageItem(1L, srcPage1, "101")));
        when(dao.findItemsOnPage(srcSub1)).thenReturn(List.of(pageItem(2L, srcSub1, "102")));
        when(dao.getPage(srcSub1)).thenReturn(srcSub1Page);
        when(dao.getPage(srcNested)).thenReturn(srcNestedPage);

        Map<Long, List<Long>> subpageRefs = producer.findReferencedPagesByItems(sourceSiteId);
        assertEquals(List.of(101L), subpageRefs.get(100L));
        assertEquals(List.of(102L), subpageRefs.get(101L));

        long newPage1 = 2001L;
        long newSub1 = 2002L;
        long newNested = 2003L;

        SimplePage destPage1 = newPage(newPage1, destSiteId, "Page 1", "0", null, null);
        SimplePage destSub1 = newPage(newSub1, destSiteId, "Subpage 1", "0", null, null);
        SimplePage destNested = newPage(newNested, destSiteId, "Nested", "0", null, null);

        Map<Long, Long> pageMap = new HashMap<>();
        pageMap.put(srcPage1, newPage1);
        pageMap.put(srcSub1, newSub1);
        pageMap.put(srcNested, newNested);

        Map<Long, Long> calculatedParentMap = new HashMap<>();
        Map<Long, Long> calculatedTopParentMap = new HashMap<>();
        producer.buildParentMapFromReferences(subpageRefs, pageMap, calculatedParentMap);
        producer.calculateTopParentMap(calculatedParentMap, calculatedTopParentMap);

        when(dao.getPage(newPage1)).thenReturn(destPage1);
        when(dao.getPage(newSub1)).thenReturn(destSub1);
        when(dao.getPage(newNested)).thenReturn(destNested);
        when(dao.quickUpdate(Mockito.any())).thenReturn(true);

        assertEquals(2, producer.applyCalculatedHierarchy(pageMap, calculatedParentMap, calculatedTopParentMap));

        destPage1.setToolId(realToolId);
        assertEquals(2, producer.updateChildPageToolIds(pageMap, calculatedTopParentMap));

        assertEquals(Long.valueOf(newPage1), destSub1.getParent());
        assertEquals(Long.valueOf(newPage1), destSub1.getTopParent());
        assertEquals(realToolId, destSub1.getToolId());

        assertEquals(Long.valueOf(newSub1), destNested.getParent());
        assertEquals(Long.valueOf(newPage1), destNested.getTopParent());
        assertEquals(realToolId, destNested.getToolId());
    }

    /**
     * Top-level pages are not in calculatedTopParentMap, so their toolId is left alone.
     */
    @Test
    public void testUpdateChildPageToolIdsDoesNotTouchTopLevel() {
        Map<Long, Long> pageMap = new HashMap<>();
        pageMap.put(100L, 5000L);

        SimplePage top = newPage(5000L, "site", "Page 1", "real-tool", null, null);

        int updates = producer.updateChildPageToolIds(pageMap, new HashMap<>());
        assertEquals(0, updates);
        assertEquals("real-tool", top.getToolId());
        verify(dao, never()).quickUpdate(top);
    }

    private static SimplePage newPage(long pageId, String siteId, String title, String toolId, Long parent, Long topParent) {
        SimplePage page = new SimplePageImpl();
        page.setPageId(pageId);
        page.setSiteId(siteId);
        page.setTitle(title);
        page.setToolId(toolId);
        page.setParent(parent);
        page.setTopParent(topParent);
        return page;
    }

    private static SimplePageItem pageItem(long id, long pageId, String sakaiId) {
        SimplePageItem item = new SimplePageItemImpl();
        item.setId(id);
        item.setPageId(pageId);
        item.setType(SimplePageItem.PAGE);
        item.setSakaiId(sakaiId);
        return item;
    }
}
