/**
 * Copyright (c) 2026 The Apereo Foundation
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
package org.sakaiproject.tool.assessment.ui.bean.print;

import java.util.Collections;
import java.util.List;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertNull;
import org.junit.Test;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;
import org.sakaiproject.samigo.api.pdf.model.AssessmentPdfQuestionModel;
import org.sakaiproject.samigo.api.pdf.model.AssessmentPrintPdfModel;
import org.sakaiproject.tool.assessment.data.ifc.assessment.ItemDataIfc;
import org.sakaiproject.tool.assessment.data.ifc.shared.TypeIfc;
import org.sakaiproject.tool.assessment.ui.bean.delivery.DeliveryBean;
import org.sakaiproject.tool.assessment.ui.bean.delivery.FinBean;
import org.sakaiproject.tool.assessment.ui.bean.delivery.ItemContentsBean;
import org.sakaiproject.tool.assessment.ui.bean.delivery.SectionContentsBean;
import org.sakaiproject.tool.assessment.ui.bean.print.settings.PrintSettingsBean;
import org.sakaiproject.util.api.FormattedText;

public class AssessmentPdfSnapshotBuilderTest {

    @Test
    public void buildPrintModelSkipsCalculatedTextWhenFinArrayIsNull() {
        ItemDataIfc itemData = mock(ItemDataIfc.class);
        when(itemData.getTypeId()).thenReturn(TypeIfc.MULTIPLE_CHOICE);
        when(itemData.getText()).thenReturn("Multiple choice question");

        ItemContentsBean item = new ItemContentsBean();
        item.setItemData(itemData);
        item.setSequence("1");

        SectionContentsBean section = mock(SectionContentsBean.class);
        when(section.getItemContents()).thenReturn(List.of(item));
        when(section.getAttachmentList()).thenReturn(Collections.emptyList());
        when(section.getTitle()).thenReturn("Part 1");
        when(section.getDescription()).thenReturn("");

        DeliveryBean deliveryBean = mock(DeliveryBean.class);
        when(deliveryBean.getAssessmentTitle()).thenReturn("Sample Quiz");
        when(deliveryBean.getIsMathJaxEnabled()).thenReturn(Boolean.FALSE);

        PrintSettingsBean printSettings = new PrintSettingsBean();
        FormattedText formattedText = mock(FormattedText.class);

        AssessmentPrintPdfModel model = AssessmentPdfSnapshotBuilder.buildPrintModel(
                deliveryBean, List.of(section), printSettings, "", formattedText);

        assertNotNull(model);
        AssessmentPdfQuestionModel question = model.getParts().get(0).getQuestions().get(0);
        assertNull(question.getCalculatedQuestionText());
    }

    @Test
    public void buildPrintModelSkipsCalculatedTextWhenFinArrayIsNullForCalculatedQuestion() {
        ItemDataIfc itemData = mock(ItemDataIfc.class);
        when(itemData.getTypeId()).thenReturn(TypeIfc.CALCULATED_QUESTION);

        ItemContentsBean item = new ItemContentsBean();
        item.setItemData(itemData);
        item.setSequence("1");
        item.setInstruction("Kevin has {x} apples");

        SectionContentsBean section = mock(SectionContentsBean.class);
        when(section.getItemContents()).thenReturn(List.of(item));
        when(section.getAttachmentList()).thenReturn(Collections.emptyList());
        when(section.getTitle()).thenReturn("Part 1");
        when(section.getDescription()).thenReturn("");

        DeliveryBean deliveryBean = mock(DeliveryBean.class);
        when(deliveryBean.getAssessmentTitle()).thenReturn("Sample Quiz");
        when(deliveryBean.getIsMathJaxEnabled()).thenReturn(Boolean.FALSE);

        PrintSettingsBean printSettings = new PrintSettingsBean();
        FormattedText formattedText = mock(FormattedText.class);

        AssessmentPrintPdfModel model = AssessmentPdfSnapshotBuilder.buildPrintModel(
                deliveryBean, List.of(section), printSettings, "", formattedText);

        assertNull(model.getParts().get(0).getQuestions().get(0).getCalculatedQuestionText());
    }

    @Test
    public void buildPrintModelIncludesCalculatedTextWhenFinArrayIsPresent() {
        ItemDataIfc itemData = mock(ItemDataIfc.class);
        when(itemData.getTypeId()).thenReturn(TypeIfc.CALCULATED_QUESTION);

        FinBean finBean = new FinBean();
        finBean.setText("Kevin has 3 apples");

        ItemContentsBean item = new ItemContentsBean();
        item.setItemData(itemData);
        item.setFinArray(List.of(finBean));
        item.setSequence("1");
        item.setInstruction("Calculated question");

        SectionContentsBean section = mock(SectionContentsBean.class);
        when(section.getItemContents()).thenReturn(List.of(item));
        when(section.getAttachmentList()).thenReturn(Collections.emptyList());
        when(section.getTitle()).thenReturn("Part 1");
        when(section.getDescription()).thenReturn("");

        DeliveryBean deliveryBean = mock(DeliveryBean.class);
        when(deliveryBean.getAssessmentTitle()).thenReturn("Sample Quiz");
        when(deliveryBean.getIsMathJaxEnabled()).thenReturn(Boolean.FALSE);

        PrintSettingsBean printSettings = new PrintSettingsBean();
        FormattedText formattedText = mock(FormattedText.class);

        AssessmentPrintPdfModel model = AssessmentPdfSnapshotBuilder.buildPrintModel(
                deliveryBean, List.of(section), printSettings, "", formattedText);

        assertEquals("Kevin has 3 apples", model.getParts().get(0).getQuestions().get(0).getCalculatedQuestionText());
    }
}
