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
 * (build: 2016-01-08 17:48:37 UTC)
 * on 2016-01-18 at 19:23:09 UTC 
 * Modify at your own risk.
 */

package com.myverbatm.verbatm.verbatmbackend.com.myverbatm.verbatm.backend.apis.verbatmApp.model;

/**
 * Model definition for Post.
 *
 * <p> This is the Java data model class that specifies how to parse/serialize into the JSON that is
 * transmitted over HTTP when working with the verbatmApp. For a detailed explanation see:
 * <a href="https://developers.google.com/api-client-library/java/google-http-java-client/json">https://developers.google.com/api-client-library/java/google-http-java-client/json</a>
 * </p>
 *
 * @author Google, Inc.
 */
@SuppressWarnings("javadoc")
public final class Post extends com.google.api.client.json.GenericJson {

  /**
   * The value may be {@code null}.
   */
  @com.google.api.client.util.Key
  private java.lang.Integer channelId;

  /**
   * The value may be {@code null}.
   */
  @com.google.api.client.util.Key
  private Timestamp dateCreated;

  /**
   * The value may be {@code null}.
   */
  @com.google.api.client.util.Key
  private java.lang.Integer id;

  /**
   * The value may be {@code null}.
   */
  @com.google.api.client.util.Key
  private ImageListWrapper images;

  /**
   * The value may be {@code null}.
   */
  @com.google.api.client.util.Key
  private PageListWrapper pages;

  /**
   * The value may be {@code null}.
   */
  @com.google.api.client.util.Key
  private java.lang.Integer sharedFromPostId;

  /**
   * The value may be {@code null}.
   */
  @com.google.api.client.util.Key
  private VideoListWrapper videos;

  /**
   * @return value or {@code null} for none
   */
  public java.lang.Integer getChannelId() {
    return channelId;
  }

  /**
   * @param channelId channelId or {@code null} for none
   */
  public Post setChannelId(java.lang.Integer channelId) {
    this.channelId = channelId;
    return this;
  }

  /**
   * @return value or {@code null} for none
   */
  public Timestamp getDateCreated() {
    return dateCreated;
  }

  /**
   * @param dateCreated dateCreated or {@code null} for none
   */
  public Post setDateCreated(Timestamp dateCreated) {
    this.dateCreated = dateCreated;
    return this;
  }

  /**
   * @return value or {@code null} for none
   */
  public java.lang.Integer getId() {
    return id;
  }

  /**
   * @param id id or {@code null} for none
   */
  public Post setId(java.lang.Integer id) {
    this.id = id;
    return this;
  }

  /**
   * @return value or {@code null} for none
   */
  public ImageListWrapper getImages() {
    return images;
  }

  /**
   * @param images images or {@code null} for none
   */
  public Post setImages(ImageListWrapper images) {
    this.images = images;
    return this;
  }

  /**
   * @return value or {@code null} for none
   */
  public PageListWrapper getPages() {
    return pages;
  }

  /**
   * @param pages pages or {@code null} for none
   */
  public Post setPages(PageListWrapper pages) {
    this.pages = pages;
    return this;
  }

  /**
   * @return value or {@code null} for none
   */
  public java.lang.Integer getSharedFromPostId() {
    return sharedFromPostId;
  }

  /**
   * @param sharedFromPostId sharedFromPostId or {@code null} for none
   */
  public Post setSharedFromPostId(java.lang.Integer sharedFromPostId) {
    this.sharedFromPostId = sharedFromPostId;
    return this;
  }

  /**
   * @return value or {@code null} for none
   */
  public VideoListWrapper getVideos() {
    return videos;
  }

  /**
   * @param videos videos or {@code null} for none
   */
  public Post setVideos(VideoListWrapper videos) {
    this.videos = videos;
    return this;
  }

  @Override
  public Post set(String fieldName, Object value) {
    return (Post) super.set(fieldName, value);
  }

  @Override
  public Post clone() {
    return (Post) super.clone();
  }

}
