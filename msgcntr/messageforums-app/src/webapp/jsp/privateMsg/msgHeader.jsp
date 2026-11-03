<%--********************* Message list toolbar *********************--%>
<script>includeLatestJQuery("msgcntr");</script>
<script src="/messageforums-tool/js/sak-10625.js"></script>
<script src="/messageforums-tool/js/bulkops.js"></script>
<script src="/library/js/lang-datepicker/lang-datepicker.js"></script>

<script>
  $(document).ready(function() {
    localDatePicker({
      input: '#prefs_pvt_form\\:searchFromDate',
      useTime: 0,
      parseFormat: 'YYYY-MM-DD',
      allowEmptyDate: true,
      val: '<h:outputText value="#{PrivateMessagesTool.searchFromDate}"><f:convertDateTime pattern="yyyy-MM-dd"/></h:outputText>',
      ashidden: { iso8601: 'searchFromDateISO8601' }
    });
    localDatePicker({
      input: '#prefs_pvt_form\\:searchToDate',
      useTime: 0,
      parseFormat: 'YYYY-MM-DD',
      allowEmptyDate: true,
      val: '<h:outputText value="#{PrivateMessagesTool.searchToDate}"><f:convertDateTime pattern="yyyy-MM-dd"/></h:outputText>',
      ashidden: { iso8601: 'searchToDateISO8601' }
    });
  });
</script>

<div class="sakai-table-toolbar sakai-messages__list-toolbar">
  <div class="sakai-table-toolbar__filters">
    <h:panelGroup styleClass="sakai-table-searchFilter">
      <h:outputLabel for="search_text"><h:outputText value="#{msgs.pvt_search_text}" /></h:outputLabel>
      <f:verbatim><div class="sakai-table-searchFilterControls"><div class="sakai-table-searchFilter-inputWrapper"></f:verbatim>
        <h:inputText value="#{PrivateMessagesTool.searchText}" id="search_text" styleClass="sakai-table-searchFilter-searchField sakai-form-control sakai-form-control--sm" />
      <f:verbatim></div><button type="button" id="search-options-toggle" class="sakai-btn sakai-btn-ghost" aria-controls="adv_input" aria-expanded="false"></f:verbatim>
        <f:verbatim><span class="bi bi-sliders" aria-hidden="true"></span><span class="visually-hidden"></f:verbatim><h:outputText value="#{msgs.pvt_search_options}" /><f:verbatim></span></f:verbatim>
      <f:verbatim></button></div></f:verbatim>
    </h:panelGroup>

    <h:panelGroup styleClass="sakai-table-viewFilter">
      <h:outputLabel for="viewlist"><h:outputText value="#{msgs.msg_view}" /></h:outputLabel>
      <h:selectOneMenu id="viewlist" styleClass="sakai-form-control sakai-form-control--sm" onchange="this.form.submit();"
        valueChangeListener="#{PrivateMessagesTool.processChangeSelectView}" value="#{PrivateMessagesTool.selectView}">
        <f:selectItem itemLabel="#{msgs.pvt_view_all_msgs}" itemValue="none"/>
        <f:selectItem itemLabel="#{msgs.pvt_view_conversation}" itemValue="threaded"/>
      </h:selectOneMenu>
    </h:panelGroup>
  </div>
</div>

