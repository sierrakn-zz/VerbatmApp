package com.myverbatm.verbatm.backend.apis;

import com.google.api.server.spi.ServiceException;
import com.google.api.server.spi.config.Api;
import com.google.api.server.spi.config.ApiClass;
import com.google.api.server.spi.config.ApiMethod;
import com.google.api.server.spi.config.ApiNamespace;
import com.google.api.server.spi.config.Named;
import com.google.api.server.spi.response.BadRequestException;
import com.google.appengine.api.datastore.Cursor;
import com.google.appengine.api.datastore.DatastoreService;
import com.google.appengine.api.datastore.DatastoreServiceFactory;
import com.google.appengine.api.datastore.Entity;
import com.google.appengine.api.datastore.FetchOptions;
import com.google.appengine.api.datastore.Key;
import com.google.appengine.api.datastore.KeyFactory;
import com.google.appengine.api.datastore.PreparedQuery;
import com.google.appengine.api.datastore.PropertyProjection;
import com.google.appengine.api.datastore.Query;
import com.google.appengine.api.datastore.QueryResultList;
import com.google.appengine.api.users.User;
import com.google.appengine.repackaged.org.joda.time.DateTime;
import com.myverbatm.verbatm.backend.Constants;
import com.myverbatm.verbatm.backend.models.IdentifierListWrapper;
import com.myverbatm.verbatm.backend.models.POV;
import com.myverbatm.verbatm.backend.models.POVInfo;
import com.myverbatm.verbatm.backend.models.Page;
import com.myverbatm.verbatm.backend.models.PageListWrapper;
import com.myverbatm.verbatm.backend.models.ResultsWithCursor;
import com.myverbatm.verbatm.backend.models.VerbatmUser;
import com.thoughtworks.xstream.mapper.Mapper;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Date;
import java.util.List;
import java.util.logging.Logger;

import javax.annotation.Nullable;

import static com.myverbatm.verbatm.backend.OfyService.*;

/**
 * Exposes REST API over POV resources
 */
@Api(name = "verbatmApp", version = "v1",
    namespace = @ApiNamespace(
        ownerDomain = Constants.API_OWNER,
        ownerName = Constants.API_OWNER,
        packagePath = Constants.API_PACKAGE_PATH
    )
)
@ApiClass(resource = "pov",
    clientIds = {
        Constants.ANDROID_CLIENT_ID,
        Constants.IOS_CLIENT_ID,
        Constants.WEB_CLIENT_ID},
    audiences = {Constants.AUDIENCE_ID}
)

/**
 * An endpoint class we are exposing.
 */
public class POVEndpoint {

    /**
     * Log output.
     */
    private static final Logger log =
        Logger.getLogger(POVEndpoint.class.getName());

    private static final DatastoreService datastore = DatastoreServiceFactory.getDatastoreService();

    /**
     * Maximum number of povs to return.
     */
    private static final int MAXIMUM_NUMBER_POVS = 100;

