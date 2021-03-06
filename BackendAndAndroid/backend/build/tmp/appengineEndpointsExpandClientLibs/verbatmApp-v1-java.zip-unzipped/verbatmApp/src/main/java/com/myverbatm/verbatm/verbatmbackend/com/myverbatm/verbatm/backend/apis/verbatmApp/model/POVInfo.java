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
 * This code was generated by https://github.com/google/apis-client-generator/
 * (build: 2016-02-18 22:11:37 UTC)
 * on 2016-03-26 at 23:52:29 UTC 
 * Modify at your own risk.
 */

package com.myverbatm.verbatm.verbatmbackend.com.myverbatm.verbatm.backend.apis.verbatmApp.model;

/**
 * Model definition for POVInfo.
 *
 * <p> This is the Java data model class that specifies how to parse/serialize into the JSON that is
 * transmitted over HTTP when working with the verbatmApp. For a detailed explanation see:
 * <a href="https://developers.google.com/api-client-library/java/google-http-java-client/json">https://developers.google.com/api-client-library/java/google-http-java-client/json</a>
 * </p>
 *
 * @author Google, Inc.
 */
@SuppressWarnings("javadoc")
public final class POVInfo extends com.google.api.client.json.GenericJson {

  /**
   * The value may be {@code null}.
   */
  @com.google.api.client.util.Key @com.google.api.client.json.JsonString
  private java.lang.Long creatorUserId;

  /**
   * The value may be {@code null}.
   */
  @com.google.api.client.util.Key
  private com.google.api.client.util.DateTime datePublished;

  /**
   * The value may be {@code null}.
   */
  @com.google.api.client.util.Key @com.google.api.client.json.JsonString
  private java.lang.Long id;

  /**
   * The value may be {@code null}.
   */
  @com.google.api.client.util.Key @com.google.api.client.json.JsonString
  private java.lang.Long numUpVotes;

  /**
   * The value may be {@code null}.
   */
  @com.google.api.client.util.Key
  private java.lang.String title;

  /**
   * @return value or {@code null} for none
   */
  public java.lang.Long getCreatorUserId() {
    return creatorUserId;
  }

  /**
   * @param creatorUserId creatorUserId or {@code null} for none
   */
  public POVInfo setCreatorUserId(java.lang.Long creatorUserId) {
    this.creatorUserId = creatorUserId;
    return this;
  }

  /**
   * @return value or {@code null} for none
   */
  public com.google.api.client.util.DateTime getDatePublished() {
    return datePublished;
  }

  /**
   * @param datePublished datePublished or {@code null} for none
   */
  public POVInfo setDatePublished(com.google.api.client.util.DateTime datePublished) {
    this.datePublished = datePublished;
    return this;
  }

  /**
   * @return value or {@code null} for none
   */
  public java.lang.Long getId() {
    return id;
  }

  /**
   * @param id id or {@code null} for none
   */
  public POVInfo setId(java.lang.Long id) {
    this.id = id;
    return this;
  }

  /**
   * @return value or {@code null} for none
   */
  public java.lang.Long getNumUpVotes() {
    return numUpVotes;
  }

  /**
   * @param numUpVotes numUpVotes or {@code null} for none
   */
  public POVInfo setNumUpVotes(java.lang.Long numUpVotes) {
    this.numUpVotes = numUpVotes;
    return this;
  }

  /**
   * @return value or {@code null} for none
   */
  public java.lang.String getTitle() {
    return title;
  }

  /**
   * @param title title or {@code null} for none
   */
  public POVInfo setTitle(java.lang.String title) {
    this.title = title;
    return this;
  }

  @Override
  public POVInfo set(String fieldName, Object value) {
    return (POVInfo) super.set(fieldName, value);
  }

  @Override
  public POVInfo clone() {
    return (POVInfo) super.clone();
  }

}