<f:verbatim><div id="adv_input" class="sakai-messages__search-options" hidden></f:verbatim>
  <h:panelGroup styleClass="sakai-actions sakai-messages__search-actions">
    <h:commandButton id="search_button" styleClass="sakai-btn sakai-btn-primary" value="#{msgs.pvt_search}"
      action="#{PrivateMessagesTool.processSearch}" />
    <h:commandButton id="clear_search_button" styleClass="sakai-btn sakai-btn-secondary" value="#{msgs.pvt_clear_search}"
      action="#{PrivateMessagesTool.processClearSearch}" />
  </h:panelGroup>

  <h:outputText value="#{msgs.pvt_search_in}" styleClass="sakai-form-section__title" />
  <div class="sakai-messages__search-scope">
    <h:panelGroup styleClass="sakai-form-choice">
      <h:selectBooleanCheckbox value="#{PrivateMessagesTool.searchOnSubject}" id="subject" />
      <h:outputLabel for="subject"><h:outputText value="#{msgs.pvt_subject}" /></h:outputLabel>
    </h:panelGroup>
    <h:panelGroup styleClass="sakai-form-choice">
      <h:selectBooleanCheckbox value="#{PrivateMessagesTool.searchOnAuthor}" id="author" />
      <h:outputLabel for="author"><h:outputText value="#{msgs.pvt_authby}" /></h:outputLabel>
    </h:panelGroup>
    <h:panelGroup styleClass="sakai-form-choice">
      <h:selectBooleanCheckbox value="#{PrivateMessagesTool.searchOnBody}" id="body" />
      <h:outputLabel for="body"><h:outputText value="#{msgs.pvt_body}" /></h:outputLabel>
    </h:panelGroup>
    <h:panelGroup styleClass="sakai-form-choice">
      <h:selectBooleanCheckbox value="#{PrivateMessagesTool.searchOnLabel}" id="label" />
      <h:outputLabel for="label"><h:outputText value="#{msgs.pvt_label}" /></h:outputLabel>
    </h:panelGroup>
    <h:panelGroup styleClass="sakai-form-choice">
      <h:selectBooleanCheckbox value="#{PrivateMessagesTool.searchOnDate}" id="search_by_date" />
      <h:outputLabel for="search_by_date"><h:outputText value="#{msgs.pvt_date_range}" /></h:outputLabel>
    </h:panelGroup>
    <h:panelGroup styleClass="sakai-form-choice" rendered="#{PrivateMessagesTool.canUseTags}">
      <h:selectBooleanCheckbox value="#{PrivateMessagesTool.searchOnTags}" id="search_by_tags" />
      <h:outputLabel for="search_by_tags"><h:outputText value="#{msgs.pvt_tags_header}" /></h:outputLabel>
    </h:panelGroup>
  </div>

  <div class="sakai-messages__search-fields">
    <h:panelGroup styleClass="sakai-messages__search-extra" id="pvt_selected_label">
      <h:outputLabel for="selectedSearchLabel" styleClass="sakai-form-label"><h:outputText value="#{msgs.pvt_label}"/></h:outputLabel>
      <h:selectOneListbox size="1" id="selectedSearchLabel" styleClass="sakai-form-control" value="#{PrivateMessagesTool.selectedSearchLabel}">
        <f:selectItem itemValue="pvt_priority_normal" itemLabel="#{msgs.pvt_priority_normal}"/>
        <f:selectItem itemValue="pvt_priority_low" itemLabel="#{msgs.pvt_priority_low}"/>
        <f:selectItem itemValue="pvt_priority_high" itemLabel="#{msgs.pvt_priority_high}"/>
      </h:selectOneListbox>
    </h:panelGroup>

    <h:panelGroup styleClass="sakai-messages__search-extra" id="pvt_beg_date">
      <h:outputLabel for="searchFromDate" styleClass="sakai-form-label"><h:outputText value="#{msgs.pvt_beg_date}"/></h:outputLabel>
      <h:inputText value="#{PrivateMessagesTool.searchFromDateString}" id="searchFromDate" styleClass="sakai-form-control"/>
    </h:panelGroup>

    <h:panelGroup styleClass="sakai-messages__search-extra" id="pvt_end_date">
      <h:outputLabel for="searchToDate" styleClass="sakai-form-label"><h:outputText value="#{msgs.pvt_end_date}"/></h:outputLabel>
      <h:inputText value="#{PrivateMessagesTool.searchToDateString}" id="searchToDate" styleClass="sakai-form-control"/>
    </h:panelGroup>

    <h:panelGroup styleClass="sakai-messages__search-extra sakai-messages__search-tags" id="pvt_selected_tags" rendered="#{PrivateMessagesTool.canUseTags}">
      <h:outputLabel styleClass="sakai-form-label"><h:outputText value="#{msgs.pvt_tags_header}"/></h:outputLabel>
      <h:inputHidden value="#{PrivateMessagesTool.selectedTags}" id="tag_selector" />
      <sakai-tag-selector
          id="tag-selector"
          input-id="prefs_pvt_form:tag_selector"
          selected-ids='<h:outputText value="#{PrivateMessagesTool.selectedTags}"/>'
          collection-id='<h:outputText value="#{PrivateMessagesTool.getSiteId()}"/>'
          site-id='<h:outputText value="#{PrivateMessagesTool.getSiteId()}"/>'
          tool='<h:outputText value="#{PrivateMessagesTool.getTagTool()}"/>'
          add-new="false"
      ></sakai-tag-selector>
    </h:panelGroup>
  </div>
<f:verbatim></div></f:verbatim>