    /**
     * Lists POV info (info to be displayed in feed) for most recent POV's
     * Also returns cursor so that the client can query from the place they left off.
     * @param pCount          the maximum number of pov's returned.
     * @param cursorString    the cursor from the last recents query (can be null)
     * @param user            the user that requested the entities.
     * @return List of recent POV info (info to be displayed in feed) and cursor.
     * @throws com.google.api.server.spi.ServiceException if user is not
     * authorized
     */
    @ApiMethod(path="/getRecentPOVs", httpMethod = "GET")
    public final ResultsWithCursor getRecentPOVsInfo(@Named("count") final int pCount,
                                                 @Named("cursor_string") @Nullable final String cursorString,
                                                 final User user) throws
        ServiceException {

        int count = pCount;

        // limit the result set to up to MAXIMUM_NUMBER_PLACES places within
        // up to MAXIMUM_DISTANCE km
        if (count > MAXIMUM_NUMBER_POVS) {
            count = MAXIMUM_NUMBER_POVS;
        } else if (count <= 0) {
            throw new BadRequestException("Invalid value of 'count' argument");
        }

        // Search POV's with dates from latest to earliest (descending)
        // Can also add filter
        Query recentPOVQuery = new Query("POV")
            .addProjection(new PropertyProjection("title", String.class))
            .addProjection(new PropertyProjection("datePublished", Date.class))
            .addProjection(new PropertyProjection("numUpVotes", Long.class))
            .addProjection(new PropertyProjection("creatorUserId", Long.class))
            // Sorting by date published
            .addSort("datePublished", Query.SortDirection.DESCENDING);

        PreparedQuery preparedQuery = datastore.prepare(recentPOVQuery);
        FetchOptions fetchOptions = FetchOptions.Builder.withLimit(count);

        if (cursorString != null) {
            fetchOptions.startCursor(Cursor.fromWebSafeString(cursorString));
        }

        List<POVInfo> results = new ArrayList<>();
        QueryResultList<Entity> entities = preparedQuery.asQueryResultList(fetchOptions);

        for (Entity entity : entities) {
            results.add(new POVInfo(entity));
        }

        String recentsCursorString = entities.getCursor().toWebSafeString();
        return new ResultsWithCursor(results, recentsCursorString);
    }

    /**
     * Lists POV info (info to be displayed in feed) for most upvoted POV's
     * Also returns cursor so that the client can query from the place they left off.
     * @param pCount          the maximum number of pov's returned.
     * @param cursorString    the cursor from the last recents query (can be null)
     * @param user            the user that requested the entities.
     * @return List of recent POV info (info to be displayed in feed) and cursor.
     * @throws com.google.api.server.spi.ServiceException if user is not
     * authorized
     */
    @ApiMethod(path="/getTrendingPOVs", httpMethod = "GET")
    public final ResultsWithCursor getTrendingPOVsInfo(@Named("count") final int pCount,
                                                              @Named("cursor_string") @Nullable final String cursorString,
                                                              final User user) throws
        ServiceException {

        int count = pCount;

        // limit the result set to up to MAXIMUM_NUMBER_PLACES places within
        // up to MAXIMUM_DISTANCE km
        if (count > MAXIMUM_NUMBER_POVS) {
            count = MAXIMUM_NUMBER_POVS;
        } else if (count <= 0) {
            throw new BadRequestException("Invalid value of 'count' argument");
        }

        // Search POV's with upvotes from most to least (descending)
        Query trendingPOVQuery = new Query("POV")
            .addProjection(new PropertyProjection("title", String.class))
            .addProjection(new PropertyProjection("datePublished", Date.class))
            .addProjection(new PropertyProjection("numUpVotes", Long.class))
            .addProjection(new PropertyProjection("creatorUserId", Long.class))
            // Sorting by upvotes
            .addSort("numUpVotes", Query.SortDirection.DESCENDING)
            // Secondary sort by most recent
            .addSort("datePublished", Query.SortDirection.DESCENDING);

        PreparedQuery preparedQuery = datastore.prepare(trendingPOVQuery);
        FetchOptions fetchOptions = FetchOptions.Builder.withLimit(count);

        if (cursorString != null) {
            log.info("Using cursor string: " + cursorString);
            fetchOptions.startCursor(Cursor.fromWebSafeString(cursorString));
        }

        List<POVInfo> results = new ArrayList<>();
        QueryResultList<Entity> entities = preparedQuery.asQueryResultList(fetchOptions);

        for (Entity entity : entities) {
            results.add(new POVInfo(entity));
        }

        Collections.sort(results);
        String trendingCursorString = entities.getCursor().toWebSafeString();
        log.info("Trending POVInfos: " + results.toString());
        log.info("Trending cursor string: " + trendingCursorString);
        return new ResultsWithCursor(results, trendingCursorString);
    }

