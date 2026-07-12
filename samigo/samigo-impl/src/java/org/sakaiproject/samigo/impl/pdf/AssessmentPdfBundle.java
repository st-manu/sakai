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
package org.sakaiproject.samigo.impl.pdf;

import java.util.ResourceBundle;

public final class AssessmentPdfBundle {

    private static final String AUTHOR = "org.sakaiproject.tool.assessment.bundle.AuthorMessages";
    private static final String EVALUATION = "org.sakaiproject.tool.assessment.bundle.EvaluationMessages";
    private static final String PRINT = "org.sakaiproject.tool.assessment.bundle.PrintMessages";
    private static final String COMMON = "org.sakaiproject.tool.assessment.bundle.CommonMessages";
    private static final String DELIVERY = "org.sakaiproject.tool.assessment.bundle.DeliveryMessages";

    private static ResourceBundle authorBundle;
    private static ResourceBundle evaluationBundle;
    private static ResourceBundle printBundle;
    private static ResourceBundle commonBundle;
    private static ResourceBundle deliveryBundle;

    private AssessmentPdfBundle() {
    }

    public static String getAuthorString(String key) {
        return authorBundle().getString(key);
    }

    public static String getEvaluationString(String key) {
        return evaluationBundle().getString(key);
    }

    public static String getPrintString(String key) {
        return printBundle().getString(key);
    }

    public static String getCommonString(String key) {
        return commonBundle().getString(key);
    }

    public static String getDeliveryString(String key) {
        return deliveryBundle().getString(key);
    }

    private static ResourceBundle authorBundle() {
        if (authorBundle == null) {
            authorBundle = ResourceBundle.getBundle(AUTHOR);
        }
        return authorBundle;
    }

    private static ResourceBundle evaluationBundle() {
        if (evaluationBundle == null) {
            evaluationBundle = ResourceBundle.getBundle(EVALUATION);
        }
        return evaluationBundle;
    }

    private static ResourceBundle printBundle() {
        if (printBundle == null) {
            printBundle = ResourceBundle.getBundle(PRINT);
        }
        return printBundle;
    }

    private static ResourceBundle commonBundle() {
        if (commonBundle == null) {
            commonBundle = ResourceBundle.getBundle(COMMON);
        }
        return commonBundle;
    }

    private static ResourceBundle deliveryBundle() {
        if (deliveryBundle == null) {
            deliveryBundle = ResourceBundle.getBundle(DELIVERY);
        }
        return deliveryBundle;
    }
}
