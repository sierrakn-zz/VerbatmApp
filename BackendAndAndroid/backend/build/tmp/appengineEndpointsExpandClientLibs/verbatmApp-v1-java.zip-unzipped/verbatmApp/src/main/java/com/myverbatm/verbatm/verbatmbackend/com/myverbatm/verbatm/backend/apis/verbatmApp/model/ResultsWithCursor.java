/*
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except
 * in compliance with the License. You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software distributed under the License
 * is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express
 * or implied. See the License for the specific language governing permissions and limitations under
 * the License.
 */
/*
 * This code was generated by https://code.google.com/p/google-apis-client-generator/
 * (build: 2015-08-03 17:34:38 UTC)
 * on 2015-09-10 at 20:16:44 UTC 
 * Modify at your own risk.
 */

package com.myverbatm.verbatm.verbatmbackend.com.myverbatm.verbatm.backend.apis.verbatmApp.model;

/**
 * Model definition for ResultsWithCursor.
 *
 * <p> This is the Java data model class that specifies how to parse/serialize into the JSON that is
 * transmitted over HTTP when working with the verbatmApp. For a detailed explanation see:
 * <a href="http://code.google.com/p/google-http-java-client/wiki/JSON">http://code.google.com/p/google-http-java-client/wiki/JSON</a>
 * </p>
 *
 * @author Google, Inc.
 */
@SuppressWarnings("javadoc")
public final class ResultsWithCursor extends com.google.api.client.json.GenericJson {

  /**
   * The value may be {@code null}.
   */
  @com.google.api.client.util.Key
  private java.lang.String cursorString;

  /**
   * The value may be {@code null}.
   */
  @com.google.api.client.util.Key
  private java.util.List<POVInfo> results;

  static {
    // hack to force ProGuard to consider POVInfo used, since otherwise it would be stripped out
    // see http://code.google.com/p/google-api-java-client/issues/detail?id=528
    com.google.api.client.util.Data.nullOf(POVInfo.class);
  }

  /**
   * @return value or {@code null} for none
   */
  public java.lang.String getCursorString() {
    return cursorString;
  }

  /**
   * @param cursorString cursorString or {@code null} for none
   */
  public ResultsWithCursor setCursorString(java.lang.String cursorString) {
    this.cursorString = cursorString;
    return this;
  }

  /**
   * @return value or {@code null} for none
   */
  public java.util.List<POVInfo> getResults() {
    return results;
  }

  /**
   * @param results results or {@code null} for none
   */
  public ResultsWithCursor setResults(java.util.List<POVInfo> results) {
    this.results = results;
    return this;
  }

  @Override
  public ResultsWithCursor set(String fieldName, Object value) {
    return (ResultsWithCursor) super.set(fieldName, value);
  }

  @Override
  public ResultsWithCursor clone() {
    return (ResultsWithCursor) super.clone();
  }

}