    /**
     * Returns a list of all the POV's made by a specific user along with the cursor string
     * @param pCount Number of POV's to return
     * @param userId ID of the user who made the POV's to return
     * @param cursorString Cursor string marking the place results were last returned from (can be null)
     * @param user
     * @return List of POV's made by user and the cursor string
     * @throws ServiceException
     */
    @ApiMethod(path="/getUserPOVs", httpMethod = "GET")
    public final ResultsWithCursor getUserPOVsInfo(@Named("count") final int pCount,
                                                   @Named("user_id") final Long userId,
                                                   @Named("cursor_string") @Nullable final String cursorString,
                                                   final User user) throws
        ServiceException {

        int count = pCount;

        // limit the result set to up to MAXIMUM_NUMBER_PLACES places within
        // up to MAXIMUM_DISTANCE km
        if (count > MAXIMUM_NUMBER_POVS) {
            count = MAXIMUM_NUMBER_POVS;
        } else if (count <= 0) {
            throw new BadRequestException("Invalid value of 'count' argument");
        }

        // filter by stories the user has created
        Query.Filter userIdFilter = new Query.FilterPredicate("creatorUserId", Query.FilterOperator.EQUAL, userId);
        // Search POV's that user created sorted by date published
        Query userPOVQuery = new Query("POV")
            .setFilter(userIdFilter)
            .addProjection(new PropertyProjection("title", String.class))
            .addProjection(new PropertyProjection("datePublished", Date.class))
            .addProjection(new PropertyProjection("numUpVotes", Long.class))
                // sort by most recent
            .addSort("datePublished", Query.SortDirection.DESCENDING);

        PreparedQuery preparedQuery = datastore.prepare(userPOVQuery);
        FetchOptions fetchOptions = FetchOptions.Builder.withLimit(count);

        if (cursorString != null) {
            fetchOptions.startCursor(Cursor.fromWebSafeString(cursorString));
        }

        List<POVInfo> results = new ArrayList<>();
        QueryResultList<Entity> entities = preparedQuery.asQueryResultList(fetchOptions);

        for (Entity entity : entities) {
            POVInfo povInfo = new POVInfo(entity);
            povInfo.setCreatorUserId(userId);
            results.add(povInfo);
        }

        Collections.sort(results);
        String resultCursorString = entities.getCursor().toWebSafeString();
        return new ResultsWithCursor(results, resultCursorString);
    }

    /**
     * Gets the Pages from a POV with given id
     *
     * @param id id of the POV
     * @param user the user that requested the entities.
     * @return a list of Pages
     * @throws ServiceException
     */
    @ApiMethod(path="/getPagesFromPOV", httpMethod = "GET")
    public final PageListWrapper getPagesFromPOV(@Named("id") final Long id, final User user)
        throws ServiceException {

        Key povKey = KeyFactory.createKey(POV.class.getSimpleName(), id);
        Query.Filter povIdFilter = new Query.FilterPredicate(Entity.KEY_RESERVED_PROPERTY, Query.FilterOperator.EQUAL, povKey);
        Query pageIdsQuery = new Query("POV")
            .setFilter(povIdFilter)
            // a list property (a property with multiple values) in a projection query
            // will return a separate entity for each time the property matches (so for each pageID)
            .addProjection(new PropertyProjection("pageIds", Long.class));

        PreparedQuery preparedQuery = datastore.prepare(pageIdsQuery);

        List<Entity> entities = preparedQuery.asList(FetchOptions.Builder.withDefaults());
        ArrayList<Page> pages = new ArrayList<>();
        for (Entity entity: entities) {
            Long pageID = (Long) entity.getProperty("pageIds");
            Page page = ofy().load().type(Page.class).id(pageID).now();
            pages.add(page);
        }

        PageListWrapper pageListWrapper = new PageListWrapper();
        pageListWrapper.pages = pages;
        return pageListWrapper;
    }

