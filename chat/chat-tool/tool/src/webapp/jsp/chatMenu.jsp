<%--
***********************************************************************************
*
* Copyright (c) 2020 Apereo Foundation
* Licensed under the Educational Community License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*             http://opensource.org/licenses/ecl2
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*
**********************************************************************************/
--%>
<h:panelGroup>
  <ul class='navIntraTool actionToolbar' role='menu'>
    <li role='menuitem'>
      <h:panelGroup id="chatMainLink" styleClass="#{chatMenuCurrent eq 'main' ? 'current' : ''}">
        <h:commandLink action="#{ChatTool.processActionBackToRoom}" immediate="true" rendered="#{chatMenuCurrent ne 'main'}">
          <h:outputText value="#{msgs.main}"/>
        </h:commandLink>
        <h:outputText value="#{msgs.main}" rendered="#{chatMenuCurrent eq 'main'}"/>
      </h:panelGroup>
    </li>
    <li role='menuitem'>
      <h:panelGroup id="chatAddRoomLink" rendered="#{ChatTool.canCreateChannel}" styleClass="#{chatMenuCurrent eq 'add' ? 'current' : ''}">
        <h:commandLink action="#{ChatTool.processActionAddRoom}" immediate="true" rendered="#{chatMenuCurrent ne 'add'}">
          <h:outputText value="#{msgs.add_room}" />
        </h:commandLink>
        <h:outputText value="#{msgs.add_room}" rendered="#{chatMenuCurrent eq 'add'}"/>
      </h:panelGroup>
    </li>
    <li role='menuitem'>
      <h:panelGroup id="chatManageLink" rendered="#{ChatTool.canManageTool}" styleClass="#{chatMenuCurrent eq 'rooms' ? 'current' : ''}">
        <h:commandLink action="#{ChatTool.processActionListRooms}" immediate="true" rendered="#{chatMenuCurrent ne 'rooms'}">
          <h:outputText value="#{msgs.manage_tool}" />
        </h:commandLink>
        <h:outputText value="#{msgs.manage_tool}" rendered="#{chatMenuCurrent eq 'rooms'}"/>
      </h:panelGroup>
    </li>
    <li role='menuitem'>
      <h:panelGroup id="chatChangeRoomLink" rendered="#{!ChatTool.canManageTool && ChatTool.siteChannelCount > 1}" styleClass="#{chatMenuCurrent eq 'rooms' ? 'current' : ''}">
        <h:commandLink action="#{ChatTool.processActionListRooms}" immediate="true" rendered="#{chatMenuCurrent ne 'rooms'}">
          <h:outputText value="#{msgs.change_room}" />
        </h:commandLink>
        <h:outputText value="#{msgs.change_room}" rendered="#{chatMenuCurrent eq 'rooms'}"/>
      </h:panelGroup>
    </li>
    <li role='menuitem'>
      <h:panelGroup id="chatPermissionsLink">
        <h:commandLink rendered="#{ChatTool.maintainer}" action="#{ChatTool.processActionPermissions}" immediate="true">
          <h:outputText value="#{msgs.permis}" />
        </h:commandLink>
      </h:panelGroup>
    </li>
  </ul>
</h:panelGroup>
