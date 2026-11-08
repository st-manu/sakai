<f:view>
    <c:set var="chatMenuCurrent" value="main" />
    <sakai:view title="#{msgs['custom.chatroom']}">
        <script src='/sakai-chat-tool/js/chat.js<h:outputText value="#{Portal.CDNQuery}" />' type="module"></script>
        <div class="sakai-chat">
        <h:form id="topForm">
            <h:inputHidden id="chatidhidden" value="#{ChatTool.currentChatChannelId}" />
            <%@ include file="chatMenu.jsp" %>
            <div class="sakai-chat__panel">
                <div class="sakai-chat__controls">
                    <sakai:instruction_message value="#{ChatTool.datesMessage}" rendered="#{ChatTool.datesMessage ne null}" />
                    <sakai:view_title value="#{ChatTool.viewingChatRoomText}"/>
                    <h:panelGroup styleClass="sakai-chat__options">
                        <h:panelGroup styleClass="sakai-chat__option">
                            <h:outputLabel for="viewOptions" value="#{msgs.view}" />
                            <h:selectOneMenu id="viewOptions" value="#{ChatTool.viewOptions}">
                                <f:selectItem itemValue="1" itemLabel="#{msgs.timeOnly}" />
                                <f:selectItem itemValue="3" itemLabel="#{msgs.timeAndDate}" />
                                <f:selectItem itemValue="2" itemLabel="#{msgs.dateOnly}" />
                                <f:selectItem itemValue="0" itemLabel="#{msgs.neitherDateOrTime}" />
                                <f:selectItem itemValue="4" itemLabel="#{msgs.uniqueid}" />
                            </h:selectOneMenu>
                        </h:panelGroup>
                        <h:panelGroup styleClass="sakai-chat__option">
                            <h:outputLabel for="messageOptions" value="#{msgs['combox.viewfrom']}" />
                            <h:selectOneMenu id="messageOptions" value="#{ChatTool.messageOptions}">
                                <f:selectItems value="#{ChatTool.messageOptionsList}" />
                            </h:selectOneMenu>
                        </h:panelGroup>
                        <h:panelGroup styleClass="sakai-chat__option">
                            <h:commandButton type="submit" id="submit" value="#{msgs['control.submit']}" styleClass="sakai-btn sakai-btn-secondary" />
                        </h:panelGroup>
                    </h:panelGroup>
                </div>

                <ul class="sakai-segmented-control sakai-chat__tabs" role="tablist">
                    <li class="sakai-segmented-control__item" role="presentation">
                        <button type="button" class="sakai-segmented-control__btn sakai-chat__tab" role="tab" id="chatTabMessages" aria-controls="chatListWrapperCont" aria-selected="true" tabindex="0" data-chat-tab="chatListWrapperCont">
                            <h:outputText value="#{msgs.messages}" />
                        </button>
                    </li>
                    <li class="sakai-segmented-control__item" role="presentation">
                        <button type="button" class="sakai-segmented-control__btn sakai-chat__tab" role="tab" id="chatTabPresence" aria-controls="chatPresenceWrapper" aria-selected="false" tabindex="-1" data-chat-tab="chatPresenceWrapper">
                            <h:outputText value="#{msgs.lay_user}" />
                        </button>
                    </li>
                </ul>

                <div class="sakai-chat__body" id="chatLeft">
                    <div id="chatListWrapperCont" class="chatListWrapperCont" role="tabpanel" aria-labelledby="chatTabMessages">
                        <div id="chatListWrapper" class="chatListWrapper">
                            <div class="sakai-chat__note">
                                <h:outputText value="#{msgs.lay_note}" rendered="#{ChatTool.canRenderAllMessages}" />
                                <h:outputFormat value="#{msgs.lay_restricted_note_days}" rendered="#{ChatTool.canRenderDateMessages}" >
                                    <f:param value="#{ChatTool.currentChannel.chatChannel.timeParam}" />
                                </h:outputFormat>
                                <h:outputFormat value="#{msgs.lay_restricted_note_messages}" rendered="#{ChatTool.canRenderNumberMessages}" >
                                    <f:param value="#{ChatTool.currentChannel.chatChannel.numberParam}" />
                                </h:outputFormat>
                                <h:outputText value="#{msgs.lay_restricted_note_none}" rendered="#{ChatTool.canRenderNoMessages}" />
                            </div>
                            <div id="chat2_messages_shown_total" class="shown_total"></div>
                            <h:messages  rendered="#{!empty facesContext.maximumSeverity}" />
                            <div id="Monitor" class="chatListMonitor">
                                <%@ include file="roomMonitor.jspf" %>
                            </div>
                        </div>
                        <button type="button" class="scrollBottom sakai-chat__scroll-bottom sakai-is-hidden" title="<h:outputText value="#{ChatTool.unreadedMessagesText}" />">
                            <span class="newMessages sakai-chat__unread"></span>
                            <i class="si si-chevron-down" aria-hidden="true"></i>
                            <span class="visually-hidden"><h:outputText value="#{msgs.unreaded}" /></span>
                        </button>
                    </div>
                    <div id="chatPresenceWrapper" class="chatListOnline is-inactive" role="tabpanel" aria-labelledby="chatTabPresence">
                        <h3 class="sakai-chat__presence-head">
                            <h:outputText value="#{msgs.lay_user}" />
                        </h3>
                        <ul id="presence" class="presenceList"></ul>
                    </div>
                </div>
                <div class="sakai-chat__footer">
                    <f:subview id="controlPanel" rendered="#{ChatTool.canPost}">
                        <div>
                            <div id="errorSubmit" class="sakai-banner sakai-banner--error sakai-is-hidden">
                                <h:outputText value="#{msgs['therewaspro']}" />
                            </div>
                            <div id="missingChannel" class="sakai-banner sakai-banner--error sakai-is-hidden">
                                <h:outputText value="#{msgs['missingchannel1']}" />
                                <h:outputLink value="#{ChatTool.toolUrl}">
                                    <h:outputText value="#{msgs['here']}" />
                                </h:outputLink>
                                <h:outputText value="#{msgs['missingchannel2']}" />
                            </div>
                            <label for="topForm:controlPanel:message">
                                <h:outputText value="#{msgs['control.lab']}" />
                            </label>
                            <c:out value="<textarea id='topForm:controlPanel:message' class='sakai-form-control sakai-chat__textarea' value='" escapeXml="false" /><h:outputText value="#{ChatTool.newMessageText}" /><c:out value="' rows='3' cols='125'></textarea>" escapeXml="false" />
                            <div class="sakai-chat__actions">
                                <h:commandButton type="button" id="submit" value="#{msgs['control.post']}" styleClass="sakai-btn sakai-btn-primary" />
                                <h:commandButton type="button" id="reset" value="#{msgs['control.clear']}" styleClass="sakai-btn sakai-btn-secondary" />
                            </div>
                        </div>
                    </f:subview>
                </div>
            </div>
        </h:form>

        <t:div styleClass="sakai-banner sakai-banner--info chat-post-warning" rendered="#{!ChatTool.canPost && ChatTool.datesRestricted}">
            <h:outputText value="#{msgs.custom_date_restricted}" />
            <h:outputText value="#{ChatTool.datesMessage}" />
        </t:div>

        <div class="modal fade" tabindex="-1" role="dialog" id="removemodal">
            <div class="modal-dialog modal-dialog-centered" role="document">
                <div class="modal-content">
                    <div class="modal-header">
                        <h1 class="modal-title"><h:outputText value="#{msgs['delete.delete']}" /></h1>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <p><h:outputText value="#{msgs['delete.sure']}" /></p>
                        <c:out value="<table class='sakai-table sakai-chat__details'>" escapeXml="false" />
                            <c:out value="<tr>" escapeXml="false" />
                                <c:out value="<th>${msgs['gen.from']}</th>" escapeXml="false" />
                                <c:out value="<td id='owner'></td>" escapeXml="false" />
                            <c:out value="</tr>" escapeXml="false" />
                            <c:out value="<tr>" escapeXml="false" />
                                <c:out value="<th>${msgs['gen.date']}</th>" escapeXml="false" />
                                <c:out value="<td id='date'></td>" escapeXml="false" />
                            <c:out value="</tr>" escapeXml="false" />
                            <c:out value="<tr>" escapeXml="false" />
                                <c:out value="<th>${msgs['gen.mess']}</th>" escapeXml="false" />
                                <c:out value="<td id='message'></td>" escapeXml="false" />
                            <c:out value="</tr>" escapeXml="false" />
                        <c:out value="</table>" escapeXml="false" />
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="sakai-btn sakai-btn-secondary" data-bs-dismiss="modal"><h:outputText value="#{msgs['gen.cancel']}" /></button>
                        <button type="button" id="deleteButton" class="sakai-btn sakai-btn-primary sakai-chat__btn-danger"><h:outputText value="#{msgs['gen.delete']}" /></button>
                    </div>
                </div>
            </div>
        </div>
        </div>

        <script type="text/javascript">
            // Store chat configuration to be used after chat module is loaded
            window.chatConfig = {
                totalMessages: "<h:outputText value="#{ChatTool.roomMessagesCount}" />",
                messageCountTemplate: "<h:outputText value="#{ChatTool.messagesShownTotalText}" />",
                messagesUnreadedTemplate: "<h:outputText value="#{ChatTool.unreadedMessagesText}" />",
                currentChatChannelId: "<h:outputText value="#{ChatTool.currentChatChannelId}" />",
                pollInterval: "<h:outputText value="#{ChatTool.pollInterval}" />"
            };
        </script>

        <script type="text/javascript">
            setMainFrameHeight('<h:outputText value="#{ChatTool.framePlacementId}" />');
        </script>
    </sakai:view>
</f:view>