    /**
     *  Gets the user Ids who have a liked a POV from the given POV
     *
     * @param id the id of the POV
     * @return IdentifierListWrapper - a list of user ids
     */
    @ApiMethod(path="/getUserIdsWhoLikeThisPOV", httpMethod = "GET")
    public final IdentifierListWrapper getUserIdsWhoLikeThisPOV(@Named("id") final Long id) {
        Key povKey = KeyFactory.createKey(POV.class.getSimpleName(), id);
        Query.Filter povIdFilter = new Query.FilterPredicate(Entity.KEY_RESERVED_PROPERTY, Query.FilterOperator.EQUAL, povKey);
        Query pageIdsQuery = new Query("POV")
            .setFilter(povIdFilter)
                // a list property (a property with multiple values) in a projection query
                // will return a separate entity for each time the property matches (so for each pageID)
            .addProjection(new PropertyProjection("usersWhoHaveLikedIDs", Long.class));

        PreparedQuery preparedQuery = datastore.prepare(pageIdsQuery);

        List<Entity> entities = preparedQuery.asList(FetchOptions.Builder.withDefaults());
        ArrayList<Long> userIds = new ArrayList<>();
        for (Entity entity: entities) {
            Long userId = (Long) entity.getProperty("usersWhoHaveLikedIDs");
            userIds.add(userId);
        }

        IdentifierListWrapper identifierListWrapper = new IdentifierListWrapper();
        identifierListWrapper.identifiers = userIds;
        return identifierListWrapper;
    }

    /**
     * Gets the entity having primary key id.
     *
     * @param id   the primary key of the java bean.
     * @param user the user requesting the entity.
     * @return The entity with primary key id.
     * @throws com.google.api.server.spi.ServiceException if user is not
     *                                                    authorized
     */
    @ApiMethod(path="/getPOVFromID", httpMethod = "GET")
    public final POV getPOV(@Named("id") final Long id, final User user)
        throws ServiceException {
//        EndpointUtil.throwIfNotAdmin(user);

        return findPOV(id);
    }

    /**
     * Inserts the entity into App Engine datastore. It uses HTTP POST method.
     *
     * @param pov  the entity to be inserted.
     * @param user the user trying to insert the entity.
     * @return The inserted entity.
     * @throws com.google.api.server.spi.ServiceException if user is not
     *                                                    authorized
     */
    @ApiMethod(httpMethod = "POST")
    public final POV insertPOV(final POV pov, final User user)
        throws ServiceException {
//        EndpointUtil.throwIfNotAuthenticated(user);

        // Do not use the key provided by the caller; use a generated key.
        pov.clearId();
        ofy().save().entity(pov).now();
        return pov;
    }

    /**
     * Updates a entity. It uses HTTP PUT method.
     *
     * @param pov the entity to be updated.
     * @param user    the user trying to update the entity.
     * @return The updated entity.
     * @throws com.google.api.server.spi.ServiceException if user is not
     *                                                    authorized
     */
    @ApiMethod(httpMethod = "PUT")
    public final POV updatePOV(final POV pov, final User user)
        throws ServiceException {
//        EndpointUtil.throwIfNotAdmin(user);

        ofy().save().entity(pov).now();

        return pov;
    }

    /**
     * Removes the entity with primary key id. It uses HTTP DELETE method.
     *
     * @param id   the primary key of the entity to be deleted.
     * @param user the user trying to delete the entity.
     * @throws com.google.api.server.spi.ServiceException if user is not
     *                                                    authorized
     */
    @ApiMethod(httpMethod = "DELETE")
    public final void removePOV(@Named("id") final Long id, final User user)
        throws ServiceException {
//        EndpointUtil.throwIfNotAdmin(user);

        POV pov = findPOV(id);
        if (pov == null) {
            log.info(
                "POV " + id + " not found, skipping deletion.");
            return;
        }
        ofy().delete().entity(pov).now();
    }

    /**
     * Searches an entity by ID.
     *
     * @param id the pov ID to search
     * @return the pov associated to id
     */
    private POV findPOV(final Long id) {
        return ofy().load().type(POV.class).id(id).now();
    }

}
