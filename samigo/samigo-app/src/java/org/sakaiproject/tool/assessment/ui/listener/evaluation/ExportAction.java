/**********************************************************************************
 * $URL$
 * $Id$
 ***********************************************************************************
 *
 * Copyright (c) 2023 The Sakai Foundation
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



package org.sakaiproject.tool.assessment.ui.listener.evaluation;

import com.lowagie.text.Chunk;
import com.lowagie.text.Document;
import com.lowagie.text.Element;
import com.lowagie.text.Font;
import com.lowagie.text.Image;
import com.lowagie.text.PageSize;
import com.lowagie.text.Paragraph;
import com.lowagie.text.Phrase;
import com.lowagie.text.pdf.BaseFont;
import com.lowagie.text.pdf.PdfContentByte;
import com.lowagie.text.pdf.PdfGState;
import com.lowagie.text.pdf.PdfPCell;
import com.lowagie.text.pdf.PdfPCellEvent;
import com.lowagie.text.pdf.PdfPTable;
import com.lowagie.text.pdf.PdfWriter;
import com.lowagie.text.Rectangle;

import java.awt.Color;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;
import java.text.DecimalFormat;
import java.util.Objects;
import javax.faces.event.ActionEvent;
import javax.faces.event.ActionListener;
import javax.faces.context.FacesContext;
import javax.faces.model.SelectItem;
import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServletResponse;

import lombok.extern.slf4j.Slf4j;
import lombok.Setter;
import lombok.Getter;

import org.apache.commons.lang3.StringUtils;
import org.json.JSONObject;
import org.jsoup.Jsoup;
import org.jsoup.select.Elements;
import org.scilab.forge.jlatexmath.TeXFormula;

import org.sakaiproject.component.cover.ServerConfigurationService;
import org.sakaiproject.content.api.ContentHostingService;
import org.sakaiproject.site.api.Site;
import org.sakaiproject.site.cover.SiteService;
import org.sakaiproject.tool.assessment.data.dao.grading.ItemGradingData;
import org.sakaiproject.tool.assessment.data.dao.grading.MediaData;
import org.sakaiproject.tool.assessment.data.ifc.shared.TypeIfc;
import org.sakaiproject.tool.assessment.ui.bean.delivery.DeliveryBean;
import org.sakaiproject.tool.assessment.ui.bean.delivery.ImageMapQuestionBean;
import org.sakaiproject.tool.assessment.ui.bean.delivery.ItemContentsBean;
import org.sakaiproject.tool.assessment.ui.bean.delivery.MatchingBean;
import org.sakaiproject.tool.assessment.ui.bean.delivery.MatrixSurveyBean;
import org.sakaiproject.tool.assessment.ui.bean.delivery.FibBean;
import org.sakaiproject.tool.assessment.ui.bean.delivery.FinBean;
import org.sakaiproject.tool.assessment.ui.bean.delivery.SectionContentsBean;
import org.sakaiproject.tool.assessment.ui.bean.delivery.SelectionBean;
import org.sakaiproject.tool.assessment.ui.bean.evaluation.StudentScoresBean;
import org.sakaiproject.tool.assessment.ui.listener.util.ContextUtil;
import org.sakaiproject.util.ResourceLoader;
import org.springframework.http.ContentDisposition;
import org.springframework.http.HttpHeaders;

@Slf4j
public class ExportAction implements ActionListener {

    private ContentHostingService contentHostingService = org.sakaiproject.content.cover.ContentHostingService.getInstance();
	private static final ResourceLoader rb = new ResourceLoader("org.sakaiproject.tool.assessment.bundle.AuthorMessages");
	private static final ResourceLoader rbEval = new ResourceLoader("org.sakaiproject.tool.assessment.bundle.EvaluationMessages");

	// Color constants
	private static final Color PRIMARY_COLOR = new Color(60, 64, 67);           // Dark gray
	private static final Color SECONDARY_COLOR = new Color(95, 99, 104);        // Medium gray
	private static final Color BACKGROUND_GRAY = new Color(243, 244, 246);      // Light gray background
	private static final Color BORDER_COLOR = new Color(229, 231, 235);         // Border gray
	private static final Color TEXT_PRIMARY = new Color(17, 24, 39);            // Dark gray (almost black)
	private static final Color TEXT_SECONDARY = new Color(107, 114, 128);       // Medium gray
	private static final Color SUCCESS_COLOR = new Color(16, 185, 129);         // Green for correct answers
	private static final Color SUCCESS_BG = new Color(220, 252, 231);           // Light green background
	private static final Color WARNING_COLOR = new Color(245, 158, 11);         // Amber for warnings
	private static final Color WARNING_BG = new Color(254, 243, 199);           // Light amber background
	private static final Color ERROR_COLOR = new Color(239, 68, 68);            // Red for errors
	private static final Color INFO_BG = new Color(219, 234, 254);              // Light blue background
	private static final Color FEEDBACK_BG = new Color(233, 213, 255);          // Light purple background
	private static final Color WHITE_COLOR = new Color(255, 255, 255);          // White color

	// Font constants
	private static final Font TITLE_FONT = new Font(Font.HELVETICA, 20, Font.BOLD);
	private static final Font HEADING_FONT = new Font(Font.HELVETICA, 14, Font.BOLD);
	private static final Font HEADING_NORMAL_FONT = new Font(Font.HELVETICA, 14, Font.NORMAL);
	private static final Font BODY_BOLD_FONT = new Font(Font.HELVETICA, 10, Font.BOLD);
	private static final Font BODY_FONT = new Font(Font.HELVETICA, 10, Font.NORMAL);
	private static final Font BODY_ITALIC_FONT = new Font(Font.HELVETICA, 10, Font.ITALIC);
	private static final Font SMALL_FONT = new Font(Font.HELVETICA, 8, Font.NORMAL);
	private static final Font SMALL_BOLD_FONT = new Font(Font.HELVETICA, 8, Font.BOLD);

	private boolean isTable = false;
	private String LATEX_SEPARATOR_DOLLAR = "$$";
	private String[] LATEX_SEPARATOR_START = {"\\(", "\\["};
	private String[] LATEX_SEPARATOR_FINAL = {"\\)", "\\]"};

	/**
	 * Helper method to create a font with a specific color based on a base font.
	 * @param baseFont The base font to clone
	 * @param color The color to apply
	 * @return A new Font with the specified color
	 */
	private Font getFontWithColor(Font baseFont, Color color) {
		return new Font(baseFont.getFamily(), baseFont.getSize(), baseFont.getStyle(), color);
	}

	/**
	 * Standard process action method.
	 * @param ae ActionEvent
	 */
	public void processAction(ActionEvent ae) {
		FacesContext faces = FacesContext.getCurrentInstance();
		HttpServletResponse response = (HttpServletResponse) faces.getExternalContext().getResponse();
		DeliveryBean deliveryBean = (DeliveryBean) ContextUtil.lookupBean("delivery");
		StudentScoresBean studentScoreBean = (StudentScoresBean) ContextUtil.lookupBean("studentScores");

		Document document = new Document(PageSize.A4, 45, 45, 45, 45);
		try {
			ServletOutputStream outputStream = response.getOutputStream();
			PdfWriter.getInstance(document, outputStream);
			document.open();
			response.setContentType("application/pdf");
			String reportFilename = "Report_" + studentScoreBean.getFirstName() + "_" + deliveryBean.getAssessmentTitle() + ".pdf";
			response.setHeader(HttpHeaders.CONTENT_DISPOSITION, ContentDisposition.attachment().filename(reportFilename, StandardCharsets.UTF_8).build().toString());

			DecimalFormat twoDecimalsFormat = new DecimalFormat("0.00");

			// Student name
			Paragraph studentNameParagraph = new Paragraph(studentScoreBean.getStudentName(), getFontWithColor(TITLE_FONT, TEXT_PRIMARY));
			studentNameParagraph.setSpacingBefore(5f);
			studentNameParagraph.setSpacingAfter(5f);
			document.add(studentNameParagraph);

			// Student email
			if (studentScoreBean.getEmail() != null && !StringUtils.equals(studentScoreBean.getEmail(), "")) {
				Paragraph studentEmailParagraph = new Paragraph(studentScoreBean.getEmail(), getFontWithColor(BODY_FONT, TEXT_PRIMARY));
				studentEmailParagraph.setSpacingAfter(10f);
				document.add(studentEmailParagraph);
			}

			// Separator line
			PdfPTable separatorTable = new PdfPTable(1);
			separatorTable.setWidthPercentage(100f);
			separatorTable.setSpacingAfter(15f);
			PdfPCell separatorCell = new PdfPCell();
			separatorCell.setBorder(Rectangle.NO_BORDER);
			separatorCell.setBorderWidthBottom(1f);
			separatorCell.setBorderColorBottom(BORDER_COLOR);
			separatorCell.setFixedHeight(1f);
			separatorTable.addCell(separatorCell);
			document.add(separatorTable);

			// Assessment title
			Paragraph assessmentTitle = new Paragraph(deliveryBean.getAssessmentTitle(), getFontWithColor(HEADING_FONT, PRIMARY_COLOR));
			assessmentTitle.setSpacingBefore(10f);
			assessmentTitle.setSpacingAfter(8f);
			document.add(assessmentTitle);

			// Site title
			String siteTitle = "";
			try {
				Site site = SiteService.getSite(deliveryBean.getSiteId());
				siteTitle = site.getTitle();
			} catch (Exception e) {
				log.debug("Could not get site title: {}", e.getMessage());
			}

			if (StringUtils.isNotBlank(siteTitle)) {
				Paragraph siteParagraph = new Paragraph();
				Chunk siteValue = new Chunk(siteTitle, getFontWithColor(BODY_FONT, TEXT_PRIMARY));
				siteParagraph.add(siteValue);
				siteParagraph.setSpacingAfter(16f);
				document.add(siteParagraph);
			}

			// Score
			double currentScore = deliveryBean.getTableOfContents().getCurrentScore();
			double maxScore = deliveryBean.getTableOfContents().getMaxScore();
			String scorePercentageString = (maxScore == 0) ? "0" : twoDecimalsFormat.format((currentScore / maxScore) * 100);
			Paragraph scoreParagraph = new Paragraph();
			scoreParagraph.add(new Chunk(rbEval.getString("score") + ": ", getFontWithColor(BODY_FONT, TEXT_PRIMARY)));
			scoreParagraph.add(new Chunk(twoDecimalsFormat.format(currentScore) + " / " + twoDecimalsFormat.format(maxScore), getFontWithColor(BODY_BOLD_FONT, TEXT_PRIMARY)));
			scoreParagraph.add(new Chunk(" (" + scorePercentageString + "%)", getFontWithColor(BODY_FONT, TEXT_PRIMARY)));
			scoreParagraph.setSpacingAfter(8f);
			document.add(scoreParagraph);

			int index = 0;
			List<SectionContentsBean> deliveryParts = deliveryBean.getPageContents().getPartsContents();

			// Calculate total questions
			int totalQuestions = 0;
			for (SectionContentsBean part : deliveryParts) {
				totalQuestions += part.getItemContents().size();
			}

			for (SectionContentsBean deliveryPart : deliveryParts) {
				List<ItemContentsBean> items = deliveryPart.getItemContents();

				// New page for each part
				document.newPage();

				String partNumber = String.valueOf(deliveryPart.getNumber());
				String answeredQuestions = String.valueOf((deliveryPart.getQuestions() - deliveryPart.getUnansweredQuestions()));
				String questionsNumber = String.valueOf(deliveryPart.getQuestions());
				String partScore = twoDecimalsFormat.format(deliveryPart.getPoints());
				String partMaxScore = twoDecimalsFormat.format(deliveryPart.getMaxPoints());

				// Part header
				Paragraph partHeader = new Paragraph();
				partHeader.setSpacingBefore(5f);
				partHeader.setSpacingAfter(10f);
				String nonDefaultTitle = deliveryPart.getNonDefaultText();
				if (StringUtils.isNotEmpty(nonDefaultTitle)) {
					partHeader.add(new Chunk(rbEval.getString("part") + " " + partNumber + ": ", getFontWithColor(HEADING_FONT, PRIMARY_COLOR)));
					partHeader.add(new Chunk(nonDefaultTitle, getFontWithColor(HEADING_NORMAL_FONT, TEXT_PRIMARY)));
				} else {
					partHeader.add(new Chunk(rbEval.getString("part") + " " + partNumber, getFontWithColor(HEADING_FONT, PRIMARY_COLOR)));
				}
				document.add(partHeader);

				// Part stats
				PdfPTable statsTable = new PdfPTable(2);
				statsTable.setWidthPercentage(100f);
				statsTable.setSpacingBefore(5f);
				statsTable.setSpacingAfter(10f);

				PdfPCell questionsCell = new PdfPCell(new Paragraph(rb.getString("question_s_lower_case") + ": " + answeredQuestions + " / " + questionsNumber + " " + rbEval.getString("submitted"), getFontWithColor(BODY_FONT, TEXT_PRIMARY)));
				styleStatsCell(questionsCell, false);
				statsTable.addCell(questionsCell);

				PdfPCell scoreStatsCell = new PdfPCell(new Paragraph(rbEval.getString("score") + ": " + partScore + " / " + partMaxScore, getFontWithColor(BODY_BOLD_FONT, TEXT_PRIMARY)));
				styleStatsCell(scoreStatsCell, true);
				statsTable.addCell(scoreStatsCell);

				document.add(statsTable);

				// Question summary table
				PdfPTable shortSummaryTable = new PdfPTable(new float[]{3f, 1.2f, 0.8f, 1f});
				shortSummaryTable.setWidthPercentage(100f);
				shortSummaryTable.setSpacingBefore(5f);

				shortSummaryTable.addCell(createSummaryHeaderCell(rbEval.getString("question"), false));
				shortSummaryTable.addCell(createSummaryHeaderCell(rb.getString("type"), false));
				shortSummaryTable.addCell(createSummaryHeaderCell(rbEval.getString("status"), false));
				shortSummaryTable.addCell(createSummaryHeaderCell(rbEval.getString("points"), true));

				for (ItemContentsBean item : items) {
					// Question text cell
					PdfPCell questionTextCell = new PdfPCell(this.getQuestionTitle(++index + ". " + item.getText(), false));
					styleSummaryBodyCell(questionTextCell, false);
					shortSummaryTable.addCell(questionTextCell);

					// Type cell
					PdfPCell typeCell = new PdfPCell(new Paragraph(rb.getString("type." + item.getItemData().getTypeId()), getFontWithColor(SMALL_FONT, TEXT_SECONDARY)));
					styleSummaryBodyCell(typeCell, false);
					shortSummaryTable.addCell(typeCell);

					// Answered status cell
					String answeredText = !item.isUnanswered() ? rbEval.getString("submitted") : rbEval.getString("no_answer");
					PdfPCell answeredCell = new PdfPCell(new Paragraph(answeredText, getFontWithColor(SMALL_FONT, TEXT_PRIMARY)));
					styleSummaryBodyCell(answeredCell, false);
					shortSummaryTable.addCell(answeredCell);

					// Score cell
					PdfPCell scoreItemCell = new PdfPCell(new Paragraph(twoDecimalsFormat.format(item.getPoints()) + " / " + twoDecimalsFormat.format(item.getMaxPoints()), getFontWithColor(SMALL_FONT, TEXT_PRIMARY)));
					styleSummaryBodyCell(scoreItemCell, true);
					shortSummaryTable.addCell(scoreItemCell);
				}
				document.add(shortSummaryTable);

				document.add(new Paragraph("\n"));

				int questionStartIndex = index - items.size();
				for (ItemContentsBean item : items) {
					questionStartIndex++;
					Long questionType = item.getItemData().getTypeId();

					// Question header
					PdfPTable questionTable = new PdfPTable(new float[]{3f, 1f});
					questionTable.setWidthPercentage(100f);
					questionTable.setSpacingBefore(20f);

					PdfPCell questionNumCell = new PdfPCell(new Paragraph(rbEval.getString("question") + " " + questionStartIndex + " / " + totalQuestions, getFontWithColor(BODY_BOLD_FONT, TEXT_PRIMARY)));
					styleQuestionHeaderCell(questionNumCell, false);
					questionTable.addCell(questionNumCell);

					PdfPCell scoreHeaderCell = new PdfPCell(new Paragraph(twoDecimalsFormat.format(item.getPoints()) + " / " + twoDecimalsFormat.format(item.getMaxPoints()) + " pts", getFontWithColor(BODY_BOLD_FONT, TEXT_PRIMARY)));
					styleQuestionHeaderCell(scoreHeaderCell, true);
					questionTable.addCell(scoreHeaderCell);

					document.add(questionTable);

					// Question title and details
					if (Objects.equals(questionType, TypeIfc.FILL_IN_NUMERIC) || Objects.equals(questionType, TypeIfc.CALCULATED_QUESTION) || Objects.equals(questionType, TypeIfc.FILL_IN_BLANK)) {
						this.processFillInQuestion(document, (!questionType.equals(TypeIfc.FILL_IN_BLANK))? item.getFinArray() : item.getFibArray(), (!questionType.equals(TypeIfc.FILL_IN_BLANK)));
					} else {
						document.add(this.getQuestionTitle(item.getText(), true));
						document.add(new Paragraph("\n"));
					}

					// ESSAY_QUESTION question type
					if (Objects.equals(questionType, TypeIfc.ESSAY_QUESTION)) {
						PdfPTable responseTable = new PdfPTable(1);
						responseTable.setWidthPercentage(100f);
						PdfPCell responseCell = new PdfPCell(new Paragraph((item.getResponseText() != null) ? this.cleanText(item.getResponseText()) : rbEval.getString("no_answer"), getFontWithColor(BODY_FONT, TEXT_PRIMARY)));
						responseCell.setPadding(8f);
						responseCell.setBackgroundColor(BACKGROUND_GRAY);
						responseCell.setBorder(Rectangle.NO_BORDER);
						responseTable.addCell(responseCell);
						document.add(responseTable);
					}

					// FILE_UPLOAD and AUDIO_RECORDING question types
					if (Objects.equals(questionType, TypeIfc.FILE_UPLOAD)) {
						PdfPTable attachmentTable = new PdfPTable(1);
						attachmentTable.setWidthPercentage(100f);
						attachmentTable.setSpacingBefore(12f);

						if (!item.getMediaArray().isEmpty()) {
							for (MediaData mediaData : item.getMediaArray()) {
								PdfPCell fileCell = new PdfPCell(new Paragraph(mediaData.getFilename(), getFontWithColor(BODY_FONT, TEXT_PRIMARY)));
								fileCell.setPadding(8f);
								fileCell.setBackgroundColor(BACKGROUND_GRAY);
								fileCell.setBorder(Rectangle.NO_BORDER);
								fileCell.setBorderWidthBottom(1f);
								fileCell.setBorderColorBottom(BORDER_COLOR);
								attachmentTable.addCell(fileCell);
							}
						} else {
							PdfPCell noFileCell = new PdfPCell(new Paragraph(rbEval.getString("no_attachments_yet"), getFontWithColor(BODY_ITALIC_FONT, TEXT_SECONDARY)));
							noFileCell.setPadding(8f);
							noFileCell.setBackgroundColor(BACKGROUND_GRAY);
							noFileCell.setBorder(Rectangle.NO_BORDER);
							attachmentTable.addCell(noFileCell);
						}
						document.add(attachmentTable);

					} else if (Objects.equals(questionType, TypeIfc.AUDIO_RECORDING)) {
						PdfPTable audioTable = new PdfPTable(1);
						audioTable.setWidthPercentage(100f);
						audioTable.setSpacingBefore(12f);

						PdfPCell audioCell;
						if (!item.getMediaArray().isEmpty()) {
							audioCell = new PdfPCell(new Paragraph(rbEval.getString("alt_recording") + " - " + rbEval.getString("submitted"), getFontWithColor(BODY_FONT, TEXT_PRIMARY)));
							audioCell.setBackgroundColor(SUCCESS_BG);
						} else {
							audioCell = new PdfPCell(new Paragraph(rbEval.getString("no_answer"), getFontWithColor(BODY_ITALIC_FONT, TEXT_SECONDARY)));
							audioCell.setBackgroundColor(BACKGROUND_GRAY);
						}
						audioCell.setPadding(8f);
						audioCell.setBorder(Rectangle.NO_BORDER);
						audioTable.addCell(audioCell);
						document.add(audioTable);
					}

					// MATRIX_CHOICES_SURVEY question type
					List matrixArray = item.getMatrixArray();
					List<Integer> columnsIndex = item.getColumnIndexList();
					String[] columns = item.getColumnArray();

					if (columns != null && columnsIndex != null && matrixArray != null) {
						PdfPTable matrixTable = new PdfPTable(columnsIndex.size()+1);
						matrixTable.setWidthPercentage(100f);
						matrixTable.setSpacingBefore(12f);

						// Empty corner cell
						PdfPCell cornerCell = new PdfPCell(new Paragraph(""));
						cornerCell.setPadding(8f);
						cornerCell.setBackgroundColor(BACKGROUND_GRAY);
						cornerCell.setBorder(Rectangle.NO_BORDER);
						cornerCell.setBorderWidthBottom(1.5f);
						cornerCell.setBorderColorBottom(BORDER_COLOR);
						matrixTable.addCell(cornerCell);

						// Column headers
						for (String column : columns) {
							PdfPCell matrixHeaderCell = new PdfPCell(new Paragraph(column, getFontWithColor(BODY_BOLD_FONT, TEXT_PRIMARY)));
							matrixHeaderCell.setPadding(8f);
							matrixHeaderCell.setBackgroundColor(BACKGROUND_GRAY);
							matrixHeaderCell.setBorder(Rectangle.NO_BORDER);
							matrixHeaderCell.setBorderWidthBottom(1.5f);
							matrixHeaderCell.setBorderColorBottom(BORDER_COLOR);
							matrixHeaderCell.setHorizontalAlignment(Element.ALIGN_CENTER);
							matrixTable.addCell(matrixHeaderCell);
						}

						// Matrix rows
						for (Object matrix : matrixArray) {
							if (Objects.equals(questionType, TypeIfc.MATRIX_CHOICES_SURVEY)) {
								// Row label
								PdfPCell rowLabelCell = new PdfPCell(new Paragraph((((MatrixSurveyBean) matrix).getItemText().getText()), getFontWithColor(BODY_FONT, TEXT_PRIMARY)));
								rowLabelCell.setPadding(8f);
								rowLabelCell.setBackgroundColor(Color.WHITE);
								rowLabelCell.setBorder(Rectangle.NO_BORDER);
								rowLabelCell.setBorderWidthBottom(1f);
								rowLabelCell.setBorderColorBottom(BORDER_COLOR);
								matrixTable.addCell(rowLabelCell);

								// Radio buttons
								for (String answer : ((MatrixSurveyBean) matrix).getAnswerSid()) {
									PdfPCell circleCell = new PdfPCell(new Paragraph(" "));
									circleCell.setPadding(0f);
									circleCell.setBackgroundColor(Color.WHITE);
									circleCell.setBorder(Rectangle.NO_BORDER);
									circleCell.setBorderWidthBottom(1f);
									circleCell.setBorderColorBottom(BORDER_COLOR);
									circleCell.setMinimumHeight(30f);
									circleCell.setHorizontalAlignment(Element.ALIGN_CENTER);
									circleCell.setVerticalAlignment(Element.ALIGN_MIDDLE);
									circleCell.setCellEvent(new CircleCellEvent(StringUtils.equals(answer, ((MatrixSurveyBean) matrix).getResponseId()), true));
									matrixTable.addCell(circleCell);
								}
							}
						}
						document.add(matrixTable);
					}

					// IMAGEMAP_QUESTION question type
					String imageSrc = ServerConfigurationService.getServerUrl() + item.getImageSrc();
					if (Objects.equals(questionType, TypeIfc.IMAGEMAP_QUESTION) && !imageSrc.isEmpty()) {
						Image image = Image.getInstance(imageSrc);

						PdfPTable tableImage = new PdfPTable(1);
						tableImage.setWidthPercentage(100f);
						PdfPCell cellImage = new PdfPCell();
						cellImage.setBorderWidth(0);
						cellImage.setPadding(0);
						cellImage.addElement(image);
						ArrayList<Rectangle> answerRectangles = new ArrayList<Rectangle>();
						for (Object answer : item.getAnswers()) {
							JSONObject jsonObject = new JSONObject((String) answer);
							answerRectangles.add(new Rectangle(jsonObject.getFloat("x1"), jsonObject.getFloat("y1"), jsonObject.getFloat("x2"), jsonObject.getFloat("y2")));
						}

						List<ItemGradingData> itemsGrading = item.getItemGradingDataArray();
						ArrayList<Circle> answerCircles = new ArrayList<Circle>();
						for (ItemGradingData itemGrading : itemsGrading) {
							if (itemGrading.getAnswerText() != null && !StringUtils.equals(itemGrading.getAnswerText(), "")) {
								JSONObject jsonObject = new JSONObject(itemGrading.getAnswerText());
								boolean xDefined = !StringUtils.equals(jsonObject.optString("x"), "undefined");
								boolean yDefined = !StringUtils.equals(jsonObject.optString("y"), "undefined");
								float x = (xDefined)? jsonObject.getFloat("x") : 0f;
								float y = (yDefined)? jsonObject.getFloat("y") : 0f;
								if (xDefined && yDefined) {
									answerCircles.add(new Circle(x, y, itemGrading.getPublishedItemTextId().intValue()));
								} else {
									answerCircles.add(new Circle(x, y, itemGrading.getPublishedItemTextId().intValue()));
								}
							}
						}
						cellImage.setCellEvent(new ImageMapQuestionCellEvent(answerCircles, answerRectangles, image.getWidth(), image.getHeight()));
						tableImage.addCell(cellImage);
						document.add(tableImage);
						document.add(new Paragraph(Chunk.NEWLINE));
					}

					// MULTIPLE_CHOICE, MULTIPLE_CORRECT_SINGLE_SELECTION, MULTIPLE_CHOICE_SURVEY, MULTIPLE_CORRECT, MATCHING, EXTENDED_MATCHING_ITEMS and TRUE_FALSE question types
					for (Object answer : item.getAnswers()) {
						if (Objects.equals(questionType, TypeIfc.MULTIPLE_CHOICE) || Objects.equals(questionType, TypeIfc.MULTIPLE_CORRECT_SINGLE_SELECTION) || Objects.equals(questionType, TypeIfc.MULTIPLE_CHOICE_SURVEY) || Objects.equals(questionType, TypeIfc.MULTIPLE_CORRECT)) {
							SelectionBean selectionBean = (SelectionBean) answer;
							PdfPTable multipleTable = new PdfPTable(1);
							multipleTable.setWidthPercentage(100f);

							PdfPCell multipleCell = new PdfPCell();
							if (questionType.equals(TypeIfc.MULTIPLE_CHOICE_SURVEY)) {
								String answerText = selectionBean.getAnswer().getText();
								if (answerText.matches("-?\\d+")) {
									multipleCell.setPhrase(new Paragraph("  " + answerText, getFontWithColor(BODY_FONT, TEXT_PRIMARY)));
								} else {
									multipleCell.setPhrase(new Paragraph("  " + rb.getString(this.cleanText(answerText)), getFontWithColor(BODY_FONT, TEXT_PRIMARY)));
								}
							} else {
								multipleCell.setPhrase(createLatexParagraph("  " + selectionBean.getAnswer().getLabel() + ". " + this.cleanText(selectionBean.getAnswer().getText()), getFontWithColor(BODY_FONT, TEXT_PRIMARY)));
							}
							styleAnswerCell(multipleCell, 15f);
							if (questionType.equals(TypeIfc.MULTIPLE_CORRECT)) {
								multipleCell.setCellEvent(new CheckboxCellEvent(selectionBean.getResponse()));
							} else {
								multipleCell.setCellEvent(new CircleCellEvent(selectionBean.getResponse()));
							}
							PdfPCell finalCell = new PdfPCell(multipleCell);
							if (selectionBean.getAnswer().getIsCorrect() != null && selectionBean.getResponse()) {
								finalCell.setCellEvent(new CheckOrCrossCellEvent(selectionBean.getAnswer().getIsCorrect()));
							}
							multipleTable.addCell(finalCell);
							document.add(multipleTable);
						} else if (Objects.equals(questionType, TypeIfc.MATCHING) || Objects.equals(questionType, TypeIfc.EXTENDED_MATCHING_ITEMS)) {
							PdfPTable matchingAnswerTable = new PdfPTable(1);
							matchingAnswerTable.setWidthPercentage(100f);
							PdfPCell matchingAnswerCell = new PdfPCell(new Paragraph(((String) answer), getFontWithColor(BODY_FONT, TEXT_PRIMARY)));
							styleAnswerCell(matchingAnswerCell, 4f);
							matchingAnswerTable.addCell(matchingAnswerCell);
							document.add(matchingAnswerTable);
						} else if (Objects.equals(questionType, TypeIfc.TRUE_FALSE)) {
							PdfPTable trueFalsequestionTable = new PdfPTable(1);
							trueFalsequestionTable.setHorizontalAlignment(PdfPTable.ALIGN_LEFT);
							SelectItem selectItem = (SelectItem) answer;
							PdfPCell questionCell = new PdfPCell(new Paragraph("  " + selectItem.getLabel(), getFontWithColor(BODY_FONT, TEXT_PRIMARY)));
							styleAnswerCell(questionCell, 15f);
							questionCell.setCellEvent(new CircleCellEvent(selectItem.getValue().equals(item.getResponseId())));
							PdfPCell finalCell = new PdfPCell(questionCell);
							if (selectItem.getValue().equals(item.getResponseId())) {
								finalCell.setCellEvent(new CheckOrCrossCellEvent(StringUtils.equals(selectItem.getDescription(), "true")));
							}
							trueFalsequestionTable.addCell(finalCell);
							document.add(trueFalsequestionTable);
						}
					}

					// MATCHING, EXTENDED_MATCHING_ITEMS and IMAGEMAP_QUESTION question types
					List matchingItems = item.getMatchingArray();
					if (matchingItems != null) {
						PdfPTable matchingTable = new PdfPTable(1);
						matchingTable.setWidthPercentage(100f);
						for (Object matchingItem : matchingItems) {
							if (Objects.equals(questionType, TypeIfc.IMAGEMAP_QUESTION)) {
								PdfPCell matchingCell = new PdfPCell(new Phrase(rb.getString("item") + " " + ((ImageMapQuestionBean) matchingItem).getText(), getFontWithColor(BODY_FONT, TEXT_PRIMARY)));
								styleAnswerCell(matchingCell, 4f);
								matchingCell.setCellEvent(new CheckOrCrossCellEvent((((ImageMapQuestionBean) matchingItem).getIsCorrect() != null)? ((ImageMapQuestionBean) matchingItem).getIsCorrect() : false));
								matchingTable.addCell(matchingCell);
							} else if (Objects.equals(questionType, TypeIfc.MATCHING) || Objects.equals(questionType, TypeIfc.EXTENDED_MATCHING_ITEMS)) {
								// Always show the matching item, with or without student response
								boolean responseFound = false;
								for (Object choice : ((MatchingBean) matchingItem).getChoices()) {
									if (((MatchingBean) matchingItem).getResponse() != null && ((MatchingBean) matchingItem).getResponse().equals(((SelectItem) choice).getValue())) {
										// Student answered: show "A ··> Item text"
										PdfPCell matchingCell = new PdfPCell(new Phrase(((SelectItem) choice).getLabel() + " ··> " + ((MatchingBean) matchingItem).getText(), getFontWithColor(BODY_FONT, TEXT_PRIMARY)));
										styleAnswerCell(matchingCell, 4f);
										matchingCell.setCellEvent(new CheckOrCrossCellEvent(Boolean.TRUE.equals(((MatchingBean) matchingItem).getIsCorrect())));
										matchingTable.addCell(matchingCell);
										responseFound = true;
										break;
									}
								}
								if (!responseFound) {
									// No answer: show just the item text with sequence number
									PdfPCell matchingCell = new PdfPCell(new Phrase(((MatchingBean) matchingItem).getText(), getFontWithColor(BODY_FONT, TEXT_PRIMARY)));
									styleAnswerCell(matchingCell, 4f);
									matchingTable.addCell(matchingCell);
								}
							}
						}
						document.add(matchingTable);
					}

					// Correct answer
					if (Objects.equals(questionType, TypeIfc.CALCULATED_QUESTION) || Objects.equals(questionType, TypeIfc.FILL_IN_BLANK) || Objects.equals(questionType, TypeIfc.FILL_IN_NUMERIC)) {
						addCorrectResponseBox(document, item.getKey());
					} else if (Objects.equals(questionType, TypeIfc.ESSAY_QUESTION)) {
						if (item.getModelAnswerIsNotEmpty()) {
							Paragraph modelPar = new Paragraph();
							modelPar.setLeading(0f, 1.2f);
							modelPar.add(new Chunk(rbEval.getString("model"), getFontWithColor(SMALL_BOLD_FONT, PRIMARY_COLOR)));
							modelPar.add(new Chunk(item.getKey(), getFontWithColor(SMALL_FONT, TEXT_PRIMARY)));
							addInfoBox(document, INFO_BG, PRIMARY_COLOR, modelPar);
						}
					} else if (!Objects.equals(questionType, TypeIfc.MULTIPLE_CHOICE_SURVEY) && !Objects.equals(questionType, TypeIfc.MATRIX_CHOICES_SURVEY) && !Objects.equals(questionType, TypeIfc.FILE_UPLOAD) && !Objects.equals(questionType, TypeIfc.IMAGEMAP_QUESTION) && !Objects.equals(questionType, TypeIfc.AUDIO_RECORDING)) {
						addCorrectResponseBox(document, item.getAnswerKeyTF());
					}

					// Grading comment and feedback
					if (item.getGradingCommentIsNotEmpty() || item.getFeedbackIsNotEmpty()) {
						PdfPTable commentTable = new PdfPTable(1);
						commentTable.setWidthPercentage(100f);
						commentTable.setSpacingBefore(12f);

						if (item.getGradingCommentIsNotEmpty()) {
							PdfPCell commentCell = createInfoBoxCell(WARNING_BG, WARNING_COLOR);
							Paragraph commentPar = new Paragraph();
							commentPar.setLeading(0f, 1.2f);
							commentPar.add(new Chunk(rbEval.getString("comment") + ": ", getFontWithColor(SMALL_BOLD_FONT, WARNING_COLOR)));
							commentPar.add(createLatexParagraph(this.cleanText(item.getGradingComment()), getFontWithColor(SMALL_FONT, TEXT_PRIMARY)));
							commentCell.addElement(commentPar);
							commentTable.addCell(commentCell);
						}
						if (item.getFeedbackIsNotEmpty()) {
							PdfPCell feedbackCell = createInfoBoxCell(FEEDBACK_BG, SECONDARY_COLOR);
							Paragraph feedbackPar = new Paragraph();
							feedbackPar.setLeading(0f, 1.2f);
							feedbackPar.add(new Chunk(rb.getString("generalItemFeedback") + ": ", getFontWithColor(SMALL_BOLD_FONT, SECONDARY_COLOR)));
							if (Objects.equals(questionType, TypeIfc.CALCULATED_QUESTION)) {
								feedbackPar.add(createLatexParagraph(this.cleanText(item.getFeedbackValue()), getFontWithColor(SMALL_FONT, TEXT_PRIMARY)));
							} else {
								feedbackPar.add(createLatexParagraph(this.cleanText(item.getFeedback()), getFontWithColor(SMALL_FONT, TEXT_PRIMARY)));
							}
							feedbackCell.addElement(feedbackPar);
							commentTable.addCell(feedbackCell);
						}
						document.add(commentTable);
					}
				}
			}

			outputStream.flush();
			outputStream.close();
			faces.responseComplete();
		} catch (Exception ex) {
			log.error(ex.getMessage());
		} finally {
			document.close();
		}

	}

	/**
	 * Applies the shared styling for a part-stats cell.
	 * @param cell - PdfPCell to style
	 * @param rightAlign - whether the content should be right aligned
	 */
	private void styleStatsCell(PdfPCell cell, boolean rightAlign) {
		cell.setPaddingTop(8f);
		cell.setPaddingBottom(8f);
		cell.setPaddingLeft(0f);
		cell.setPaddingRight(0f);
		cell.setBorder(Rectangle.NO_BORDER);
		cell.setBorderWidthBottom(1f);
		cell.setBorderColorBottom(BORDER_COLOR);
		if (rightAlign) {
			cell.setHorizontalAlignment(Element.ALIGN_RIGHT);
		}
	}

	/**
	 * Creates a header cell for the question summary table.
	 * @param text - header text
	 * @param rightAlign - whether the content should be right aligned
	 * @return - PdfPCell
	 */
	private PdfPCell createSummaryHeaderCell(String text, boolean rightAlign) {
		PdfPCell cell = new PdfPCell(new Paragraph(text, getFontWithColor(BODY_BOLD_FONT, TEXT_PRIMARY)));
		cell.setPadding(8f);
		cell.setBorder(Rectangle.NO_BORDER);
		if (rightAlign) {
			cell.setHorizontalAlignment(Element.ALIGN_RIGHT);
		}
		return cell;
	}

	/**
	 * Applies the shared styling for a body cell of the question summary table.
	 * @param cell - PdfPCell to style
	 * @param rightAlign - whether the content should be right aligned
	 */
	private void styleSummaryBodyCell(PdfPCell cell, boolean rightAlign) {
		cell.setPadding(8f);
		cell.setBackgroundColor(BACKGROUND_GRAY);
		cell.setBorder(Rectangle.NO_BORDER);
		cell.setBorderWidthBottom(1.5f);
		cell.setBorderColorBottom(WHITE_COLOR);
		if (rightAlign) {
			cell.setHorizontalAlignment(Element.ALIGN_RIGHT);
		}
	}

	/**
	 * Applies the shared styling for a question detail header cell.
	 * @param cell - PdfPCell to style
	 * @param rightAlign - whether the content should be right aligned
	 */
	private void styleQuestionHeaderCell(PdfPCell cell, boolean rightAlign) {
		cell.setPaddingLeft(0f);
		cell.setPaddingRight(0f);
		cell.setPaddingTop(10f);
		cell.setPaddingBottom(10f);
		cell.setBorder(Rectangle.NO_BORDER);
		cell.setBorderWidthTop(1.5f);
		cell.setBorderColorTop(TEXT_PRIMARY);
		if (rightAlign) {
			cell.setHorizontalAlignment(Element.ALIGN_RIGHT);
		}
	}

	/**
	 * Applies the shared styling for an answer/option cell.
	 * @param cell - PdfPCell to style
	 * @param paddingLeft - left padding used to indent the option
	 */
	private void styleAnswerCell(PdfPCell cell, float paddingLeft) {
		cell.setBorderWidth(0);
		cell.setPaddingLeft(paddingLeft);
		cell.setPaddingTop(0f);
		cell.setPaddingBottom(2f);
	}

	/**
	 * Creates a styled "info box" cell with a coloured left accent border.
	 * @param backgroundColor - the cell background color
	 * @param leftBorderColor - the color of the left accent border
	 * @return - PdfPCell
	 */
	private PdfPCell createInfoBoxCell(Color backgroundColor, Color leftBorderColor) {
		PdfPCell cell = new PdfPCell();
		cell.setPadding(8f);
		cell.setBackgroundColor(backgroundColor);
		cell.setBorder(Rectangle.NO_BORDER);
		cell.setBorderWidthLeft(2f);
		cell.setBorderColorLeft(leftBorderColor);
		return cell;
	}

	/**
	 * Adds a standalone "info box" (single cell table) to the document.
	 * @param document - the PDF document
	 * @param backgroundColor - the box background color
	 * @param leftBorderColor - the color of the left accent border
	 * @param content - the paragraph to render inside the box
	 */
	private void addInfoBox(Document document, Color backgroundColor, Color leftBorderColor, Paragraph content) throws Exception {
		PdfPTable table = new PdfPTable(1);
		table.setWidthPercentage(100f);
		table.setSpacingBefore(12f);
		PdfPCell cell = createInfoBoxCell(backgroundColor, leftBorderColor);
		cell.addElement(content);
		table.addCell(cell);
		document.add(table);
	}

	/**
	 * Adds the "Correct Responses" info box for the given answer key value.
	 * @param document - the PDF document
	 * @param value - the correct answer key text
	 */
	private void addCorrectResponseBox(Document document, String value) throws Exception {
		Paragraph paragraph = new Paragraph();
		paragraph.setLeading(0f, 1.2f);
		paragraph.add(new Chunk(rbEval.getString("correct_responses") + ": ", getFontWithColor(SMALL_BOLD_FONT, SECONDARY_COLOR)));
		paragraph.add(new Chunk(value, getFontWithColor(SMALL_FONT, TEXT_PRIMARY)));
		addInfoBox(document, BACKGROUND_GRAY, SECONDARY_COLOR, paragraph);
	}

	/**
	 * Method to get the question text and parse if has html and get only the table transforming
	 * it into a PdfPTable
	 * @param questionText - String
	 * @param showAllInformation - boolean
	 * @return - PdfPTable
	 */
	private PdfPTable getQuestionTitle(String questionText, boolean showAllInformation) {
		PdfPTable auxTable = new PdfPTable(1);
		auxTable.setWidthPercentage(100f);

		String[] textSeparatedByLineBreak = questionText.split("<br />");
		String finalText = "";
		if (textSeparatedByLineBreak.length > 1) {
			for (String text : textSeparatedByLineBreak) {
				String cleanedText = this.cleanText(text);
				if (StringUtils.isNotEmpty(cleanedText)){
					finalText += cleanedText + "\n";
				}
			}
		} else {
			textSeparatedByLineBreak = (questionText.indexOf("\n") != -1? questionText.split("\n") : textSeparatedByLineBreak);
			for (String text : textSeparatedByLineBreak) {
				String cleanedText = this.cleanText(text);
				if (StringUtils.isNotEmpty(cleanedText)){
					finalText += cleanedText + "\n";
				}
			}
		}
		finalText = finalText.trim();

		DeliveryBean deliveryBean = (DeliveryBean) ContextUtil.lookupBean("delivery");

		PdfPCell textCell = new PdfPCell();
		textCell.setBorder(Rectangle.NO_BORDER);
		textCell.setPadding(0f);

		Font textFont = showAllInformation ? getFontWithColor(BODY_FONT, TEXT_PRIMARY) : getFontWithColor(SMALL_FONT, TEXT_PRIMARY);
		Paragraph textParagraph;
		if ((finalText.indexOf(LATEX_SEPARATOR_DOLLAR) != -1 || finalText.indexOf(LATEX_SEPARATOR_START[0]) != -1 || finalText.indexOf(LATEX_SEPARATOR_START[1]) != -1) && deliveryBean.getIsMathJaxEnabled()) {
			textParagraph = createLatexParagraph(finalText, textFont);
		} else {
			textParagraph = new Paragraph(finalText, textFont);
		}
		textParagraph.setSpacingBefore(0f);
		textParagraph.setSpacingAfter(0f);
		textParagraph.setLeading(0f, 1.0f);
		textCell.addElement(textParagraph);
		auxTable.addCell(textCell);

		if (showAllInformation) {
			addTableElementsToTable(questionText, auxTable);
			addImageElementsToTable(questionText, auxTable);
		}

		return auxTable;
	}

	/**
	 * Method to create a Paragraph with Latex functions.
	 * @param text
	 * @param font
	 * @return Paragraph latexParagraph
	 */
	private Paragraph createLatexParagraph(String text, Font font) {
		Paragraph latexParagraph = new Paragraph();
		String[] searchIndex = {LATEX_SEPARATOR_DOLLAR, LATEX_SEPARATOR_START[0], LATEX_SEPARATOR_START[1]};
		DeliveryBean deliveryBean = (DeliveryBean) ContextUtil.lookupBean("delivery");
		if ((text.indexOf(searchIndex[0]) != -1 || text.indexOf(searchIndex[1]) != -1 || text.indexOf(searchIndex[2]) != -1) && deliveryBean.getIsMathJaxEnabled()) {
			String[] finalSearchIndex = {LATEX_SEPARATOR_DOLLAR, LATEX_SEPARATOR_FINAL[0], LATEX_SEPARATOR_FINAL[1]};
			int currentSearch = 1;
			if (text.indexOf(searchIndex[0]) != -1) {
				currentSearch = 0;
			}
			if (text.indexOf(searchIndex[1]) != -1){
				currentSearch = (text.indexOf(searchIndex[0]) != -1 && text.indexOf(searchIndex[0]) < text.indexOf(searchIndex[1]))? 0 : 1;
			} else if (text.indexOf(searchIndex[2]) != -1) {
				currentSearch = (text.indexOf(searchIndex[0]) != -1 && text.indexOf(searchIndex[0]) < text.indexOf(searchIndex[2]))? 0 : 2;
			}

			int latexInitIndex = text.indexOf(searchIndex[currentSearch]);
			int latexFinalIndex = text.indexOf(finalSearchIndex[currentSearch], latexInitIndex + 2);
			// Tracks the last matched closing delimiter so trailing text can still be emitted
			// safely if an opening delimiter is left unclosed (latexFinalIndex == -1).
			int lastValidIndex = 0;
			while (latexInitIndex != -1 && latexFinalIndex != -1) {
				String textBeforeLatex = text.substring(0, latexInitIndex);
				String latex = text.substring(latexInitIndex + 2, latexFinalIndex).replace(searchIndex[currentSearch], "").replace(finalSearchIndex[currentSearch], "");
				latex = latex.replace("@", "\\text{at}");
				TeXFormula formula = new TeXFormula(latex);
				Image pdfLatexImage = null;
				try {
					pdfLatexImage = Image.getInstance(formula.createBufferedImage(TeXFormula.BOLD, 300, null, null), null);
				} catch (Exception ex) {
					log.error(ex.getMessage());
				}
				float finalWidth = formula.createBufferedImage(TeXFormula.BOLD, 10, null, null).getWidth(null);
				float finalHeight = formula.createBufferedImage(TeXFormula.BOLD, 10, null, null).getHeight(null);
				pdfLatexImage.scaleAbsolute(finalWidth, finalHeight);

				latexParagraph.add(new Chunk(textBeforeLatex, font));
				latexParagraph.add(new Chunk(pdfLatexImage, -1, -2, true));

				currentSearch = 1;
				if (text.indexOf(searchIndex[0], latexFinalIndex + 1) != -1) {
					currentSearch = 0;
					if (text.indexOf(searchIndex[1], latexFinalIndex + 2) != -1) {
						currentSearch = text.indexOf(searchIndex[0], latexFinalIndex + 2) < text.indexOf(searchIndex[1], latexFinalIndex + 2) ? 0 : 1;
					} else if (text.indexOf(searchIndex[2], latexFinalIndex + 2) != -1) {
						currentSearch = text.indexOf(searchIndex[0], latexFinalIndex + 2) < text.indexOf(searchIndex[2], latexFinalIndex + 2)? 0 : 2;
					}
				}

				latexInitIndex = text.indexOf(searchIndex[currentSearch], latexFinalIndex + 1);

				if (latexInitIndex != -1) {
					textBeforeLatex = text.substring(latexFinalIndex, latexInitIndex).replace(LATEX_SEPARATOR_DOLLAR, "")
							.replace(LATEX_SEPARATOR_START[0], "").replace(LATEX_SEPARATOR_FINAL[0], "")
							.replace(LATEX_SEPARATOR_START[1], "").replace(LATEX_SEPARATOR_FINAL[1], "");
					lastValidIndex = latexFinalIndex;
					latexFinalIndex = text.indexOf(finalSearchIndex[currentSearch], latexInitIndex + 2);
				}
			}
			// An unclosed opening delimiter leaves latexFinalIndex == -1; fall back to the last
			// matched closing delimiter (or the start of the text) so the remaining text is emitted safely.
			int remainingIndex = latexFinalIndex != -1 ? latexFinalIndex : lastValidIndex;
			latexParagraph.add(new Chunk(text.substring(remainingIndex).replace(LATEX_SEPARATOR_DOLLAR, "").replace(LATEX_SEPARATOR_START[0], "")
					.replace(LATEX_SEPARATOR_FINAL[0], "").replace(LATEX_SEPARATOR_START[1], "").replace(LATEX_SEPARATOR_FINAL[1], ""), font));
		} else {
			latexParagraph.add(new Chunk(text, font));
		}
		return latexParagraph;
	}

	/**
	 * Method to add the Table Elements from a String to a PdfPTable
	 *
	 * @param text - string that contain the Table Elements functions
	 * @param table - PdfPTable where save the resolved text
	 */
	private void addTableElementsToTable(String text, PdfPTable table){
		try {
			Elements tables = Jsoup.parse(text).select("table");
			for (org.jsoup.nodes.Element tableElement : tables) {
				PdfPTable pdfTable = new PdfPTable(tableElement.select("tr").first().children().size());
				for (org.jsoup.nodes.Element row : tableElement.select("tr")) {
					for (org.jsoup.nodes.Element cell : row.children()) {
						PdfPCell contentCell = new PdfPCell(new Paragraph(cell.text()));
						contentCell.setBorderWidth(0);
						contentCell.setBorderWidthBottom(1);

						contentCell.setPadding(5f);
						pdfTable.addCell(contentCell);
					}
				}
				PdfPCell questionCell = new PdfPCell(pdfTable);
				questionCell.setBorderWidth(0);
				table.addCell(questionCell);
				PdfPCell blankLine = new PdfPCell(new Paragraph(Chunk.NEWLINE));
				blankLine.setBorderWidth(0);
				table.addCell(blankLine);
			}
		} catch (Exception ex) {
			log.error(ex.getMessage());
		}
	}

	/**
	 * Method to add the Image Elements from a String to a PdfPTable
	 *
	 * @param text - string that contain the Image Elements functions
	 * @param table - PdfPTable where save the resolved text
	 */
	private void addImageElementsToTable(String text, PdfPTable table){
		try {
			Elements imageElements = Jsoup.parse(text).select("img");
			for (org.jsoup.nodes.Element imageElement : imageElements) {
				String imageSrc = imageElement.attr("src");
				Image image = Image.getInstance(contentHostingService.getResource(imageSrc.replace(ServerConfigurationService.getAccessUrl() + "/content", "")).getContent());
				float originalWidth = image.getWidth();
				float originalHeight = image.getHeight();
				float newHeight = PageSize.A4.getHeight() * 0.25f;
				float newWidth = (originalWidth * newHeight) / originalHeight;
				if (newWidth > (PageSize.A4.getWidth() * 0.8)) {
					image.scalePercent((PageSize.A4.getWidth() / originalWidth) * 80);
				} else {
					image.scaleAbsoluteHeight(newHeight);
					image.scaleAbsoluteWidth(newWidth);
				}
				PdfPCell imageCell = new PdfPCell(image);
				imageCell.setBorderWidth(0);
				table.addCell(imageCell);
			}
		} catch (Exception ex) {
			log.error(ex.getMessage());
		}
	}

	/**
	 * Method to get only the text without the html tag
	 * @param text - String
	 * @return - String
	 */
	private String cleanText(String text) {
		String textAux = text;
		int tableIndex = textAux.indexOf("<table");
		int tableIndexFinal = textAux.indexOf("</table>", tableIndex);
		if (tableIndex != -1) {
			isTable = true;
		}
		if (isTable) {
			if (tableIndexFinal != -1) {
				if (tableIndex != -1) {
					while (tableIndex != -1) {
						textAux = (textAux.substring(0, tableIndex) + textAux.substring(tableIndexFinal));
						tableIndex = textAux.indexOf("<table");
						tableIndexFinal = textAux.indexOf("</table>", tableIndex);
					}
					isTable = false;
				} else {
					isTable = false;
				}
			} else {
				textAux = "";
			}
		}
		return Jsoup.parse(textAux).text();
	}

	/**
	 * Method to process the fill in questions text
	 *
	 * @param Document - document
	 * @param List - fillInArray
	 * @param boolean - numeric
	 */
	private void processFillInQuestion(Document document, List fillInArray, boolean numeric) throws Exception {
		PdfPTable fillInTable = new PdfPTable(1);
		fillInTable.setWidthPercentage(100f);
		fillInTable.setHorizontalAlignment(PdfPTable.ALIGN_LEFT);
		int i = 0;
		String questionText = "";
		for (Object fillInObject : fillInArray) {
			if (numeric) {
				FinBean fillInBean = (FinBean) fillInObject;
				if (i + 1 != fillInArray.size()) {
					questionText += fillInBean.getText() + " (" + (++i) + ") ";
					fillInTable.addCell(createFillInCell(i, fillInBean.getResponse(), fillInBean.getIsCorrect()));
				} else {
					questionText += fillInBean.getText();
				}
			} else {
				FibBean fillInBean = (FibBean) fillInObject;
				if (i + 1 != fillInArray.size()) {
					questionText += fillInBean.getText() + " (" + (++i) + ") ";
					fillInTable.addCell(createFillInCell(i, fillInBean.getResponse(), fillInBean.getIsCorrect()));
				} else {
					questionText += fillInBean.getText();
				}
			}
		}
		document.add(this.getQuestionTitle(questionText, true));
		fillInTable.setSpacingBefore(12f);
		fillInTable.setSpacingAfter(8f);
		document.add(fillInTable);
	}

	/**
	 * Builds the response cell of a fill-in blank/numeric question.
	 * @param position - 1-based blank position
	 * @param response - the student response (may be empty)
	 * @param isCorrect - whether the response is correct
	 * @return - PdfPCell
	 */
	private PdfPCell createFillInCell(int position, String response, Boolean isCorrect) {
		String responseText = StringUtils.equals(response, "") ? rb.getString("no_answer.text") : response;
		PdfPCell fillInCell = new PdfPCell(new Phrase("(" + position + ") " + responseText, getFontWithColor(BODY_FONT, TEXT_PRIMARY)));
		fillInCell.setPaddingBottom(2f);
		fillInCell.setPaddingLeft(2f);
		fillInCell.setBorder(Rectangle.NO_BORDER);
		fillInCell.setCellEvent(new CheckOrCrossCellEvent(isCorrect != null && isCorrect));
		return fillInCell;
	}

	/**
	 * Class to handle the CircleCellEvent (equivalent to the radio in html)
	 */
	private static class CircleCellEvent implements PdfPCellEvent {
		private boolean checked = false;
		private boolean centered = false;

		public CircleCellEvent(boolean checked) {
			this.checked = checked;
		}
		public CircleCellEvent(boolean checked, boolean centered) {
			this.checked = checked;
			this.centered = centered;
		}

		public void cellLayout(PdfPCell cell, Rectangle position, PdfContentByte[] canvases) {
			PdfContentByte canvas = canvases[PdfPTable.TEXTCANVAS];
			float xAux = (centered) ? (position.getRight() - position.getLeft()) / 2 + position.getLeft() : position.getLeft() + 10;
			float yAux = (centered) ? (position.getTop() + position.getBottom()) / 2 : position.getTop() - 6f;
			float radius = 5f;

			canvas.circle(xAux, yAux, radius);
			canvas.setColorFill(Color.BLACK);
			canvas.fill();
			canvas.circle(xAux, yAux, radius * 0.95f);
			canvas.setColorFill(Color.WHITE);
			canvas.fill();
			if (checked) {
				canvas.circle(xAux, yAux, radius * 0.6f);
				canvas.setColorFill(Color.BLACK);
				canvas.fill();
			}

			canvas.setColorFill(Color.BLACK);
			canvas.setColorStroke(Color.BLACK);
		}
	}

	/**
	 * Class to handle the CheckboxCellEvent (equivalent to the checkbox in html)
	 */
	private static class CheckboxCellEvent implements PdfPCellEvent {
		private boolean checked = false;

		public CheckboxCellEvent(boolean checked) {
			this.checked = checked;
		}

		public void cellLayout(PdfPCell cell, Rectangle position, PdfContentByte[] canvases) {
			PdfContentByte canvas = canvases[PdfPTable.TEXTCANVAS];
			float xAux = position.getLeft() + 6;
			float yAux = position.getTop() - 10;

			canvas.rectangle(xAux, yAux, 8, 8);
			canvas.stroke();

			if (checked) {
				canvas.moveTo(xAux + 1.5f, yAux + 1.5f);
				canvas.lineTo(xAux + 6.5f, yAux + 6.5f);
				canvas.moveTo(xAux + 1.5f, yAux + 6.5f);
				canvas.lineTo(xAux + 6.5f, yAux + 1.5f);
				canvas.stroke();
			}
		}
	}

	/**
	 * Class to handle the ImageMapQuestionCellEvent
	 */
	private static class ImageMapQuestionCellEvent implements PdfPCellEvent {
		private ArrayList<Rectangle> answerRectangles = new ArrayList<Rectangle>();
		private ArrayList<Circle> answerCircles = new ArrayList<Circle>();
		private float originalWidth;
		private float originalHeight;

		public ImageMapQuestionCellEvent(ArrayList<Circle> answerCircles, ArrayList<Rectangle> answerRectangles, float originalWidth, float originalHeight) {
			this.answerRectangles = answerRectangles;
			this.answerCircles = answerCircles;
			this.originalWidth = originalWidth;
			this.originalHeight = originalHeight;
		}

		public void cellLayout(PdfPCell cell, Rectangle position, PdfContentByte[] canvases) {
			PdfContentByte canvas = canvases[PdfPTable.TEXTCANVAS];
			float x = position.getLeft();
			float y = position.getBottom();

			float scaleX = position.getWidth() / (originalWidth);
			float scaleY = position.getHeight() / (originalHeight);
			for (Rectangle answerRectangle : answerRectangles) {
				PdfGState transparentState = new PdfGState();
				transparentState.setFillOpacity(0.65f);
				transparentState.setStrokeOpacity(1f);
				float transformedX = x + answerRectangle.getLeft() * scaleX;
				float transformedY = y + position.getHeight() - answerRectangle.getTop() * scaleY;
				float transformedW = answerRectangle.getWidth() * scaleX;
				float transformedH = answerRectangle.getHeight() * scaleY;
				canvas.rectangle(transformedX, transformedY, transformedW, transformedH);
				canvas.setColorFill(Color.BLUE);
				canvas.setColorStroke(Color.BLACK);
				canvas.setGState(transparentState);
			}
			canvas.fillStroke();
			canvas.fill();

			float radius = 3f;
			int smallestValue = (answerCircles.size() > 0)? answerCircles.get(0).getPublishedItemId() + 1 : 0;
			for (Circle answerCircle : answerCircles) {
				PdfGState transparentState = new PdfGState();
				transparentState.setFillOpacity(0.3f);
				transparentState.setStrokeOpacity(0.8f);
				float transformedX = x + answerCircle.getX() * scaleX;
				float transformedY = y + position.getHeight() - answerCircle.getY() * scaleY;
				if (answerCircle.getX() != 0 && answerCircle.getY() != 0) {
					canvas.circle(transformedX, transformedY, radius);
					canvas.setGState(transparentState);
					canvas.circle(transformedX, transformedY, 0.3f);
					canvas.setColorFill(Color.YELLOW);
					canvas.setColorStroke(Color.YELLOW);
				}
				if (answerCircle.getPublishedItemId() < smallestValue) {
					smallestValue = answerCircle.getPublishedItemId();
				}
			}
			canvas.fillStroke();
			canvas.fill();

			int questionIndex = 1;
			for (Rectangle answerRectangle : answerRectangles) {
				PdfGState transparentState = new PdfGState();
				transparentState.setFillOpacity(1f);
				transparentState.setStrokeOpacity(1f);
				float transformedX = x + answerRectangle.getLeft() * scaleX;
				float transformedY = y + position.getHeight() - answerRectangle.getTop() * scaleY;
				float transformedW = answerRectangle.getWidth() * scaleX;
				canvas.setGState(transparentState);
				try {
					canvas.beginText();
					canvas.setColorFill(Color.BLUE);
					canvas.setFontAndSize(BaseFont.createFont(), 9);
					canvas.showTextAligned(Element.ALIGN_LEFT, String.valueOf(questionIndex), transformedX + transformedW + 1, transformedY, 0);
					canvas.endText();
					questionIndex++;
				} catch (Exception ex) {
					log.error("Cannot write the number of the ImageMap. " + ex.getMessage());
				}
			}

			int toReduce = smallestValue;
			for (Circle answerCircle : answerCircles) {
				float transformedX = x + answerCircle.getX() * scaleX;
				float transformedY = y + position.getHeight() - answerCircle.getY() * scaleY;
				if (answerCircle.getX() != 0 && answerCircle.getY() != 0) {
					try {
						int answerIndex = answerCircles.size() - (answerCircle.getPublishedItemId() - toReduce);
						canvas.beginText();
						canvas.setColorFill(Color.YELLOW);
						canvas.setFontAndSize(BaseFont.createFont(), 9);
						canvas.showTextAligned(Element.ALIGN_LEFT, String.valueOf(answerIndex), transformedX + 4, transformedY - 3, 0);
						canvas.endText();
						canvas.fill();
					} catch (Exception ex) {
						log.error("Cannot write the number of the ImageMap. " + ex.getMessage());
					}
				}
			}

			PdfGState transparentState = new PdfGState();
			transparentState.setFillOpacity(1f);
			transparentState.setStrokeOpacity(1f);
			canvas.setGState(transparentState);
			canvas.setColorFill(Color.BLACK);
			canvas.setColorStroke(Color.BLACK);
		}
	}

	/**
	 * Class to handle the CheckOrCrossCellEvent (equivalent to the check and cross icon)
	 */
	private static class CheckOrCrossCellEvent implements PdfPCellEvent {
		private boolean isCheckIcon = false;

		public CheckOrCrossCellEvent(boolean isCheckIcon) {
			this.isCheckIcon = isCheckIcon;
		}

		public void cellLayout(PdfPCell cell, Rectangle position, PdfContentByte[] canvases) {
			PdfContentByte canvas = canvases[PdfPTable.TEXTCANVAS];
			float xAux = position.getLeft() + 2;
			float yAux = position.getTop() - 10;

			if (isCheckIcon) {
				// Check mark
				canvas.setLineWidth(2.5f);
				canvas.setColorStroke(SUCCESS_COLOR);
				canvas.setLineCap(PdfContentByte.LINE_CAP_ROUND);
				canvas.moveTo(xAux - 3, yAux + 1);
				canvas.lineTo(xAux, yAux - 2);
				canvas.lineTo(xAux + 6, yAux + 6);
				canvas.stroke();
			} else {
				// X mark
				canvas.setLineWidth(2.5f);
				canvas.setColorStroke(ERROR_COLOR);
				canvas.setLineCap(PdfContentByte.LINE_CAP_ROUND);
				canvas.moveTo(xAux - 3, yAux - 3);
				canvas.lineTo(xAux + 3, yAux + 3);
				canvas.stroke();
				canvas.moveTo(xAux - 3, yAux + 3);
				canvas.lineTo(xAux + 3, yAux - 3);
				canvas.stroke();
			}

			// Reset to defaults
			canvas.setLineWidth(1f);
			canvas.setColorFill(Color.BLACK);
			canvas.setColorStroke(Color.BLACK);
			canvas.setLineCap(PdfContentByte.LINE_CAP_BUTT);
		}
	}

	/**
	 * Class used to facilitate the use of the circles in the ImageMapQuestionCellEvent
	 */
	private class Circle {
		@Setter @Getter
		private float x;
		@Setter @Getter
		private float y;
		@Setter @Getter
		private int publishedItemId;

		public Circle(float x, float y, int publishedItemId) {
			this.x = x;
			this.y = y;
			this.publishedItemId = publishedItemId;
		}
	}

}
