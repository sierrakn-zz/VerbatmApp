package com.myverbatm.verbatm.backend.models;

import com.google.appengine.api.datastore.Entity;

import java.util.Date;

/**
 * Information about the POV needed to display in the feed
 */
public class POVInfo {

    /**
     * VerbatmUser given title for the POV
     */
    private String title;

    /**
     * The url of the cover picture in the blobstore
     */
    private String coverPicUrl;

    /**
     * Date the POV was published
     */
    private Date datePublished;

    /**
     * Number of up votes this POV has received
     */
    private Integer numUpVotes;

    /**
     * POV's creator's user key
     */
    private Long creatorUserKey;

    /**
     * Creates a POVInfo instance from an Entity containing each property
     * (probably generated by a Projection Query)
     * @param entity
     */
    public POVInfo(Entity entity) {
        this.title = (String) entity.getProperty("title");
        this.coverPicUrl = (String) entity.getProperty("coverPicUrl");
        this.datePublished = (Date) entity.getProperty("datePublished");
        this.numUpVotes = (Integer) entity.getProperty("numUpVotes");
        this.creatorUserKey = (Long) entity.getProperty("creatorUserKey");
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getCoverPicUrl() {
        return coverPicUrl;
    }

    public void setCoverPicUrl(String coverPicUrl) {
        this.coverPicUrl = coverPicUrl;
    }

    public Date getDatePublished() {
        return datePublished;
    }

    public void setDatePublished(Date datePublished) {
        this.datePublished = datePublished;
    }

    public Integer getNumUpVotes() {
        return numUpVotes;
    }

    public void setNumUpVotes(Integer numUpVotes) {
        this.numUpVotes = numUpVotes;
    }

    public Long getCreatorUserKey() {
        return creatorUserKey;
    }

    public void setCreatorUserKey(Long creatorUserKey) {
        this.creatorUserKey = creatorUserKey;
    }
}
