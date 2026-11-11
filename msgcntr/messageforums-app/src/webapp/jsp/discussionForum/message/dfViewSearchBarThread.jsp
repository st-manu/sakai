<h:panelGroup layout="block" styleClass="sakai-table-toolbar sakai-no-print" rendered="#{!ForumTool.threadMoved}">
	<div class="sakai-table-toolbar__filters" role="group">
		<label class="sakai-form-label" for="msgForum:select_label">
			<h:outputText value="#{msgs.df_view}" />
		</label>
		<h:selectOneMenu id="select_label" styleClass="sakai-form-control sakai-form-control--sm"
				onchange="this.form.submit();"
				valueChangeListener="#{ForumTool.processValueChangedForMessageOrganize}"
				value="#{ForumTool.selectedMessageView}">
			<f:selectItem itemValue="thread" itemLabel="#{msgs.msg_organize_thread}" />
			<f:selectItem itemValue="date" itemLabel="#{msgs.msg_organize_date_asc}" />
			<f:selectItem itemValue="date_desc" itemLabel="#{msgs.msg_organize_date_desc}" />
			<f:selectItem itemValue="unread" itemLabel="#{msgs.msg_organize_unread}" />
		</h:selectOneMenu>
	</div>
</h:panelGroup>

<h:messages styleClass="sakai-banner sakai-banner--error" id="errorMessages" rendered="#{! empty facesContext.maximumSeverity}" />
<div class="sakai-banner sakai-banner--success" id="gradesSavedDiv" style="display:none" role="alert" aria-live="assertive">
	<h:outputText value="#{msgs.cdfm_grade_successful}"/>
</div>
