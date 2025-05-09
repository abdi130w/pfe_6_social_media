--
-- PostgreSQL database dump
--

-- Dumped from database version 17.4
-- Dumped by pg_dump version 17.4

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: r; Type: SCHEMA; Schema: -; Owner: lemmy
--

CREATE SCHEMA r;


ALTER SCHEMA r OWNER TO lemmy;

--
-- Name: utils; Type: SCHEMA; Schema: -; Owner: lemmy
--

CREATE SCHEMA utils;


ALTER SCHEMA utils OWNER TO lemmy;

--
-- Name: ltree; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS ltree WITH SCHEMA public;


--
-- Name: EXTENSION ltree; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION ltree IS 'data type for hierarchical tree-like structures';


--
-- Name: pg_trgm; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;


--
-- Name: EXTENSION pg_trgm; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pg_trgm IS 'text similarity measurement and index searching based on trigrams';


--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: actor_type_enum; Type: TYPE; Schema: public; Owner: lemmy
--

CREATE TYPE public.actor_type_enum AS ENUM (
    'site',
    'community',
    'person'
);


ALTER TYPE public.actor_type_enum OWNER TO lemmy;

--
-- Name: community_visibility; Type: TYPE; Schema: public; Owner: lemmy
--

CREATE TYPE public.community_visibility AS ENUM (
    'Public',
    'LocalOnly'
);


ALTER TYPE public.community_visibility OWNER TO lemmy;

--
-- Name: listing_type_enum; Type: TYPE; Schema: public; Owner: lemmy
--

CREATE TYPE public.listing_type_enum AS ENUM (
    'All',
    'Local',
    'Subscribed',
    'ModeratorView'
);


ALTER TYPE public.listing_type_enum OWNER TO lemmy;

--
-- Name: post_listing_mode_enum; Type: TYPE; Schema: public; Owner: lemmy
--

CREATE TYPE public.post_listing_mode_enum AS ENUM (
    'List',
    'Card',
    'SmallCard'
);


ALTER TYPE public.post_listing_mode_enum OWNER TO lemmy;

--
-- Name: registration_mode_enum; Type: TYPE; Schema: public; Owner: lemmy
--

CREATE TYPE public.registration_mode_enum AS ENUM (
    'Closed',
    'RequireApplication',
    'Open'
);


ALTER TYPE public.registration_mode_enum OWNER TO lemmy;

--
-- Name: sort_type_enum; Type: TYPE; Schema: public; Owner: lemmy
--

CREATE TYPE public.sort_type_enum AS ENUM (
    'Active',
    'Hot',
    'New',
    'Old',
    'TopDay',
    'TopWeek',
    'TopMonth',
    'TopYear',
    'TopAll',
    'MostComments',
    'NewComments',
    'TopHour',
    'TopSixHour',
    'TopTwelveHour',
    'TopThreeMonths',
    'TopSixMonths',
    'TopNineMonths',
    'Controversial',
    'Scaled'
);


ALTER TYPE public.sort_type_enum OWNER TO lemmy;

--
-- Name: diesel_manage_updated_at(regclass); Type: FUNCTION; Schema: public; Owner: lemmy
--

CREATE FUNCTION public.diesel_manage_updated_at(_tbl regclass) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    EXECUTE format('CREATE TRIGGER set_updated_at BEFORE UPDATE ON %s
                    FOR EACH ROW EXECUTE PROCEDURE diesel_set_updated_at()', _tbl);
END;
$$;


ALTER FUNCTION public.diesel_manage_updated_at(_tbl regclass) OWNER TO lemmy;

--
-- Name: diesel_set_updated_at(); Type: FUNCTION; Schema: public; Owner: lemmy
--

CREATE FUNCTION public.diesel_set_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF (NEW IS DISTINCT FROM OLD AND NEW.updated_at IS NOT DISTINCT FROM OLD.updated_at) THEN
        NEW.updated_at := CURRENT_TIMESTAMP;
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.diesel_set_updated_at() OWNER TO lemmy;

--
-- Name: drop_ccnew_indexes(); Type: FUNCTION; Schema: public; Owner: lemmy
--

CREATE FUNCTION public.drop_ccnew_indexes() RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    i RECORD;
BEGIN
    FOR i IN (
        SELECT
            relname
        FROM
            pg_class
        WHERE
            relname LIKE '%ccnew%')
        LOOP
            EXECUTE 'DROP INDEX ' || i.relname;
        END LOOP;
    RETURN 1;
END;
$$;


ALTER FUNCTION public.drop_ccnew_indexes() OWNER TO lemmy;

--
-- Name: generate_unique_changeme(); Type: FUNCTION; Schema: public; Owner: lemmy
--

CREATE FUNCTION public.generate_unique_changeme() RETURNS text
    LANGUAGE sql
    AS $$
    SELECT
        'http://changeme.invalid/seq/' || nextval('changeme_seq')::text;
$$;


ALTER FUNCTION public.generate_unique_changeme() OWNER TO lemmy;

--
-- Name: reverse_timestamp_sort(timestamp with time zone); Type: FUNCTION; Schema: public; Owner: lemmy
--

CREATE FUNCTION public.reverse_timestamp_sort(t timestamp with time zone) RETURNS bigint
    LANGUAGE plpgsql IMMUTABLE PARALLEL SAFE
    AS $$
BEGIN
    RETURN (-1000000 * EXTRACT(EPOCH FROM t))::bigint;
END;
$$;


ALTER FUNCTION public.reverse_timestamp_sort(t timestamp with time zone) OWNER TO lemmy;

--
-- Name: comment_aggregates_from_comment(); Type: FUNCTION; Schema: r; Owner: lemmy
--

CREATE FUNCTION r.comment_aggregates_from_comment() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO comment_aggregates (comment_id, published)
    SELECT
        id,
        published
    FROM
        new_comment;
    RETURN NULL;
END;
$$;


ALTER FUNCTION r.comment_aggregates_from_comment() OWNER TO lemmy;

--
-- Name: comment_change_values(); Type: FUNCTION; Schema: r; Owner: lemmy
--

CREATE FUNCTION r.comment_change_values() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    id text = NEW.id::text;
BEGIN
    -- Make `path` end with `id` if it doesn't already
    IF NOT (NEW.path ~ ('*.' || id)::lquery) THEN
        NEW.path = NEW.path || id;
    END IF;
    -- Set local ap_id
    IF NEW.local THEN
        NEW.ap_id = coalesce(NEW.ap_id, r.local_url ('/comment/' || id));
    END IF;
    RETURN NEW;
END
$$;


ALTER FUNCTION r.comment_change_values() OWNER TO lemmy;

--
-- Name: comment_delete_statement(); Type: FUNCTION; Schema: r; Owner: lemmy
--

CREATE FUNCTION r.comment_delete_statement() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE
        person_aggregates AS a
    SET
        comment_count = a.comment_count + diff.comment_count
    FROM (
        SELECT
            (comment).creator_id, coalesce(sum(count_diff), 0) AS comment_count
        FROM  (
        SELECT
            -1 AS count_diff,
            old_table::comment AS comment
        FROM
            select_old_rows AS old_table
        UNION ALL
        SELECT
            1 AS count_diff,
            new_table::comment AS comment
        FROM
             (
        SELECT
            *
        FROM
            -- Real transition table
            select_old_rows
        WHERE
            FALSE)  AS new_table)  AS old_and_new_rows
        WHERE
            r.is_counted (comment)
        GROUP BY (comment).creator_id) AS diff
WHERE
    a.person_id = diff.creator_id
        AND diff.comment_count != 0;

UPDATE
    comment_aggregates AS a
SET
    child_count = a.child_count + diff.child_count
FROM (
    SELECT
        parent_id,
        coalesce(sum(count_diff), 0) AS child_count
    FROM (
        -- For each inserted or deleted comment, this outputs 1 row for each parent comment.
        -- For example, this:
        --
        --  count_diff | (comment).path
        -- ------------+----------------
        --  1          | 0.5.6.7
        --  1          | 0.5.6.7.8
        --
        -- becomes this:
        --
        --  count_diff | parent_id
        -- ------------+-----------
        --  1          | 5
        --  1          | 6
        --  1          | 5
        --  1          | 6
        --  1          | 7
        SELECT
            count_diff,
            parent_id
        FROM
             (
        SELECT
            -1 AS count_diff,
            old_table::comment AS comment
        FROM
            select_old_rows AS old_table
        UNION ALL
        SELECT
            1 AS count_diff,
            new_table::comment AS comment
        FROM
             (
        SELECT
            *
        FROM
            -- Real transition table
            select_old_rows
        WHERE
            FALSE)  AS new_table)  AS old_and_new_rows,
            LATERAL r.parent_comment_ids ((comment).path) AS parent_id) AS expanded_old_and_new_rows
    GROUP BY
        parent_id) AS diff
WHERE
    a.comment_id = diff.parent_id
    AND diff.child_count != 0;

WITH post_diff AS (
    UPDATE
        post_aggregates AS a
    SET
        comments = a.comments + diff.comments,
        newest_comment_time = GREATEST (a.newest_comment_time, diff.newest_comment_time),
        newest_comment_time_necro = GREATEST (a.newest_comment_time_necro, diff.newest_comment_time_necro)
    FROM (
        SELECT
            post.id AS post_id,
            coalesce(sum(count_diff), 0) AS comments,
            -- Old rows are excluded using `count_diff = 1`
            max((comment).published) FILTER (WHERE count_diff = 1) AS newest_comment_time,
            max((comment).published) FILTER (WHERE count_diff = 1
                -- Ignore comments from the post's creator
                AND post.creator_id != (comment).creator_id
            -- Ignore comments on old posts
            AND post.published > ((comment).published - '2 days'::interval)) AS newest_comment_time_necro,
        r.is_counted (post.*) AS include_in_community_aggregates
    FROM
         (
        SELECT
            -1 AS count_diff,
            old_table::comment AS comment
        FROM
            select_old_rows AS old_table
        UNION ALL
        SELECT
            1 AS count_diff,
            new_table::comment AS comment
        FROM
             (
        SELECT
            *
        FROM
            -- Real transition table
            select_old_rows
        WHERE
            FALSE)  AS new_table)  AS old_and_new_rows
        LEFT JOIN post ON post.id = (comment).post_id
    WHERE
        r.is_counted (comment)
    GROUP BY
        post.id) AS diff
    WHERE
        a.post_id = diff.post_id
        AND (diff.comments,
            GREATEST (a.newest_comment_time, diff.newest_comment_time),
            GREATEST (a.newest_comment_time_necro, diff.newest_comment_time_necro)) != (0,
            a.newest_comment_time,
            a.newest_comment_time_necro)
    RETURNING
        a.community_id,
        diff.comments,
        diff.include_in_community_aggregates)
UPDATE
    community_aggregates AS a
SET
    comments = a.comments + diff.comments
FROM (
    SELECT
        community_id,
        sum(comments) AS comments
    FROM
        post_diff
    WHERE
        post_diff.include_in_community_aggregates
    GROUP BY
        community_id) AS diff
WHERE
    a.community_id = diff.community_id
    AND diff.comments != 0;

UPDATE
    site_aggregates AS a
SET
    comments = a.comments + diff.comments
FROM (
    SELECT
        coalesce(sum(count_diff), 0) AS comments
    FROM
         (
        SELECT
            -1 AS count_diff,
            old_table::comment AS comment
        FROM
            select_old_rows AS old_table
        UNION ALL
        SELECT
            1 AS count_diff,
            new_table::comment AS comment
        FROM
             (
        SELECT
            *
        FROM
            -- Real transition table
            select_old_rows
        WHERE
            FALSE)  AS new_table)  AS old_and_new_rows
    WHERE
        r.is_counted (comment)
        AND (comment).local) AS diff
WHERE
    diff.comments != 0;

RETURN NULL;

END;

$$;


ALTER FUNCTION r.comment_delete_statement() OWNER TO lemmy;

--
-- Name: comment_insert_statement(); Type: FUNCTION; Schema: r; Owner: lemmy
--

CREATE FUNCTION r.comment_insert_statement() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE
        person_aggregates AS a
    SET
        comment_count = a.comment_count + diff.comment_count
    FROM (
        SELECT
            (comment).creator_id, coalesce(sum(count_diff), 0) AS comment_count
        FROM  (
        SELECT
            -1 AS count_diff,
            old_table::comment AS comment
        FROM
             (
        SELECT
            *
        FROM
            -- Real transition table
            select_new_rows
        WHERE
            FALSE)  AS old_table
        UNION ALL
        SELECT
            1 AS count_diff,
            new_table::comment AS comment
        FROM
            select_new_rows AS new_table)  AS old_and_new_rows
        WHERE
            r.is_counted (comment)
        GROUP BY (comment).creator_id) AS diff
WHERE
    a.person_id = diff.creator_id
        AND diff.comment_count != 0;

UPDATE
    comment_aggregates AS a
SET
    child_count = a.child_count + diff.child_count
FROM (
    SELECT
        parent_id,
        coalesce(sum(count_diff), 0) AS child_count
    FROM (
        -- For each inserted or deleted comment, this outputs 1 row for each parent comment.
        -- For example, this:
        --
        --  count_diff | (comment).path
        -- ------------+----------------
        --  1          | 0.5.6.7
        --  1          | 0.5.6.7.8
        --
        -- becomes this:
        --
        --  count_diff | parent_id
        -- ------------+-----------
        --  1          | 5
        --  1          | 6
        --  1          | 5
        --  1          | 6
        --  1          | 7
        SELECT
            count_diff,
            parent_id
        FROM
             (
        SELECT
            -1 AS count_diff,
            old_table::comment AS comment
        FROM
             (
        SELECT
            *
        FROM
            -- Real transition table
            select_new_rows
        WHERE
            FALSE)  AS old_table
        UNION ALL
        SELECT
            1 AS count_diff,
            new_table::comment AS comment
        FROM
            select_new_rows AS new_table)  AS old_and_new_rows,
            LATERAL r.parent_comment_ids ((comment).path) AS parent_id) AS expanded_old_and_new_rows
    GROUP BY
        parent_id) AS diff
WHERE
    a.comment_id = diff.parent_id
    AND diff.child_count != 0;

WITH post_diff AS (
    UPDATE
        post_aggregates AS a
    SET
        comments = a.comments + diff.comments,
        newest_comment_time = GREATEST (a.newest_comment_time, diff.newest_comment_time),
        newest_comment_time_necro = GREATEST (a.newest_comment_time_necro, diff.newest_comment_time_necro)
    FROM (
        SELECT
            post.id AS post_id,
            coalesce(sum(count_diff), 0) AS comments,
            -- Old rows are excluded using `count_diff = 1`
            max((comment).published) FILTER (WHERE count_diff = 1) AS newest_comment_time,
            max((comment).published) FILTER (WHERE count_diff = 1
                -- Ignore comments from the post's creator
                AND post.creator_id != (comment).creator_id
            -- Ignore comments on old posts
            AND post.published > ((comment).published - '2 days'::interval)) AS newest_comment_time_necro,
        r.is_counted (post.*) AS include_in_community_aggregates
    FROM
         (
        SELECT
            -1 AS count_diff,
            old_table::comment AS comment
        FROM
             (
        SELECT
            *
        FROM
            -- Real transition table
            select_new_rows
        WHERE
            FALSE)  AS old_table
        UNION ALL
        SELECT
            1 AS count_diff,
            new_table::comment AS comment
        FROM
            select_new_rows AS new_table)  AS old_and_new_rows
        LEFT JOIN post ON post.id = (comment).post_id
    WHERE
        r.is_counted (comment)
    GROUP BY
        post.id) AS diff
    WHERE
        a.post_id = diff.post_id
        AND (diff.comments,
            GREATEST (a.newest_comment_time, diff.newest_comment_time),
            GREATEST (a.newest_comment_time_necro, diff.newest_comment_time_necro)) != (0,
            a.newest_comment_time,
            a.newest_comment_time_necro)
    RETURNING
        a.community_id,
        diff.comments,
        diff.include_in_community_aggregates)
UPDATE
    community_aggregates AS a
SET
    comments = a.comments + diff.comments
FROM (
    SELECT
        community_id,
        sum(comments) AS comments
    FROM
        post_diff
    WHERE
        post_diff.include_in_community_aggregates
    GROUP BY
        community_id) AS diff
WHERE
    a.community_id = diff.community_id
    AND diff.comments != 0;

UPDATE
    site_aggregates AS a
SET
    comments = a.comments + diff.comments
FROM (
    SELECT
        coalesce(sum(count_diff), 0) AS comments
    FROM
         (
        SELECT
            -1 AS count_diff,
            old_table::comment AS comment
        FROM
             (
        SELECT
            *
        FROM
            -- Real transition table
            select_new_rows
        WHERE
            FALSE)  AS old_table
        UNION ALL
        SELECT
            1 AS count_diff,
            new_table::comment AS comment
        FROM
            select_new_rows AS new_table)  AS old_and_new_rows
    WHERE
        r.is_counted (comment)
        AND (comment).local) AS diff
WHERE
    diff.comments != 0;

RETURN NULL;

END;

$$;


ALTER FUNCTION r.comment_insert_statement() OWNER TO lemmy;

--
-- Name: comment_like_delete_statement(); Type: FUNCTION; Schema: r; Owner: lemmy
--

CREATE FUNCTION r.comment_like_delete_statement() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
            BEGIN
                WITH comment_diff AS ( UPDATE
                        comment_aggregates AS a
                    SET
                        score = a.score + diff.upvotes - diff.downvotes, upvotes = a.upvotes + diff.upvotes, downvotes = a.downvotes + diff.downvotes, controversy_rank = r.controversy_rank ((a.upvotes + diff.upvotes)::numeric, (a.downvotes + diff.downvotes)::numeric)
                    FROM (
                        SELECT
                            (comment_like).comment_id, coalesce(sum(count_diff) FILTER (WHERE (comment_like).score = 1), 0) AS upvotes, coalesce(sum(count_diff) FILTER (WHERE (comment_like).score != 1), 0) AS downvotes FROM  (
        SELECT
            -1 AS count_diff,
            old_table::comment_like AS comment_like
        FROM
            select_old_rows AS old_table
        UNION ALL
        SELECT
            1 AS count_diff,
            new_table::comment_like AS comment_like
        FROM
             (
        SELECT
            *
        FROM
            -- Real transition table
            select_old_rows
        WHERE
            FALSE)  AS new_table)  AS old_and_new_rows GROUP BY (comment_like).comment_id) AS diff
            WHERE
                a.comment_id = diff.comment_id
                    AND (diff.upvotes, diff.downvotes) != (0, 0)
                RETURNING
                    r.creator_id_from_comment_aggregates (a.*) AS creator_id, diff.upvotes - diff.downvotes AS score)
            UPDATE
                person_aggregates AS a
            SET
                comment_score = a.comment_score + diff.score FROM (
                    SELECT
                        creator_id, sum(score) AS score FROM comment_diff GROUP BY creator_id) AS diff
                WHERE
                    a.person_id = diff.creator_id
                    AND diff.score != 0;
                RETURN NULL;
            END;
    $$;


ALTER FUNCTION r.comment_like_delete_statement() OWNER TO lemmy;

--
-- Name: comment_like_insert_statement(); Type: FUNCTION; Schema: r; Owner: lemmy
--

CREATE FUNCTION r.comment_like_insert_statement() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
            BEGIN
                WITH comment_diff AS ( UPDATE
                        comment_aggregates AS a
                    SET
                        score = a.score + diff.upvotes - diff.downvotes, upvotes = a.upvotes + diff.upvotes, downvotes = a.downvotes + diff.downvotes, controversy_rank = r.controversy_rank ((a.upvotes + diff.upvotes)::numeric, (a.downvotes + diff.downvotes)::numeric)
                    FROM (
                        SELECT
                            (comment_like).comment_id, coalesce(sum(count_diff) FILTER (WHERE (comment_like).score = 1), 0) AS upvotes, coalesce(sum(count_diff) FILTER (WHERE (comment_like).score != 1), 0) AS downvotes FROM  (
        SELECT
            -1 AS count_diff,
            old_table::comment_like AS comment_like
        FROM
             (
        SELECT
            *
        FROM
            -- Real transition table
            select_new_rows
        WHERE
            FALSE)  AS old_table
        UNION ALL
        SELECT
            1 AS count_diff,
            new_table::comment_like AS comment_like
        FROM
            select_new_rows AS new_table)  AS old_and_new_rows GROUP BY (comment_like).comment_id) AS diff
            WHERE
                a.comment_id = diff.comment_id
                    AND (diff.upvotes, diff.downvotes) != (0, 0)
                RETURNING
                    r.creator_id_from_comment_aggregates (a.*) AS creator_id, diff.upvotes - diff.downvotes AS score)
            UPDATE
                person_aggregates AS a
            SET
                comment_score = a.comment_score + diff.score FROM (
                    SELECT
                        creator_id, sum(score) AS score FROM comment_diff GROUP BY creator_id) AS diff
                WHERE
                    a.person_id = diff.creator_id
                    AND diff.score != 0;
                RETURN NULL;
            END;
    $$;


ALTER FUNCTION r.comment_like_insert_statement() OWNER TO lemmy;

--
-- Name: comment_like_update_statement(); Type: FUNCTION; Schema: r; Owner: lemmy
--

CREATE FUNCTION r.comment_like_update_statement() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
            BEGIN
                WITH comment_diff AS ( UPDATE
                        comment_aggregates AS a
                    SET
                        score = a.score + diff.upvotes - diff.downvotes, upvotes = a.upvotes + diff.upvotes, downvotes = a.downvotes + diff.downvotes, controversy_rank = r.controversy_rank ((a.upvotes + diff.upvotes)::numeric, (a.downvotes + diff.downvotes)::numeric)
                    FROM (
                        SELECT
                            (comment_like).comment_id, coalesce(sum(count_diff) FILTER (WHERE (comment_like).score = 1), 0) AS upvotes, coalesce(sum(count_diff) FILTER (WHERE (comment_like).score != 1), 0) AS downvotes FROM  (
        SELECT
            -1 AS count_diff,
            old_table::comment_like AS comment_like
        FROM
            select_old_rows AS old_table
        UNION ALL
        SELECT
            1 AS count_diff,
            new_table::comment_like AS comment_like
        FROM
            select_new_rows AS new_table)  AS old_and_new_rows GROUP BY (comment_like).comment_id) AS diff
            WHERE
                a.comment_id = diff.comment_id
                    AND (diff.upvotes, diff.downvotes) != (0, 0)
                RETURNING
                    r.creator_id_from_comment_aggregates (a.*) AS creator_id, diff.upvotes - diff.downvotes AS score)
            UPDATE
                person_aggregates AS a
            SET
                comment_score = a.comment_score + diff.score FROM (
                    SELECT
                        creator_id, sum(score) AS score FROM comment_diff GROUP BY creator_id) AS diff
                WHERE
                    a.person_id = diff.creator_id
                    AND diff.score != 0;
                RETURN NULL;
            END;
    $$;


ALTER FUNCTION r.comment_like_update_statement() OWNER TO lemmy;

--
-- Name: comment_update_statement(); Type: FUNCTION; Schema: r; Owner: lemmy
--

CREATE FUNCTION r.comment_update_statement() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE
        person_aggregates AS a
    SET
        comment_count = a.comment_count + diff.comment_count
    FROM (
        SELECT
            (comment).creator_id, coalesce(sum(count_diff), 0) AS comment_count
        FROM  (
        SELECT
            -1 AS count_diff,
            old_table::comment AS comment
        FROM
            select_old_rows AS old_table
        UNION ALL
        SELECT
            1 AS count_diff,
            new_table::comment AS comment
        FROM
            select_new_rows AS new_table)  AS old_and_new_rows
        WHERE
            r.is_counted (comment)
        GROUP BY (comment).creator_id) AS diff
WHERE
    a.person_id = diff.creator_id
        AND diff.comment_count != 0;

UPDATE
    comment_aggregates AS a
SET
    child_count = a.child_count + diff.child_count
FROM (
    SELECT
        parent_id,
        coalesce(sum(count_diff), 0) AS child_count
    FROM (
        -- For each inserted or deleted comment, this outputs 1 row for each parent comment.
        -- For example, this:
        --
        --  count_diff | (comment).path
        -- ------------+----------------
        --  1          | 0.5.6.7
        --  1          | 0.5.6.7.8
        --
        -- becomes this:
        --
        --  count_diff | parent_id
        -- ------------+-----------
        --  1          | 5
        --  1          | 6
        --  1          | 5
        --  1          | 6
        --  1          | 7
        SELECT
            count_diff,
            parent_id
        FROM
             (
        SELECT
            -1 AS count_diff,
            old_table::comment AS comment
        FROM
            select_old_rows AS old_table
        UNION ALL
        SELECT
            1 AS count_diff,
            new_table::comment AS comment
        FROM
            select_new_rows AS new_table)  AS old_and_new_rows,
            LATERAL r.parent_comment_ids ((comment).path) AS parent_id) AS expanded_old_and_new_rows
    GROUP BY
        parent_id) AS diff
WHERE
    a.comment_id = diff.parent_id
    AND diff.child_count != 0;

WITH post_diff AS (
    UPDATE
        post_aggregates AS a
    SET
        comments = a.comments + diff.comments,
        newest_comment_time = GREATEST (a.newest_comment_time, diff.newest_comment_time),
        newest_comment_time_necro = GREATEST (a.newest_comment_time_necro, diff.newest_comment_time_necro)
    FROM (
        SELECT
            post.id AS post_id,
            coalesce(sum(count_diff), 0) AS comments,
            -- Old rows are excluded using `count_diff = 1`
            max((comment).published) FILTER (WHERE count_diff = 1) AS newest_comment_time,
            max((comment).published) FILTER (WHERE count_diff = 1
                -- Ignore comments from the post's creator
                AND post.creator_id != (comment).creator_id
            -- Ignore comments on old posts
            AND post.published > ((comment).published - '2 days'::interval)) AS newest_comment_time_necro,
        r.is_counted (post.*) AS include_in_community_aggregates
    FROM
         (
        SELECT
            -1 AS count_diff,
            old_table::comment AS comment
        FROM
            select_old_rows AS old_table
        UNION ALL
        SELECT
            1 AS count_diff,
            new_table::comment AS comment
        FROM
            select_new_rows AS new_table)  AS old_and_new_rows
        LEFT JOIN post ON post.id = (comment).post_id
    WHERE
        r.is_counted (comment)
    GROUP BY
        post.id) AS diff
    WHERE
        a.post_id = diff.post_id
        AND (diff.comments,
            GREATEST (a.newest_comment_time, diff.newest_comment_time),
            GREATEST (a.newest_comment_time_necro, diff.newest_comment_time_necro)) != (0,
            a.newest_comment_time,
            a.newest_comment_time_necro)
    RETURNING
        a.community_id,
        diff.comments,
        diff.include_in_community_aggregates)
UPDATE
    community_aggregates AS a
SET
    comments = a.comments + diff.comments
FROM (
    SELECT
        community_id,
        sum(comments) AS comments
    FROM
        post_diff
    WHERE
        post_diff.include_in_community_aggregates
    GROUP BY
        community_id) AS diff
WHERE
    a.community_id = diff.community_id
    AND diff.comments != 0;

UPDATE
    site_aggregates AS a
SET
    comments = a.comments + diff.comments
FROM (
    SELECT
        coalesce(sum(count_diff), 0) AS comments
    FROM
         (
        SELECT
            -1 AS count_diff,
            old_table::comment AS comment
        FROM
            select_old_rows AS old_table
        UNION ALL
        SELECT
            1 AS count_diff,
            new_table::comment AS comment
        FROM
            select_new_rows AS new_table)  AS old_and_new_rows
    WHERE
        r.is_counted (comment)
        AND (comment).local) AS diff
WHERE
    diff.comments != 0;

RETURN NULL;

END;

$$;


ALTER FUNCTION r.comment_update_statement() OWNER TO lemmy;

--
-- Name: community_aggregates_activity(text); Type: FUNCTION; Schema: r; Owner: lemmy
--

CREATE FUNCTION r.community_aggregates_activity(i text) RETURNS TABLE(count_ bigint, community_id_ integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN query
    SELECT
        count(*),
        community_id
    FROM (
        SELECT
            c.creator_id,
            p.community_id
        FROM
            comment c
            INNER JOIN post p ON c.post_id = p.id
            INNER JOIN person pe ON c.creator_id = pe.id
        WHERE
            c.published > ('now'::timestamp - i::interval)
            AND pe.bot_account = FALSE
        UNION
        SELECT
            p.creator_id,
            p.community_id
        FROM
            post p
            INNER JOIN person pe ON p.creator_id = pe.id
        WHERE
            p.published > ('now'::timestamp - i::interval)
            AND pe.bot_account = FALSE
        UNION
        SELECT
            pl.person_id,
            p.community_id
        FROM
            post_like pl
            INNER JOIN post p ON pl.post_id = p.id
            INNER JOIN person pe ON pl.person_id = pe.id
        WHERE
            pl.published > ('now'::timestamp - i::interval)
            AND pe.bot_account = FALSE
        UNION
        SELECT
            cl.person_id,
            p.community_id
        FROM
            comment_like cl
            INNER JOIN comment c ON cl.comment_id = c.id
            INNER JOIN post p ON c.post_id = p.id
            INNER JOIN person pe ON cl.person_id = pe.id
        WHERE
            cl.published > ('now'::timestamp - i::interval)
            AND pe.bot_account = FALSE) a
GROUP BY
    community_id;
END;
$$;


ALTER FUNCTION r.community_aggregates_activity(i text) OWNER TO lemmy;

--
-- Name: community_aggregates_from_community(); Type: FUNCTION; Schema: r; Owner: lemmy
--

CREATE FUNCTION r.community_aggregates_from_community() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO community_aggregates (community_id, published)
    SELECT
        id,
        published
    FROM
        new_community;
    RETURN NULL;
END;
$$;


ALTER FUNCTION r.community_aggregates_from_community() OWNER TO lemmy;

--
-- Name: community_delete_statement(); Type: FUNCTION; Schema: r; Owner: lemmy
--

CREATE FUNCTION r.community_delete_statement() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE
        site_aggregates AS a
    SET
        communities = a.communities + diff.communities
    FROM (
        SELECT
            coalesce(sum(count_diff), 0) AS communities
        FROM  (
        SELECT
            -1 AS count_diff,
            old_table::community AS community
        FROM
            select_old_rows AS old_table
        UNION ALL
        SELECT
            1 AS count_diff,
            new_table::community AS community
        FROM
             (
        SELECT
            *
        FROM
            -- Real transition table
            select_old_rows
        WHERE
            FALSE)  AS new_table)  AS old_and_new_rows
        WHERE
            r.is_counted (community)
            AND (community).local) AS diff
WHERE
    diff.communities != 0;

RETURN NULL;

END;

$$;


ALTER FUNCTION r.community_delete_statement() OWNER TO lemmy;

--
-- Name: community_follower_delete_statement(); Type: FUNCTION; Schema: r; Owner: lemmy
--

CREATE FUNCTION r.community_follower_delete_statement() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE
        community_aggregates AS a
    SET
        subscribers = a.subscribers + diff.subscribers, subscribers_local = a.subscribers_local + diff.subscribers_local
    FROM (
        SELECT
            (community_follower).community_id, coalesce(sum(count_diff) FILTER (WHERE community.local), 0) AS subscribers, coalesce(sum(count_diff) FILTER (WHERE person.local), 0) AS subscribers_local
        FROM  (
        SELECT
            -1 AS count_diff,
            old_table::community_follower AS community_follower
        FROM
            select_old_rows AS old_table
        UNION ALL
        SELECT
            1 AS count_diff,
            new_table::community_follower AS community_follower
        FROM
             (
        SELECT
            *
        FROM
            -- Real transition table
            select_old_rows
        WHERE
            FALSE)  AS new_table)  AS old_and_new_rows
    LEFT JOIN community ON community.id = (community_follower).community_id
    LEFT JOIN person ON person.id = (community_follower).person_id GROUP BY (community_follower).community_id) AS diff
WHERE
    a.community_id = diff.community_id
        AND (diff.subscribers, diff.subscribers_local) != (0, 0);

RETURN NULL;

END;

$$;


ALTER FUNCTION r.community_follower_delete_statement() OWNER TO lemmy;

--
-- Name: community_follower_insert_statement(); Type: FUNCTION; Schema: r; Owner: lemmy
--

CREATE FUNCTION r.community_follower_insert_statement() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE
        community_aggregates AS a
    SET
        subscribers = a.subscribers + diff.subscribers, subscribers_local = a.subscribers_local + diff.subscribers_local
    FROM (
        SELECT
            (community_follower).community_id, coalesce(sum(count_diff) FILTER (WHERE community.local), 0) AS subscribers, coalesce(sum(count_diff) FILTER (WHERE person.local), 0) AS subscribers_local
        FROM  (
        SELECT
            -1 AS count_diff,
            old_table::community_follower AS community_follower
        FROM
             (
        SELECT
            *
        FROM
            -- Real transition table
            select_new_rows
        WHERE
            FALSE)  AS old_table
        UNION ALL
        SELECT
            1 AS count_diff,
            new_table::community_follower AS community_follower
        FROM
            select_new_rows AS new_table)  AS old_and_new_rows
    LEFT JOIN community ON community.id = (community_follower).community_id
    LEFT JOIN person ON person.id = (community_follower).person_id GROUP BY (community_follower).community_id) AS diff
WHERE
    a.community_id = diff.community_id
        AND (diff.subscribers, diff.subscribers_local) != (0, 0);

RETURN NULL;

END;

$$;


ALTER FUNCTION r.community_follower_insert_statement() OWNER TO lemmy;

--
-- Name: community_follower_update_statement(); Type: FUNCTION; Schema: r; Owner: lemmy
--

CREATE FUNCTION r.community_follower_update_statement() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE
        community_aggregates AS a
    SET
        subscribers = a.subscribers + diff.subscribers, subscribers_local = a.subscribers_local + diff.subscribers_local
    FROM (
        SELECT
            (community_follower).community_id, coalesce(sum(count_diff) FILTER (WHERE community.local), 0) AS subscribers, coalesce(sum(count_diff) FILTER (WHERE person.local), 0) AS subscribers_local
        FROM  (
        SELECT
            -1 AS count_diff,
            old_table::community_follower AS community_follower
        FROM
            select_old_rows AS old_table
        UNION ALL
        SELECT
            1 AS count_diff,
            new_table::community_follower AS community_follower
        FROM
            select_new_rows AS new_table)  AS old_and_new_rows
    LEFT JOIN community ON community.id = (community_follower).community_id
    LEFT JOIN person ON person.id = (community_follower).person_id GROUP BY (community_follower).community_id) AS diff
WHERE
    a.community_id = diff.community_id
        AND (diff.subscribers, diff.subscribers_local) != (0, 0);

RETURN NULL;

END;

$$;


ALTER FUNCTION r.community_follower_update_statement() OWNER TO lemmy;

--
-- Name: community_insert_statement(); Type: FUNCTION; Schema: r; Owner: lemmy
--

CREATE FUNCTION r.community_insert_statement() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE
        site_aggregates AS a
    SET
        communities = a.communities + diff.communities
    FROM (
        SELECT
            coalesce(sum(count_diff), 0) AS communities
        FROM  (
        SELECT
            -1 AS count_diff,
            old_table::community AS community
        FROM
             (
        SELECT
            *
        FROM
            -- Real transition table
            select_new_rows
        WHERE
            FALSE)  AS old_table
        UNION ALL
        SELECT
            1 AS count_diff,
            new_table::community AS community
        FROM
            select_new_rows AS new_table)  AS old_and_new_rows
        WHERE
            r.is_counted (community)
            AND (community).local) AS diff
WHERE
    diff.communities != 0;

RETURN NULL;

END;

$$;


ALTER FUNCTION r.community_insert_statement() OWNER TO lemmy;

--
-- Name: community_update_statement(); Type: FUNCTION; Schema: r; Owner: lemmy
--

CREATE FUNCTION r.community_update_statement() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE
        site_aggregates AS a
    SET
        communities = a.communities + diff.communities
    FROM (
        SELECT
            coalesce(sum(count_diff), 0) AS communities
        FROM  (
        SELECT
            -1 AS count_diff,
            old_table::community AS community
        FROM
            select_old_rows AS old_table
        UNION ALL
        SELECT
            1 AS count_diff,
            new_table::community AS community
        FROM
            select_new_rows AS new_table)  AS old_and_new_rows
        WHERE
            r.is_counted (community)
            AND (community).local) AS diff
WHERE
    diff.communities != 0;

RETURN NULL;

END;

$$;


ALTER FUNCTION r.community_update_statement() OWNER TO lemmy;

--
-- Name: controversy_rank(numeric, numeric); Type: FUNCTION; Schema: r; Owner: lemmy
--

CREATE FUNCTION r.controversy_rank(upvotes numeric, downvotes numeric) RETURNS double precision
    LANGUAGE sql IMMUTABLE PARALLEL SAFE
    RETURN CASE WHEN ((downvotes <= (0)::numeric) OR (upvotes <= (0)::numeric)) THEN (0)::double precision ELSE (((upvotes + downvotes))::double precision ^ CASE WHEN (upvotes > downvotes) THEN ((downvotes)::double precision / (upvotes)::double precision) ELSE ((upvotes)::double precision / (downvotes)::double precision) END) END;


ALTER FUNCTION r.controversy_rank(upvotes numeric, downvotes numeric) OWNER TO lemmy;

--
-- Name: create_triggers(text, text); Type: PROCEDURE; Schema: r; Owner: lemmy
--

CREATE PROCEDURE r.create_triggers(IN table_name text, IN function_body text)
    LANGUAGE plpgsql
    AS $_$
DECLARE
    defs text := $$
    -- Delete
    CREATE FUNCTION r.thing_delete_statement ()
        RETURNS TRIGGER
        LANGUAGE plpgsql
        AS function_body_delete;
    CREATE TRIGGER delete_statement
        AFTER DELETE ON thing REFERENCING OLD TABLE AS select_old_rows
        FOR EACH STATEMENT
        EXECUTE FUNCTION r.thing_delete_statement ( );
    -- Insert
    CREATE FUNCTION r.thing_insert_statement ( )
        RETURNS TRIGGER
        LANGUAGE plpgsql
        AS function_body_insert;
    CREATE TRIGGER insert_statement
        AFTER INSERT ON thing REFERENCING NEW TABLE AS select_new_rows
        FOR EACH STATEMENT
        EXECUTE FUNCTION r.thing_insert_statement ( );
    -- Update
    CREATE FUNCTION r.thing_update_statement ( )
        RETURNS TRIGGER
        LANGUAGE plpgsql
        AS function_body_update;
    CREATE TRIGGER update_statement
        AFTER UPDATE ON thing REFERENCING OLD TABLE AS select_old_rows NEW TABLE AS select_new_rows
        FOR EACH STATEMENT
        EXECUTE FUNCTION r.thing_update_statement ( );
    $$;
    select_old_and_new_rows text := $$ (
        SELECT
            -1 AS count_diff,
            old_table::thing AS thing
        FROM
            select_old_rows AS old_table
        UNION ALL
        SELECT
            1 AS count_diff,
            new_table::thing AS thing
        FROM
            select_new_rows AS new_table) $$;
    empty_select_new_rows text := $$ (
        SELECT
            *
        FROM
            -- Real transition table
            select_old_rows
        WHERE
            FALSE) $$;
    empty_select_old_rows text := $$ (
        SELECT
            *
        FROM
            -- Real transition table
            select_new_rows
        WHERE
            FALSE) $$;
    BEGIN
        function_body := replace(function_body, 'select_old_and_new_rows', select_old_and_new_rows);
        -- `select_old_rows` and `select_new_rows` are made available as empty tables if they don't already exist
        defs := replace(defs, 'function_body_delete', quote_literal(replace(function_body, 'select_new_rows', empty_select_new_rows)));
        defs := replace(defs, 'function_body_insert', quote_literal(replace(function_body, 'select_old_rows', empty_select_old_rows)));
        defs := replace(defs, 'function_body_update', quote_literal(function_body));
        defs := replace(defs, 'thing', table_name);
        EXECUTE defs;
END;
$_$;


ALTER PROCEDURE r.create_triggers(IN table_name text, IN function_body text) OWNER TO lemmy;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: comment; Type: TABLE; Schema: public; Owner: lemmy
--

CREATE TABLE public.comment (
    id integer NOT NULL,
    creator_id integer NOT NULL,
    post_id integer NOT NULL,
    content text NOT NULL,
    removed boolean DEFAULT false NOT NULL,
    published timestamp with time zone DEFAULT now() NOT NULL,
    updated timestamp with time zone,
    deleted boolean DEFAULT false NOT NULL,
    ap_id character varying(255) NOT NULL,
    local boolean DEFAULT true NOT NULL,
    path public.ltree DEFAULT '0'::public.ltree NOT NULL,
    distinguished boolean DEFAULT false NOT NULL,
    language_id integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.comment OWNER TO lemmy;

--
-- Name: comment_aggregates; Type: TABLE; Schema: public; Owner: lemmy
--

CREATE TABLE public.comment_aggregates (
    comment_id integer NOT NULL,
    score bigint DEFAULT 0 NOT NULL,
    upvotes bigint DEFAULT 0 NOT NULL,
    downvotes bigint DEFAULT 0 NOT NULL,
    published timestamp with time zone DEFAULT now() NOT NULL,
    child_count integer DEFAULT 0 NOT NULL,
    hot_rank double precision DEFAULT 0.0001 NOT NULL,
    controversy_rank double precision DEFAULT 0 NOT NULL
);


ALTER TABLE public.comment_aggregates OWNER TO lemmy;

--
-- Name: creator_id_from_comment_aggregates(public.comment_aggregates); Type: FUNCTION; Schema: r; Owner: lemmy
--

CREATE FUNCTION r.creator_id_from_comment_aggregates(agg public.comment_aggregates) RETURNS integer
    LANGUAGE sql IMMUTABLE PARALLEL SAFE
    RETURN (SELECT comment.creator_id FROM public.comment WHERE (comment.id = (creator_id_from_comment_aggregates.agg).comment_id) LIMIT 1);


ALTER FUNCTION r.creator_id_from_comment_aggregates(agg public.comment_aggregates) OWNER TO lemmy;

--
-- Name: post_aggregates; Type: TABLE; Schema: public; Owner: lemmy
--

CREATE TABLE public.post_aggregates (
    post_id integer NOT NULL,
    comments bigint DEFAULT 0 NOT NULL,
    score bigint DEFAULT 0 NOT NULL,
    upvotes bigint DEFAULT 0 NOT NULL,
    downvotes bigint DEFAULT 0 NOT NULL,
    published timestamp with time zone DEFAULT now() NOT NULL,
    newest_comment_time_necro timestamp with time zone DEFAULT now() NOT NULL,
    newest_comment_time timestamp with time zone DEFAULT now() NOT NULL,
    featured_community boolean DEFAULT false NOT NULL,
    featured_local boolean DEFAULT false NOT NULL,
    hot_rank double precision DEFAULT 0.0001 NOT NULL,
    hot_rank_active double precision DEFAULT 0.0001 NOT NULL,
    community_id integer NOT NULL,
    creator_id integer NOT NULL,
    controversy_rank double precision DEFAULT 0 NOT NULL,
    instance_id integer NOT NULL,
    scaled_rank double precision DEFAULT 0.0001 NOT NULL
);


ALTER TABLE public.post_aggregates OWNER TO lemmy;

--
-- Name: creator_id_from_post_aggregates(public.post_aggregates); Type: FUNCTION; Schema: r; Owner: lemmy
--

CREATE FUNCTION r.creator_id_from_post_aggregates(agg public.post_aggregates) RETURNS integer
    LANGUAGE sql IMMUTABLE PARALLEL SAFE
    RETURN (agg).creator_id;


ALTER FUNCTION r.creator_id_from_post_aggregates(agg public.post_aggregates) OWNER TO lemmy;

--
-- Name: delete_comments_before_post(); Type: FUNCTION; Schema: r; Owner: lemmy
--

CREATE FUNCTION r.delete_comments_before_post() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    DELETE FROM comment AS c
    WHERE c.post_id = OLD.id;
    RETURN OLD;
END;
$$;


ALTER FUNCTION r.delete_comments_before_post() OWNER TO lemmy;

--
-- Name: delete_follow_before_person(); Type: FUNCTION; Schema: r; Owner: lemmy
--

CREATE FUNCTION r.delete_follow_before_person() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    DELETE FROM community_follower AS c
    WHERE c.person_id = OLD.id;
    RETURN OLD;
END;
$$;


ALTER FUNCTION r.delete_follow_before_person() OWNER TO lemmy;

--
-- Name: hot_rank(numeric, timestamp with time zone); Type: FUNCTION; Schema: r; Owner: lemmy
--

CREATE FUNCTION r.hot_rank(score numeric, published timestamp with time zone) RETURNS double precision
    LANGUAGE sql IMMUTABLE PARALLEL SAFE
    RETURN CASE WHEN (((now() - published) > '00:00:00'::interval) AND ((now() - published) < '7 days'::interval)) THEN (log(GREATEST((2)::numeric, (score + (2)::numeric))) / power(((EXTRACT(epoch FROM (now() - published)) / (3600)::numeric) + (2)::numeric), 1.8)) ELSE 0.0 END;


ALTER FUNCTION r.hot_rank(score numeric, published timestamp with time zone) OWNER TO lemmy;

--
-- Name: is_counted(record); Type: FUNCTION; Schema: r; Owner: lemmy
--

CREATE FUNCTION r.is_counted(item record) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE PARALLEL SAFE
    AS $$
BEGIN
    RETURN COALESCE(NOT (item.deleted
            OR item.removed), FALSE);
END;
$$;


ALTER FUNCTION r.is_counted(item record) OWNER TO lemmy;

--
-- Name: local_url(text); Type: FUNCTION; Schema: r; Owner: lemmy
--

CREATE FUNCTION r.local_url(url_path text) RETURNS text
    LANGUAGE sql STABLE PARALLEL SAFE
    RETURN (current_setting('lemmy.protocol_and_hostname'::text) || url_path);


ALTER FUNCTION r.local_url(url_path text) OWNER TO lemmy;

--
-- Name: parent_comment_ids(public.ltree); Type: FUNCTION; Schema: r; Owner: lemmy
--

CREATE FUNCTION r.parent_comment_ids(path public.ltree) RETURNS SETOF integer
    LANGUAGE sql IMMUTABLE PARALLEL SAFE
    BEGIN ATOMIC
 SELECT (comment_id.comment_id)::integer AS comment_id
    FROM string_to_table(public.ltree2text(parent_comment_ids.path), '.'::text) comment_id(comment_id)
  OFFSET 1
  LIMIT (public.nlevel(parent_comment_ids.path) - 2);
END;


ALTER FUNCTION r.parent_comment_ids(path public.ltree) OWNER TO lemmy;

--
-- Name: person_aggregates_from_person(); Type: FUNCTION; Schema: r; Owner: lemmy
--

CREATE FUNCTION r.person_aggregates_from_person() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO person_aggregates (person_id)
    SELECT
        id
    FROM
        new_person;
    RETURN NULL;
END;
$$;


ALTER FUNCTION r.person_aggregates_from_person() OWNER TO lemmy;

--
-- Name: person_delete_statement(); Type: FUNCTION; Schema: r; Owner: lemmy
--

CREATE FUNCTION r.person_delete_statement() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE
        site_aggregates AS a
    SET
        users = a.users + diff.users
    FROM (
        SELECT
            coalesce(sum(count_diff), 0) AS users
        FROM  (
        SELECT
            -1 AS count_diff,
            old_table::person AS person
        FROM
            select_old_rows AS old_table
        UNION ALL
        SELECT
            1 AS count_diff,
            new_table::person AS person
        FROM
             (
        SELECT
            *
        FROM
            -- Real transition table
            select_old_rows
        WHERE
            FALSE)  AS new_table)  AS old_and_new_rows
        WHERE (person).local) AS diff
WHERE
    diff.users != 0;

RETURN NULL;

END;

$$;


ALTER FUNCTION r.person_delete_statement() OWNER TO lemmy;

--
-- Name: person_insert_statement(); Type: FUNCTION; Schema: r; Owner: lemmy
--

CREATE FUNCTION r.person_insert_statement() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE
        site_aggregates AS a
    SET
        users = a.users + diff.users
    FROM (
        SELECT
            coalesce(sum(count_diff), 0) AS users
        FROM  (
        SELECT
            -1 AS count_diff,
            old_table::person AS person
        FROM
             (
        SELECT
            *
        FROM
            -- Real transition table
            select_new_rows
        WHERE
            FALSE)  AS old_table
        UNION ALL
        SELECT
            1 AS count_diff,
            new_table::person AS person
        FROM
            select_new_rows AS new_table)  AS old_and_new_rows
        WHERE (person).local) AS diff
WHERE
    diff.users != 0;

RETURN NULL;

END;

$$;


ALTER FUNCTION r.person_insert_statement() OWNER TO lemmy;

--
-- Name: person_update_statement(); Type: FUNCTION; Schema: r; Owner: lemmy
--

CREATE FUNCTION r.person_update_statement() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE
        site_aggregates AS a
    SET
        users = a.users + diff.users
    FROM (
        SELECT
            coalesce(sum(count_diff), 0) AS users
        FROM  (
        SELECT
            -1 AS count_diff,
            old_table::person AS person
        FROM
            select_old_rows AS old_table
        UNION ALL
        SELECT
            1 AS count_diff,
            new_table::person AS person
        FROM
            select_new_rows AS new_table)  AS old_and_new_rows
        WHERE (person).local) AS diff
WHERE
    diff.users != 0;

RETURN NULL;

END;

$$;


ALTER FUNCTION r.person_update_statement() OWNER TO lemmy;

--
-- Name: post_aggregates_from_post(); Type: FUNCTION; Schema: r; Owner: lemmy
--

CREATE FUNCTION r.post_aggregates_from_post() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO post_aggregates (post_id, published, newest_comment_time, newest_comment_time_necro, community_id, creator_id, instance_id, featured_community, featured_local)
    SELECT
        new_post.id,
        new_post.published,
        new_post.published,
        new_post.published,
        new_post.community_id,
        new_post.creator_id,
        community.instance_id,
        new_post.featured_community,
        new_post.featured_local
    FROM
        new_post
        INNER JOIN community ON community.id = new_post.community_id;
    RETURN NULL;
END;
$$;


ALTER FUNCTION r.post_aggregates_from_post() OWNER TO lemmy;

--
-- Name: post_aggregates_from_post_update(); Type: FUNCTION; Schema: r; Owner: lemmy
--

CREATE FUNCTION r.post_aggregates_from_post_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE
        post_aggregates
    SET
        featured_community = new_post.featured_community,
        featured_local = new_post.featured_local
    FROM
        new_post
        INNER JOIN old_post ON old_post.id = new_post.id
            AND (old_post.featured_community,
                old_post.featured_local) != (new_post.featured_community,
                new_post.featured_local)
    WHERE
        post_aggregates.post_id = new_post.id;
    RETURN NULL;
END;
$$;


ALTER FUNCTION r.post_aggregates_from_post_update() OWNER TO lemmy;

--
-- Name: post_change_values(); Type: FUNCTION; Schema: r; Owner: lemmy
--

CREATE FUNCTION r.post_change_values() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Set local ap_id
    IF NEW.local THEN
        NEW.ap_id = coalesce(NEW.ap_id, r.local_url ('/post/' || NEW.id::text));
    END IF;
    RETURN NEW;
END
$$;


ALTER FUNCTION r.post_change_values() OWNER TO lemmy;

--
-- Name: post_delete_statement(); Type: FUNCTION; Schema: r; Owner: lemmy
--

CREATE FUNCTION r.post_delete_statement() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE
        person_aggregates AS a
    SET
        post_count = a.post_count + diff.post_count
    FROM (
        SELECT
            (post).creator_id, coalesce(sum(count_diff), 0) AS post_count
        FROM  (
        SELECT
            -1 AS count_diff,
            old_table::post AS post
        FROM
            select_old_rows AS old_table
        UNION ALL
        SELECT
            1 AS count_diff,
            new_table::post AS post
        FROM
             (
        SELECT
            *
        FROM
            -- Real transition table
            select_old_rows
        WHERE
            FALSE)  AS new_table)  AS old_and_new_rows
        WHERE
            r.is_counted (post)
        GROUP BY (post).creator_id) AS diff
WHERE
    a.person_id = diff.creator_id
        AND diff.post_count != 0;

UPDATE
    community_aggregates AS a
SET
    posts = a.posts + diff.posts
FROM (
    SELECT
        (post).community_id,
        coalesce(sum(count_diff), 0) AS posts
    FROM
         (
        SELECT
            -1 AS count_diff,
            old_table::post AS post
        FROM
            select_old_rows AS old_table
        UNION ALL
        SELECT
            1 AS count_diff,
            new_table::post AS post
        FROM
             (
        SELECT
            *
        FROM
            -- Real transition table
            select_old_rows
        WHERE
            FALSE)  AS new_table)  AS old_and_new_rows
    WHERE
        r.is_counted (post)
    GROUP BY
        (post).community_id) AS diff
WHERE
    a.community_id = diff.community_id
    AND diff.posts != 0;

UPDATE
    site_aggregates AS a
SET
    posts = a.posts + diff.posts
FROM (
    SELECT
        coalesce(sum(count_diff), 0) AS posts
    FROM
         (
        SELECT
            -1 AS count_diff,
            old_table::post AS post
        FROM
            select_old_rows AS old_table
        UNION ALL
        SELECT
            1 AS count_diff,
            new_table::post AS post
        FROM
             (
        SELECT
            *
        FROM
            -- Real transition table
            select_old_rows
        WHERE
            FALSE)  AS new_table)  AS old_and_new_rows
    WHERE
        r.is_counted (post)
        AND (post).local) AS diff
WHERE
    diff.posts != 0;

RETURN NULL;

END;

$$;


ALTER FUNCTION r.post_delete_statement() OWNER TO lemmy;

--
-- Name: post_insert_statement(); Type: FUNCTION; Schema: r; Owner: lemmy
--

CREATE FUNCTION r.post_insert_statement() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE
        person_aggregates AS a
    SET
        post_count = a.post_count + diff.post_count
    FROM (
        SELECT
            (post).creator_id, coalesce(sum(count_diff), 0) AS post_count
        FROM  (
        SELECT
            -1 AS count_diff,
            old_table::post AS post
        FROM
             (
        SELECT
            *
        FROM
            -- Real transition table
            select_new_rows
        WHERE
            FALSE)  AS old_table
        UNION ALL
        SELECT
            1 AS count_diff,
            new_table::post AS post
        FROM
            select_new_rows AS new_table)  AS old_and_new_rows
        WHERE
            r.is_counted (post)
        GROUP BY (post).creator_id) AS diff
WHERE
    a.person_id = diff.creator_id
        AND diff.post_count != 0;

UPDATE
    community_aggregates AS a
SET
    posts = a.posts + diff.posts
FROM (
    SELECT
        (post).community_id,
        coalesce(sum(count_diff), 0) AS posts
    FROM
         (
        SELECT
            -1 AS count_diff,
            old_table::post AS post
        FROM
             (
        SELECT
            *
        FROM
            -- Real transition table
            select_new_rows
        WHERE
            FALSE)  AS old_table
        UNION ALL
        SELECT
            1 AS count_diff,
            new_table::post AS post
        FROM
            select_new_rows AS new_table)  AS old_and_new_rows
    WHERE
        r.is_counted (post)
    GROUP BY
        (post).community_id) AS diff
WHERE
    a.community_id = diff.community_id
    AND diff.posts != 0;

UPDATE
    site_aggregates AS a
SET
    posts = a.posts + diff.posts
FROM (
    SELECT
        coalesce(sum(count_diff), 0) AS posts
    FROM
         (
        SELECT
            -1 AS count_diff,
            old_table::post AS post
        FROM
             (
        SELECT
            *
        FROM
            -- Real transition table
            select_new_rows
        WHERE
            FALSE)  AS old_table
        UNION ALL
        SELECT
            1 AS count_diff,
            new_table::post AS post
        FROM
            select_new_rows AS new_table)  AS old_and_new_rows
    WHERE
        r.is_counted (post)
        AND (post).local) AS diff
WHERE
    diff.posts != 0;

RETURN NULL;

END;

$$;


ALTER FUNCTION r.post_insert_statement() OWNER TO lemmy;

--
-- Name: post_like_delete_statement(); Type: FUNCTION; Schema: r; Owner: lemmy
--

CREATE FUNCTION r.post_like_delete_statement() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
            BEGIN
                WITH post_diff AS ( UPDATE
                        post_aggregates AS a
                    SET
                        score = a.score + diff.upvotes - diff.downvotes, upvotes = a.upvotes + diff.upvotes, downvotes = a.downvotes + diff.downvotes, controversy_rank = r.controversy_rank ((a.upvotes + diff.upvotes)::numeric, (a.downvotes + diff.downvotes)::numeric)
                    FROM (
                        SELECT
                            (post_like).post_id, coalesce(sum(count_diff) FILTER (WHERE (post_like).score = 1), 0) AS upvotes, coalesce(sum(count_diff) FILTER (WHERE (post_like).score != 1), 0) AS downvotes FROM  (
        SELECT
            -1 AS count_diff,
            old_table::post_like AS post_like
        FROM
            select_old_rows AS old_table
        UNION ALL
        SELECT
            1 AS count_diff,
            new_table::post_like AS post_like
        FROM
             (
        SELECT
            *
        FROM
            -- Real transition table
            select_old_rows
        WHERE
            FALSE)  AS new_table)  AS old_and_new_rows GROUP BY (post_like).post_id) AS diff
            WHERE
                a.post_id = diff.post_id
                    AND (diff.upvotes, diff.downvotes) != (0, 0)
                RETURNING
                    r.creator_id_from_post_aggregates (a.*) AS creator_id, diff.upvotes - diff.downvotes AS score)
            UPDATE
                person_aggregates AS a
            SET
                post_score = a.post_score + diff.score FROM (
                    SELECT
                        creator_id, sum(score) AS score FROM post_diff GROUP BY creator_id) AS diff
                WHERE
                    a.person_id = diff.creator_id
                    AND diff.score != 0;
                RETURN NULL;
            END;
    $$;


ALTER FUNCTION r.post_like_delete_statement() OWNER TO lemmy;

--
-- Name: post_like_insert_statement(); Type: FUNCTION; Schema: r; Owner: lemmy
--

CREATE FUNCTION r.post_like_insert_statement() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
            BEGIN
                WITH post_diff AS ( UPDATE
                        post_aggregates AS a
                    SET
                        score = a.score + diff.upvotes - diff.downvotes, upvotes = a.upvotes + diff.upvotes, downvotes = a.downvotes + diff.downvotes, controversy_rank = r.controversy_rank ((a.upvotes + diff.upvotes)::numeric, (a.downvotes + diff.downvotes)::numeric)
                    FROM (
                        SELECT
                            (post_like).post_id, coalesce(sum(count_diff) FILTER (WHERE (post_like).score = 1), 0) AS upvotes, coalesce(sum(count_diff) FILTER (WHERE (post_like).score != 1), 0) AS downvotes FROM  (
        SELECT
            -1 AS count_diff,
            old_table::post_like AS post_like
        FROM
             (
        SELECT
            *
        FROM
            -- Real transition table
            select_new_rows
        WHERE
            FALSE)  AS old_table
        UNION ALL
        SELECT
            1 AS count_diff,
            new_table::post_like AS post_like
        FROM
            select_new_rows AS new_table)  AS old_and_new_rows GROUP BY (post_like).post_id) AS diff
            WHERE
                a.post_id = diff.post_id
                    AND (diff.upvotes, diff.downvotes) != (0, 0)
                RETURNING
                    r.creator_id_from_post_aggregates (a.*) AS creator_id, diff.upvotes - diff.downvotes AS score)
            UPDATE
                person_aggregates AS a
            SET
                post_score = a.post_score + diff.score FROM (
                    SELECT
                        creator_id, sum(score) AS score FROM post_diff GROUP BY creator_id) AS diff
                WHERE
                    a.person_id = diff.creator_id
                    AND diff.score != 0;
                RETURN NULL;
            END;
    $$;


ALTER FUNCTION r.post_like_insert_statement() OWNER TO lemmy;

--
-- Name: post_like_update_statement(); Type: FUNCTION; Schema: r; Owner: lemmy
--

CREATE FUNCTION r.post_like_update_statement() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
            BEGIN
                WITH post_diff AS ( UPDATE
                        post_aggregates AS a
                    SET
                        score = a.score + diff.upvotes - diff.downvotes, upvotes = a.upvotes + diff.upvotes, downvotes = a.downvotes + diff.downvotes, controversy_rank = r.controversy_rank ((a.upvotes + diff.upvotes)::numeric, (a.downvotes + diff.downvotes)::numeric)
                    FROM (
                        SELECT
                            (post_like).post_id, coalesce(sum(count_diff) FILTER (WHERE (post_like).score = 1), 0) AS upvotes, coalesce(sum(count_diff) FILTER (WHERE (post_like).score != 1), 0) AS downvotes FROM  (
        SELECT
            -1 AS count_diff,
            old_table::post_like AS post_like
        FROM
            select_old_rows AS old_table
        UNION ALL
        SELECT
            1 AS count_diff,
            new_table::post_like AS post_like
        FROM
            select_new_rows AS new_table)  AS old_and_new_rows GROUP BY (post_like).post_id) AS diff
            WHERE
                a.post_id = diff.post_id
                    AND (diff.upvotes, diff.downvotes) != (0, 0)
                RETURNING
                    r.creator_id_from_post_aggregates (a.*) AS creator_id, diff.upvotes - diff.downvotes AS score)
            UPDATE
                person_aggregates AS a
            SET
                post_score = a.post_score + diff.score FROM (
                    SELECT
                        creator_id, sum(score) AS score FROM post_diff GROUP BY creator_id) AS diff
                WHERE
                    a.person_id = diff.creator_id
                    AND diff.score != 0;
                RETURN NULL;
            END;
    $$;


ALTER FUNCTION r.post_like_update_statement() OWNER TO lemmy;

--
-- Name: post_or_comment(text); Type: PROCEDURE; Schema: r; Owner: lemmy
--

CREATE PROCEDURE r.post_or_comment(IN table_name text)
    LANGUAGE plpgsql
    AS $_$
BEGIN
    EXECUTE replace($b$
        -- When a thing gets a vote, update its aggregates and its creator's aggregates
        CALL r.create_triggers ('thing_like', $$
            BEGIN
                WITH thing_diff AS ( UPDATE
                        thing_aggregates AS a
                    SET
                        score = a.score + diff.upvotes - diff.downvotes, upvotes = a.upvotes + diff.upvotes, downvotes = a.downvotes + diff.downvotes, controversy_rank = r.controversy_rank ((a.upvotes + diff.upvotes)::numeric, (a.downvotes + diff.downvotes)::numeric)
                    FROM (
                        SELECT
                            (thing_like).thing_id, coalesce(sum(count_diff) FILTER (WHERE (thing_like).score = 1), 0) AS upvotes, coalesce(sum(count_diff) FILTER (WHERE (thing_like).score != 1), 0) AS downvotes FROM select_old_and_new_rows AS old_and_new_rows GROUP BY (thing_like).thing_id) AS diff
            WHERE
                a.thing_id = diff.thing_id
                    AND (diff.upvotes, diff.downvotes) != (0, 0)
                RETURNING
                    r.creator_id_from_thing_aggregates (a.*) AS creator_id, diff.upvotes - diff.downvotes AS score)
            UPDATE
                person_aggregates AS a
            SET
                thing_score = a.thing_score + diff.score FROM (
                    SELECT
                        creator_id, sum(score) AS score FROM thing_diff GROUP BY creator_id) AS diff
                WHERE
                    a.person_id = diff.creator_id
                    AND diff.score != 0;
                RETURN NULL;
            END;
    $$);
    $b$,
    'thing',
    table_name);
END;
$_$;


ALTER PROCEDURE r.post_or_comment(IN table_name text) OWNER TO lemmy;

--
-- Name: post_update_statement(); Type: FUNCTION; Schema: r; Owner: lemmy
--

CREATE FUNCTION r.post_update_statement() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE
        person_aggregates AS a
    SET
        post_count = a.post_count + diff.post_count
    FROM (
        SELECT
            (post).creator_id, coalesce(sum(count_diff), 0) AS post_count
        FROM  (
        SELECT
            -1 AS count_diff,
            old_table::post AS post
        FROM
            select_old_rows AS old_table
        UNION ALL
        SELECT
            1 AS count_diff,
            new_table::post AS post
        FROM
            select_new_rows AS new_table)  AS old_and_new_rows
        WHERE
            r.is_counted (post)
        GROUP BY (post).creator_id) AS diff
WHERE
    a.person_id = diff.creator_id
        AND diff.post_count != 0;

UPDATE
    community_aggregates AS a
SET
    posts = a.posts + diff.posts
FROM (
    SELECT
        (post).community_id,
        coalesce(sum(count_diff), 0) AS posts
    FROM
         (
        SELECT
            -1 AS count_diff,
            old_table::post AS post
        FROM
            select_old_rows AS old_table
        UNION ALL
        SELECT
            1 AS count_diff,
            new_table::post AS post
        FROM
            select_new_rows AS new_table)  AS old_and_new_rows
    WHERE
        r.is_counted (post)
    GROUP BY
        (post).community_id) AS diff
WHERE
    a.community_id = diff.community_id
    AND diff.posts != 0;

UPDATE
    site_aggregates AS a
SET
    posts = a.posts + diff.posts
FROM (
    SELECT
        coalesce(sum(count_diff), 0) AS posts
    FROM
         (
        SELECT
            -1 AS count_diff,
            old_table::post AS post
        FROM
            select_old_rows AS old_table
        UNION ALL
        SELECT
            1 AS count_diff,
            new_table::post AS post
        FROM
            select_new_rows AS new_table)  AS old_and_new_rows
    WHERE
        r.is_counted (post)
        AND (post).local) AS diff
WHERE
    diff.posts != 0;

RETURN NULL;

END;

$$;


ALTER FUNCTION r.post_update_statement() OWNER TO lemmy;

--
-- Name: private_message_change_values(); Type: FUNCTION; Schema: r; Owner: lemmy
--

CREATE FUNCTION r.private_message_change_values() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Set local ap_id
    IF NEW.local THEN
        NEW.ap_id = coalesce(NEW.ap_id, r.local_url ('/private_message/' || NEW.id::text));
    END IF;
    RETURN NEW;
END
$$;


ALTER FUNCTION r.private_message_change_values() OWNER TO lemmy;

--
-- Name: scaled_rank(numeric, timestamp with time zone, numeric); Type: FUNCTION; Schema: r; Owner: lemmy
--

CREATE FUNCTION r.scaled_rank(score numeric, published timestamp with time zone, users_active_month numeric) RETURNS double precision
    LANGUAGE sql IMMUTABLE PARALLEL SAFE
    RETURN (r.hot_rank(score, published) / (log(((2)::numeric + users_active_month)))::double precision);


ALTER FUNCTION r.scaled_rank(score numeric, published timestamp with time zone, users_active_month numeric) OWNER TO lemmy;

--
-- Name: site_aggregates_activity(text); Type: FUNCTION; Schema: r; Owner: lemmy
--

CREATE FUNCTION r.site_aggregates_activity(i text) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    count_ integer;
BEGIN
    SELECT
        count(*) INTO count_
    FROM (
        SELECT
            c.creator_id
        FROM
            comment c
            INNER JOIN person pe ON c.creator_id = pe.id
        WHERE
            c.published > ('now'::timestamp - i::interval)
            AND pe.local = TRUE
            AND pe.bot_account = FALSE
        UNION
        SELECT
            p.creator_id
        FROM
            post p
            INNER JOIN person pe ON p.creator_id = pe.id
        WHERE
            p.published > ('now'::timestamp - i::interval)
            AND pe.local = TRUE
            AND pe.bot_account = FALSE
        UNION
        SELECT
            pl.person_id
        FROM
            post_like pl
            INNER JOIN person pe ON pl.person_id = pe.id
        WHERE
            pl.published > ('now'::timestamp - i::interval)
            AND pe.local = TRUE
            AND pe.bot_account = FALSE
        UNION
        SELECT
            cl.person_id
        FROM
            comment_like cl
            INNER JOIN person pe ON cl.person_id = pe.id
        WHERE
            cl.published > ('now'::timestamp - i::interval)
            AND pe.local = TRUE
            AND pe.bot_account = FALSE) a;
    RETURN count_;
END;
$$;


ALTER FUNCTION r.site_aggregates_activity(i text) OWNER TO lemmy;

--
-- Name: site_aggregates_from_site(); Type: FUNCTION; Schema: r; Owner: lemmy
--

CREATE FUNCTION r.site_aggregates_from_site() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- only 1 row can be in site_aggregates because of the index idx_site_aggregates_1_row_only.
    -- we only ever want to have a single value in site_aggregate because the site_aggregate triggers update all rows in that table.
    -- a cleaner check would be to insert it for the local_site but that would break assumptions at least in the tests
    INSERT INTO site_aggregates (site_id)
        VALUES (NEW.id)
    ON CONFLICT ((TRUE))
        DO NOTHING;
    RETURN NULL;
END;
$$;


ALTER FUNCTION r.site_aggregates_from_site() OWNER TO lemmy;

--
-- Name: update_comment_count_from_post(); Type: FUNCTION; Schema: r; Owner: lemmy
--

CREATE FUNCTION r.update_comment_count_from_post() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE
        community_aggregates AS a
    SET
        comments = a.comments + diff.comments
    FROM (
        SELECT
            old_post.community_id,
            sum((
                CASE WHEN r.is_counted (new_post.*) THEN
                    1
                ELSE
                    -1
                END) * post_aggregates.comments) AS comments
        FROM
            new_post
            INNER JOIN old_post ON new_post.id = old_post.id
                AND (r.is_counted (new_post.*) != r.is_counted (old_post.*))
                INNER JOIN post_aggregates ON post_aggregates.post_id = new_post.id
            GROUP BY
                old_post.community_id) AS diff
WHERE
    a.community_id = diff.community_id
        AND diff.comments != 0;
    RETURN NULL;
END;
$$;


ALTER FUNCTION r.update_comment_count_from_post() OWNER TO lemmy;

--
-- Name: restore_views(character varying, character varying); Type: FUNCTION; Schema: utils; Owner: lemmy
--

CREATE FUNCTION utils.restore_views(p_view_schema character varying, p_view_name character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_curr record;
BEGIN
    FOR v_curr IN (
        SELECT
            ddl_to_run,
            id
        FROM
            utils.deps_saved_ddl
        WHERE
            view_schema = p_view_schema
            AND view_name = p_view_name
        ORDER BY
            id DESC)
            LOOP
                BEGIN
                    EXECUTE v_curr.ddl_to_run;
                    DELETE FROM utils.deps_saved_ddl
                    WHERE id = v_curr.id;
                EXCEPTION
                    WHEN OTHERS THEN
                        -- keep looping, but please check for errors or remove left overs to handle manually
                END;
    END LOOP;
END;

$$;


ALTER FUNCTION utils.restore_views(p_view_schema character varying, p_view_name character varying) OWNER TO lemmy;

--
-- Name: save_and_drop_views(name, name); Type: FUNCTION; Schema: utils; Owner: lemmy
--

CREATE FUNCTION utils.save_and_drop_views(p_view_schema name, p_view_name name) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_curr record;
BEGIN
    FOR v_curr IN (
        SELECT
            obj_schema,
            obj_name,
            obj_type
        FROM ( WITH RECURSIVE recursive_deps (
                obj_schema,
                obj_name,
                obj_type,
                depth
) AS (
                SELECT
                    p_view_schema::name,
                    p_view_name,
                    NULL::varchar,
                    0
                UNION
                SELECT
                    dep_schema::varchar,
                    dep_name::varchar,
                    dep_type::varchar,
                    recursive_deps.depth + 1
                FROM (
                    SELECT
                        ref_nsp.nspname ref_schema,
                        ref_cl.relname ref_name,
                        rwr_cl.relkind dep_type,
                        rwr_nsp.nspname dep_schema,
                        rwr_cl.relname dep_name
                    FROM
                        pg_depend dep
                        JOIN pg_class ref_cl ON dep.refobjid = ref_cl.oid
                        JOIN pg_namespace ref_nsp ON ref_cl.relnamespace = ref_nsp.oid
                        JOIN pg_rewrite rwr ON dep.objid = rwr.oid
                        JOIN pg_class rwr_cl ON rwr.ev_class = rwr_cl.oid
                        JOIN pg_namespace rwr_nsp ON rwr_cl.relnamespace = rwr_nsp.oid
                    WHERE
                        dep.deptype = 'n'
                        AND dep.classid = 'pg_rewrite'::regclass) deps
                    JOIN recursive_deps ON deps.ref_schema = recursive_deps.obj_schema
                        AND deps.ref_name = recursive_deps.obj_name
                WHERE (deps.ref_schema != deps.dep_schema
                    OR deps.ref_name != deps.dep_name))
            SELECT
                obj_schema,
                obj_name,
                obj_type,
                depth
            FROM
                recursive_deps
            WHERE
                depth > 0) t
        GROUP BY
            obj_schema,
            obj_name,
            obj_type
        ORDER BY
            max(depth) DESC)
            LOOP
                IF v_curr.obj_type = 'v' THEN
                    INSERT INTO utils.deps_saved_ddl (view_schema, view_name, ddl_to_run)
                    SELECT
                        p_view_schema,
                        p_view_name,
                        'CREATE VIEW ' || v_curr.obj_schema || '.' || v_curr.obj_name || ' AS ' || view_definition
                    FROM
                        information_schema.views
                    WHERE
                        table_schema = v_curr.obj_schema
                        AND table_name = v_curr.obj_name;
                    EXECUTE 'DROP VIEW' || ' ' || v_curr.obj_schema || '.' || v_curr.obj_name;
                END IF;
            END LOOP;
END;
$$;


ALTER FUNCTION utils.save_and_drop_views(p_view_schema name, p_view_name name) OWNER TO lemmy;

--
-- Name: __diesel_schema_migrations; Type: TABLE; Schema: public; Owner: lemmy
--

CREATE TABLE public.__diesel_schema_migrations (
    version character varying(50) NOT NULL,
    run_on timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.__diesel_schema_migrations OWNER TO lemmy;

--
-- Name: admin_purge_comment; Type: TABLE; Schema: public; Owner: lemmy
--

CREATE TABLE public.admin_purge_comment (
    id integer NOT NULL,
    admin_person_id integer NOT NULL,
    post_id integer NOT NULL,
    reason text,
    when_ timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.admin_purge_comment OWNER TO lemmy;

--
-- Name: admin_purge_comment_id_seq; Type: SEQUENCE; Schema: public; Owner: lemmy
--

CREATE SEQUENCE public.admin_purge_comment_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.admin_purge_comment_id_seq OWNER TO lemmy;

--
-- Name: admin_purge_comment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: lemmy
--

ALTER SEQUENCE public.admin_purge_comment_id_seq OWNED BY public.admin_purge_comment.id;


--
-- Name: admin_purge_community; Type: TABLE; Schema: public; Owner: lemmy
--

CREATE TABLE public.admin_purge_community (
    id integer NOT NULL,
    admin_person_id integer NOT NULL,
    reason text,
    when_ timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.admin_purge_community OWNER TO lemmy;

--
-- Name: admin_purge_community_id_seq; Type: SEQUENCE; Schema: public; Owner: lemmy
--

CREATE SEQUENCE public.admin_purge_community_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.admin_purge_community_id_seq OWNER TO lemmy;

--
-- Name: admin_purge_community_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: lemmy
--

ALTER SEQUENCE public.admin_purge_community_id_seq OWNED BY public.admin_purge_community.id;


--
-- Name: admin_purge_person; Type: TABLE; Schema: public; Owner: lemmy
--

CREATE TABLE public.admin_purge_person (
    id integer NOT NULL,
    admin_person_id integer NOT NULL,
    reason text,
    when_ timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.admin_purge_person OWNER TO lemmy;

--
-- Name: admin_purge_person_id_seq; Type: SEQUENCE; Schema: public; Owner: lemmy
--

CREATE SEQUENCE public.admin_purge_person_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.admin_purge_person_id_seq OWNER TO lemmy;

--
-- Name: admin_purge_person_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: lemmy
--

ALTER SEQUENCE public.admin_purge_person_id_seq OWNED BY public.admin_purge_person.id;


--
-- Name: admin_purge_post; Type: TABLE; Schema: public; Owner: lemmy
--

CREATE TABLE public.admin_purge_post (
    id integer NOT NULL,
    admin_person_id integer NOT NULL,
    community_id integer NOT NULL,
    reason text,
    when_ timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.admin_purge_post OWNER TO lemmy;

--
-- Name: admin_purge_post_id_seq; Type: SEQUENCE; Schema: public; Owner: lemmy
--

CREATE SEQUENCE public.admin_purge_post_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.admin_purge_post_id_seq OWNER TO lemmy;

--
-- Name: admin_purge_post_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: lemmy
--

ALTER SEQUENCE public.admin_purge_post_id_seq OWNED BY public.admin_purge_post.id;


--
-- Name: captcha_answer; Type: TABLE; Schema: public; Owner: lemmy
--

CREATE TABLE public.captcha_answer (
    uuid uuid DEFAULT gen_random_uuid() NOT NULL,
    answer text NOT NULL,
    published timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.captcha_answer OWNER TO lemmy;

--
-- Name: changeme_seq; Type: SEQUENCE; Schema: public; Owner: lemmy
--

CREATE SEQUENCE public.changeme_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
    CYCLE;


ALTER SEQUENCE public.changeme_seq OWNER TO lemmy;

--
-- Name: comment_id_seq; Type: SEQUENCE; Schema: public; Owner: lemmy
--

CREATE SEQUENCE public.comment_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.comment_id_seq OWNER TO lemmy;

--
-- Name: comment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: lemmy
--

ALTER SEQUENCE public.comment_id_seq OWNED BY public.comment.id;


--
-- Name: comment_like; Type: TABLE; Schema: public; Owner: lemmy
--

CREATE TABLE public.comment_like (
    person_id integer NOT NULL,
    comment_id integer NOT NULL,
    post_id integer NOT NULL,
    score smallint NOT NULL,
    published timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.comment_like OWNER TO lemmy;

--
-- Name: comment_reply; Type: TABLE; Schema: public; Owner: lemmy
--

CREATE TABLE public.comment_reply (
    id integer NOT NULL,
    recipient_id integer NOT NULL,
    comment_id integer NOT NULL,
    read boolean DEFAULT false NOT NULL,
    published timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.comment_reply OWNER TO lemmy;

--
-- Name: comment_reply_id_seq; Type: SEQUENCE; Schema: public; Owner: lemmy
--

CREATE SEQUENCE public.comment_reply_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.comment_reply_id_seq OWNER TO lemmy;

--
-- Name: comment_reply_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: lemmy
--

ALTER SEQUENCE public.comment_reply_id_seq OWNED BY public.comment_reply.id;


--
-- Name: comment_report; Type: TABLE; Schema: public; Owner: lemmy
--

CREATE TABLE public.comment_report (
    id integer NOT NULL,
    creator_id integer NOT NULL,
    comment_id integer NOT NULL,
    original_comment_text text NOT NULL,
    reason text NOT NULL,
    resolved boolean DEFAULT false NOT NULL,
    resolver_id integer,
    published timestamp with time zone DEFAULT now() NOT NULL,
    updated timestamp with time zone
);


ALTER TABLE public.comment_report OWNER TO lemmy;

--
-- Name: comment_report_id_seq; Type: SEQUENCE; Schema: public; Owner: lemmy
--

CREATE SEQUENCE public.comment_report_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.comment_report_id_seq OWNER TO lemmy;

--
-- Name: comment_report_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: lemmy
--

ALTER SEQUENCE public.comment_report_id_seq OWNED BY public.comment_report.id;


--
-- Name: comment_saved; Type: TABLE; Schema: public; Owner: lemmy
--

CREATE TABLE public.comment_saved (
    comment_id integer NOT NULL,
    person_id integer NOT NULL,
    published timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.comment_saved OWNER TO lemmy;

--
-- Name: community; Type: TABLE; Schema: public; Owner: lemmy
--

CREATE TABLE public.community (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    title character varying(255) NOT NULL,
    description text,
    removed boolean DEFAULT false NOT NULL,
    published timestamp with time zone DEFAULT now() NOT NULL,
    updated timestamp with time zone,
    deleted boolean DEFAULT false NOT NULL,
    nsfw boolean DEFAULT false NOT NULL,
    actor_id character varying(255) DEFAULT public.generate_unique_changeme() NOT NULL,
    local boolean DEFAULT true NOT NULL,
    private_key text,
    public_key text NOT NULL,
    last_refreshed_at timestamp with time zone DEFAULT now() NOT NULL,
    icon text,
    banner text,
    followers_url character varying(255) DEFAULT public.generate_unique_changeme(),
    inbox_url character varying(255) DEFAULT public.generate_unique_changeme() NOT NULL,
    shared_inbox_url character varying(255),
    hidden boolean DEFAULT false NOT NULL,
    posting_restricted_to_mods boolean DEFAULT false NOT NULL,
    instance_id integer NOT NULL,
    moderators_url character varying(255),
    featured_url character varying(255),
    visibility public.community_visibility DEFAULT 'Public'::public.community_visibility NOT NULL
);


ALTER TABLE public.community OWNER TO lemmy;

--
-- Name: community_aggregates; Type: TABLE; Schema: public; Owner: lemmy
--

CREATE TABLE public.community_aggregates (
    community_id integer NOT NULL,
    subscribers bigint DEFAULT 0 NOT NULL,
    posts bigint DEFAULT 0 NOT NULL,
    comments bigint DEFAULT 0 NOT NULL,
    published timestamp with time zone DEFAULT now() NOT NULL,
    users_active_day bigint DEFAULT 0 NOT NULL,
    users_active_week bigint DEFAULT 0 NOT NULL,
    users_active_month bigint DEFAULT 0 NOT NULL,
    users_active_half_year bigint DEFAULT 0 NOT NULL,
    hot_rank double precision DEFAULT 0.0001 NOT NULL,
    subscribers_local bigint DEFAULT 0 NOT NULL
);


ALTER TABLE public.community_aggregates OWNER TO lemmy;

--
-- Name: community_block; Type: TABLE; Schema: public; Owner: lemmy
--

CREATE TABLE public.community_block (
    person_id integer NOT NULL,
    community_id integer NOT NULL,
    published timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.community_block OWNER TO lemmy;

--
-- Name: community_follower; Type: TABLE; Schema: public; Owner: lemmy
--

CREATE TABLE public.community_follower (
    community_id integer NOT NULL,
    person_id integer NOT NULL,
    published timestamp with time zone DEFAULT now() NOT NULL,
    pending boolean DEFAULT false NOT NULL
);


ALTER TABLE public.community_follower OWNER TO lemmy;

--
-- Name: community_id_seq; Type: SEQUENCE; Schema: public; Owner: lemmy
--

CREATE SEQUENCE public.community_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.community_id_seq OWNER TO lemmy;

--
-- Name: community_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: lemmy
--

ALTER SEQUENCE public.community_id_seq OWNED BY public.community.id;


--
-- Name: community_language; Type: TABLE; Schema: public; Owner: lemmy
--

CREATE TABLE public.community_language (
    community_id integer NOT NULL,
    language_id integer NOT NULL
);


ALTER TABLE public.community_language OWNER TO lemmy;

--
-- Name: community_moderator; Type: TABLE; Schema: public; Owner: lemmy
--

CREATE TABLE public.community_moderator (
    community_id integer NOT NULL,
    person_id integer NOT NULL,
    published timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.community_moderator OWNER TO lemmy;

--
-- Name: community_person_ban; Type: TABLE; Schema: public; Owner: lemmy
--

CREATE TABLE public.community_person_ban (
    community_id integer NOT NULL,
    person_id integer NOT NULL,
    published timestamp with time zone DEFAULT now() NOT NULL,
    expires timestamp with time zone
);


ALTER TABLE public.community_person_ban OWNER TO lemmy;

--
-- Name: custom_emoji; Type: TABLE; Schema: public; Owner: lemmy
--

CREATE TABLE public.custom_emoji (
    id integer NOT NULL,
    local_site_id integer NOT NULL,
    shortcode character varying(128) NOT NULL,
    image_url text NOT NULL,
    alt_text text NOT NULL,
    category text NOT NULL,
    published timestamp with time zone DEFAULT now() NOT NULL,
    updated timestamp with time zone
);


ALTER TABLE public.custom_emoji OWNER TO lemmy;

--
-- Name: custom_emoji_id_seq; Type: SEQUENCE; Schema: public; Owner: lemmy
--

CREATE SEQUENCE public.custom_emoji_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.custom_emoji_id_seq OWNER TO lemmy;

--
-- Name: custom_emoji_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: lemmy
--

ALTER SEQUENCE public.custom_emoji_id_seq OWNED BY public.custom_emoji.id;


--
-- Name: custom_emoji_keyword; Type: TABLE; Schema: public; Owner: lemmy
--

CREATE TABLE public.custom_emoji_keyword (
    custom_emoji_id integer NOT NULL,
    keyword character varying(128) NOT NULL
);


ALTER TABLE public.custom_emoji_keyword OWNER TO lemmy;

--
-- Name: email_verification; Type: TABLE; Schema: public; Owner: lemmy
--

CREATE TABLE public.email_verification (
    id integer NOT NULL,
    local_user_id integer NOT NULL,
    email text NOT NULL,
    verification_token text NOT NULL,
    published timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.email_verification OWNER TO lemmy;

--
-- Name: email_verification_id_seq; Type: SEQUENCE; Schema: public; Owner: lemmy
--

CREATE SEQUENCE public.email_verification_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.email_verification_id_seq OWNER TO lemmy;

--
-- Name: email_verification_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: lemmy
--

ALTER SEQUENCE public.email_verification_id_seq OWNED BY public.email_verification.id;


--
-- Name: federation_allowlist; Type: TABLE; Schema: public; Owner: lemmy
--

CREATE TABLE public.federation_allowlist (
    instance_id integer NOT NULL,
    published timestamp with time zone DEFAULT now() NOT NULL,
    updated timestamp with time zone
);


ALTER TABLE public.federation_allowlist OWNER TO lemmy;

--
-- Name: federation_blocklist; Type: TABLE; Schema: public; Owner: lemmy
--

CREATE TABLE public.federation_blocklist (
    instance_id integer NOT NULL,
    published timestamp with time zone DEFAULT now() NOT NULL,
    updated timestamp with time zone
);


ALTER TABLE public.federation_blocklist OWNER TO lemmy;

--
-- Name: federation_queue_state; Type: TABLE; Schema: public; Owner: lemmy
--

CREATE TABLE public.federation_queue_state (
    instance_id integer NOT NULL,
    last_successful_id bigint,
    fail_count integer NOT NULL,
    last_retry timestamp with time zone,
    last_successful_published_time timestamp with time zone
);


ALTER TABLE public.federation_queue_state OWNER TO lemmy;

--
-- Name: image_details; Type: TABLE; Schema: public; Owner: lemmy
--

CREATE TABLE public.image_details (
    link text NOT NULL,
    width integer NOT NULL,
    height integer NOT NULL,
    content_type text NOT NULL
);


ALTER TABLE public.image_details OWNER TO lemmy;

--
-- Name: instance; Type: TABLE; Schema: public; Owner: lemmy
--

CREATE TABLE public.instance (
    id integer NOT NULL,
    domain character varying(255) NOT NULL,
    published timestamp with time zone DEFAULT now() NOT NULL,
    updated timestamp with time zone,
    software character varying(255),
    version character varying(255)
);


ALTER TABLE public.instance OWNER TO lemmy;

--
-- Name: instance_block; Type: TABLE; Schema: public; Owner: lemmy
--

CREATE TABLE public.instance_block (
    person_id integer NOT NULL,
    instance_id integer NOT NULL,
    published timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.instance_block OWNER TO lemmy;

--
-- Name: instance_id_seq; Type: SEQUENCE; Schema: public; Owner: lemmy
--

CREATE SEQUENCE public.instance_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.instance_id_seq OWNER TO lemmy;

--
-- Name: instance_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: lemmy
--

ALTER SEQUENCE public.instance_id_seq OWNED BY public.instance.id;


--
-- Name: language; Type: TABLE; Schema: public; Owner: lemmy
--

CREATE TABLE public.language (
    id integer NOT NULL,
    code character varying(3) NOT NULL,
    name text NOT NULL
);


ALTER TABLE public.language OWNER TO lemmy;

--
-- Name: language_id_seq; Type: SEQUENCE; Schema: public; Owner: lemmy
--

CREATE SEQUENCE public.language_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.language_id_seq OWNER TO lemmy;

--
-- Name: language_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: lemmy
--

ALTER SEQUENCE public.language_id_seq OWNED BY public.language.id;


--
-- Name: local_image; Type: TABLE; Schema: public; Owner: lemmy
--

CREATE TABLE public.local_image (
    local_user_id integer,
    pictrs_alias text NOT NULL,
    pictrs_delete_token text NOT NULL,
    published timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.local_image OWNER TO lemmy;

--
-- Name: local_site; Type: TABLE; Schema: public; Owner: lemmy
--

CREATE TABLE public.local_site (
    id integer NOT NULL,
    site_id integer NOT NULL,
    site_setup boolean DEFAULT false NOT NULL,
    enable_downvotes boolean DEFAULT true NOT NULL,
    enable_nsfw boolean DEFAULT true NOT NULL,
    community_creation_admin_only boolean DEFAULT false NOT NULL,
    require_email_verification boolean DEFAULT false NOT NULL,
    application_question text DEFAULT 'to verify that you are human, please explain why you want to create an account on this site'::text,
    private_instance boolean DEFAULT false NOT NULL,
    default_theme text DEFAULT 'browser'::text NOT NULL,
    default_post_listing_type public.listing_type_enum DEFAULT 'Local'::public.listing_type_enum NOT NULL,
    legal_information text,
    hide_modlog_mod_names boolean DEFAULT true NOT NULL,
    application_email_admins boolean DEFAULT false NOT NULL,
    slur_filter_regex text,
    actor_name_max_length integer DEFAULT 20 NOT NULL,
    federation_enabled boolean DEFAULT true NOT NULL,
    captcha_enabled boolean DEFAULT false NOT NULL,
    captcha_difficulty character varying(255) DEFAULT 'medium'::character varying NOT NULL,
    published timestamp with time zone DEFAULT now() NOT NULL,
    updated timestamp with time zone,
    registration_mode public.registration_mode_enum DEFAULT 'RequireApplication'::public.registration_mode_enum NOT NULL,
    reports_email_admins boolean DEFAULT false NOT NULL,
    federation_signed_fetch boolean DEFAULT false NOT NULL,
    default_post_listing_mode public.post_listing_mode_enum DEFAULT 'List'::public.post_listing_mode_enum NOT NULL,
    default_sort_type public.sort_type_enum DEFAULT 'Active'::public.sort_type_enum NOT NULL
);


ALTER TABLE public.local_site OWNER TO lemmy;

--
-- Name: local_site_id_seq; Type: SEQUENCE; Schema: public; Owner: lemmy
--

CREATE SEQUENCE public.local_site_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.local_site_id_seq OWNER TO lemmy;

--
-- Name: local_site_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: lemmy
--

ALTER SEQUENCE public.local_site_id_seq OWNED BY public.local_site.id;


--
-- Name: local_site_rate_limit; Type: TABLE; Schema: public; Owner: lemmy
--

CREATE TABLE public.local_site_rate_limit (
    local_site_id integer NOT NULL,
    message integer DEFAULT 180 NOT NULL,
    message_per_second integer DEFAULT 60 NOT NULL,
    post integer DEFAULT 6 NOT NULL,
    post_per_second integer DEFAULT 600 NOT NULL,
    register integer DEFAULT 10 NOT NULL,
    register_per_second integer DEFAULT 3600 NOT NULL,
    image integer DEFAULT 6 NOT NULL,
    image_per_second integer DEFAULT 3600 NOT NULL,
    comment integer DEFAULT 6 NOT NULL,
    comment_per_second integer DEFAULT 600 NOT NULL,
    search integer DEFAULT 60 NOT NULL,
    search_per_second integer DEFAULT 600 NOT NULL,
    published timestamp with time zone DEFAULT now() NOT NULL,
    updated timestamp with time zone,
    import_user_settings integer DEFAULT 1 NOT NULL,
    import_user_settings_per_second integer DEFAULT 86400 NOT NULL
);


ALTER TABLE public.local_site_rate_limit OWNER TO lemmy;

--
-- Name: local_site_url_blocklist; Type: TABLE; Schema: public; Owner: lemmy
--

CREATE TABLE public.local_site_url_blocklist (
    id integer NOT NULL,
    url text NOT NULL,
    published timestamp with time zone DEFAULT now() NOT NULL,
    updated timestamp with time zone
);


ALTER TABLE public.local_site_url_blocklist OWNER TO lemmy;

--
-- Name: local_site_url_blocklist_id_seq; Type: SEQUENCE; Schema: public; Owner: lemmy
--

CREATE SEQUENCE public.local_site_url_blocklist_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.local_site_url_blocklist_id_seq OWNER TO lemmy;

--
-- Name: local_site_url_blocklist_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: lemmy
--

ALTER SEQUENCE public.local_site_url_blocklist_id_seq OWNED BY public.local_site_url_blocklist.id;


--
-- Name: local_user; Type: TABLE; Schema: public; Owner: lemmy
--

CREATE TABLE public.local_user (
    id integer NOT NULL,
    person_id integer NOT NULL,
    password_encrypted text NOT NULL,
    email text,
    show_nsfw boolean DEFAULT false NOT NULL,
    theme text DEFAULT 'browser'::text NOT NULL,
    default_sort_type public.sort_type_enum DEFAULT 'Active'::public.sort_type_enum NOT NULL,
    default_listing_type public.listing_type_enum DEFAULT 'Local'::public.listing_type_enum NOT NULL,
    interface_language character varying(20) DEFAULT 'browser'::character varying NOT NULL,
    show_avatars boolean DEFAULT true NOT NULL,
    send_notifications_to_email boolean DEFAULT false NOT NULL,
    show_scores boolean DEFAULT true NOT NULL,
    show_bot_accounts boolean DEFAULT true NOT NULL,
    show_read_posts boolean DEFAULT true NOT NULL,
    email_verified boolean DEFAULT false NOT NULL,
    accepted_application boolean DEFAULT false NOT NULL,
    totp_2fa_secret text,
    open_links_in_new_tab boolean DEFAULT false NOT NULL,
    blur_nsfw boolean DEFAULT true NOT NULL,
    auto_expand boolean DEFAULT false NOT NULL,
    infinite_scroll_enabled boolean DEFAULT false NOT NULL,
    admin boolean DEFAULT false NOT NULL,
    post_listing_mode public.post_listing_mode_enum DEFAULT 'List'::public.post_listing_mode_enum NOT NULL,
    totp_2fa_enabled boolean DEFAULT false NOT NULL,
    enable_keyboard_navigation boolean DEFAULT false NOT NULL,
    enable_animated_images boolean DEFAULT true NOT NULL,
    collapse_bot_comments boolean DEFAULT false NOT NULL,
    last_donation_notification timestamp with time zone DEFAULT (now() - (random() * '1 year'::interval)) NOT NULL
);


ALTER TABLE public.local_user OWNER TO lemmy;

--
-- Name: local_user_id_seq; Type: SEQUENCE; Schema: public; Owner: lemmy
--

CREATE SEQUENCE public.local_user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.local_user_id_seq OWNER TO lemmy;

--
-- Name: local_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: lemmy
--

ALTER SEQUENCE public.local_user_id_seq OWNED BY public.local_user.id;


--
-- Name: local_user_language; Type: TABLE; Schema: public; Owner: lemmy
--

CREATE TABLE public.local_user_language (
    local_user_id integer NOT NULL,
    language_id integer NOT NULL
);


ALTER TABLE public.local_user_language OWNER TO lemmy;

--
-- Name: local_user_vote_display_mode; Type: TABLE; Schema: public; Owner: lemmy
--

CREATE TABLE public.local_user_vote_display_mode (
    local_user_id integer NOT NULL,
    score boolean DEFAULT false NOT NULL,
    upvotes boolean DEFAULT true NOT NULL,
    downvotes boolean DEFAULT true NOT NULL,
    upvote_percentage boolean DEFAULT false NOT NULL
);


ALTER TABLE public.local_user_vote_display_mode OWNER TO lemmy;

--
-- Name: login_token; Type: TABLE; Schema: public; Owner: lemmy
--

CREATE TABLE public.login_token (
    token text NOT NULL,
    user_id integer NOT NULL,
    published timestamp with time zone DEFAULT now() NOT NULL,
    ip text,
    user_agent text
);


ALTER TABLE public.login_token OWNER TO lemmy;

--
-- Name: mod_add; Type: TABLE; Schema: public; Owner: lemmy
--

CREATE TABLE public.mod_add (
    id integer NOT NULL,
    mod_person_id integer NOT NULL,
    other_person_id integer NOT NULL,
    removed boolean DEFAULT false NOT NULL,
    when_ timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.mod_add OWNER TO lemmy;

--
-- Name: mod_add_community; Type: TABLE; Schema: public; Owner: lemmy
--

CREATE TABLE public.mod_add_community (
    id integer NOT NULL,
    mod_person_id integer NOT NULL,
    other_person_id integer NOT NULL,
    community_id integer NOT NULL,
    removed boolean DEFAULT false NOT NULL,
    when_ timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.mod_add_community OWNER TO lemmy;

--
-- Name: mod_add_community_id_seq; Type: SEQUENCE; Schema: public; Owner: lemmy
--

CREATE SEQUENCE public.mod_add_community_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.mod_add_community_id_seq OWNER TO lemmy;

--
-- Name: mod_add_community_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: lemmy
--

ALTER SEQUENCE public.mod_add_community_id_seq OWNED BY public.mod_add_community.id;


--
-- Name: mod_add_id_seq; Type: SEQUENCE; Schema: public; Owner: lemmy
--

CREATE SEQUENCE public.mod_add_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.mod_add_id_seq OWNER TO lemmy;

--
-- Name: mod_add_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: lemmy
--

ALTER SEQUENCE public.mod_add_id_seq OWNED BY public.mod_add.id;


--
-- Name: mod_ban; Type: TABLE; Schema: public; Owner: lemmy
--

CREATE TABLE public.mod_ban (
    id integer NOT NULL,
    mod_person_id integer NOT NULL,
    other_person_id integer NOT NULL,
    reason text,
    banned boolean DEFAULT true NOT NULL,
    expires timestamp with time zone,
    when_ timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.mod_ban OWNER TO lemmy;

--
-- Name: mod_ban_from_community; Type: TABLE; Schema: public; Owner: lemmy
--

CREATE TABLE public.mod_ban_from_community (
    id integer NOT NULL,
    mod_person_id integer NOT NULL,
    other_person_id integer NOT NULL,
    community_id integer NOT NULL,
    reason text,
    banned boolean DEFAULT true NOT NULL,
    expires timestamp with time zone,
    when_ timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.mod_ban_from_community OWNER TO lemmy;

--
-- Name: mod_ban_from_community_id_seq; Type: SEQUENCE; Schema: public; Owner: lemmy
--

CREATE SEQUENCE public.mod_ban_from_community_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.mod_ban_from_community_id_seq OWNER TO lemmy;

--
-- Name: mod_ban_from_community_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: lemmy
--

ALTER SEQUENCE public.mod_ban_from_community_id_seq OWNED BY public.mod_ban_from_community.id;


--
-- Name: mod_ban_id_seq; Type: SEQUENCE; Schema: public; Owner: lemmy
--

CREATE SEQUENCE public.mod_ban_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.mod_ban_id_seq OWNER TO lemmy;

--
-- Name: mod_ban_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: lemmy
--

ALTER SEQUENCE public.mod_ban_id_seq OWNED BY public.mod_ban.id;


--
-- Name: mod_feature_post; Type: TABLE; Schema: public; Owner: lemmy
--

CREATE TABLE public.mod_feature_post (
    id integer NOT NULL,
    mod_person_id integer NOT NULL,
    post_id integer NOT NULL,
    featured boolean DEFAULT true NOT NULL,
    when_ timestamp with time zone DEFAULT now() NOT NULL,
    is_featured_community boolean DEFAULT true NOT NULL
);


ALTER TABLE public.mod_feature_post OWNER TO lemmy;

--
-- Name: mod_hide_community; Type: TABLE; Schema: public; Owner: lemmy
--

CREATE TABLE public.mod_hide_community (
    id integer NOT NULL,
    community_id integer NOT NULL,
    mod_person_id integer NOT NULL,
    when_ timestamp with time zone DEFAULT now() NOT NULL,
    reason text,
    hidden boolean DEFAULT false NOT NULL
);


ALTER TABLE public.mod_hide_community OWNER TO lemmy;

--
-- Name: mod_hide_community_id_seq; Type: SEQUENCE; Schema: public; Owner: lemmy
--

CREATE SEQUENCE public.mod_hide_community_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.mod_hide_community_id_seq OWNER TO lemmy;

--
-- Name: mod_hide_community_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: lemmy
--

ALTER SEQUENCE public.mod_hide_community_id_seq OWNED BY public.mod_hide_community.id;


--
-- Name: mod_lock_post; Type: TABLE; Schema: public; Owner: lemmy
--

CREATE TABLE public.mod_lock_post (
    id integer NOT NULL,
    mod_person_id integer NOT NULL,
    post_id integer NOT NULL,
    locked boolean DEFAULT true NOT NULL,
    when_ timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.mod_lock_post OWNER TO lemmy;

--
-- Name: mod_lock_post_id_seq; Type: SEQUENCE; Schema: public; Owner: lemmy
--

CREATE SEQUENCE public.mod_lock_post_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.mod_lock_post_id_seq OWNER TO lemmy;

--
-- Name: mod_lock_post_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: lemmy
--

ALTER SEQUENCE public.mod_lock_post_id_seq OWNED BY public.mod_lock_post.id;


--
-- Name: mod_remove_comment; Type: TABLE; Schema: public; Owner: lemmy
--

CREATE TABLE public.mod_remove_comment (
    id integer NOT NULL,
    mod_person_id integer NOT NULL,
    comment_id integer NOT NULL,
    reason text,
    removed boolean DEFAULT true NOT NULL,
    when_ timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.mod_remove_comment OWNER TO lemmy;

--
-- Name: mod_remove_comment_id_seq; Type: SEQUENCE; Schema: public; Owner: lemmy
--

CREATE SEQUENCE public.mod_remove_comment_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.mod_remove_comment_id_seq OWNER TO lemmy;

--
-- Name: mod_remove_comment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: lemmy
--

ALTER SEQUENCE public.mod_remove_comment_id_seq OWNED BY public.mod_remove_comment.id;


--
-- Name: mod_remove_community; Type: TABLE; Schema: public; Owner: lemmy
--

CREATE TABLE public.mod_remove_community (
    id integer NOT NULL,
    mod_person_id integer NOT NULL,
    community_id integer NOT NULL,
    reason text,
    removed boolean DEFAULT true NOT NULL,
    when_ timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.mod_remove_community OWNER TO lemmy;

--
-- Name: mod_remove_community_id_seq; Type: SEQUENCE; Schema: public; Owner: lemmy
--

CREATE SEQUENCE public.mod_remove_community_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.mod_remove_community_id_seq OWNER TO lemmy;

--
-- Name: mod_remove_community_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: lemmy
--

ALTER SEQUENCE public.mod_remove_community_id_seq OWNED BY public.mod_remove_community.id;


--
-- Name: mod_remove_post; Type: TABLE; Schema: public; Owner: lemmy
--

CREATE TABLE public.mod_remove_post (
    id integer NOT NULL,
    mod_person_id integer NOT NULL,
    post_id integer NOT NULL,
    reason text,
    removed boolean DEFAULT true NOT NULL,
    when_ timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.mod_remove_post OWNER TO lemmy;

--
-- Name: mod_remove_post_id_seq; Type: SEQUENCE; Schema: public; Owner: lemmy
--

CREATE SEQUENCE public.mod_remove_post_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.mod_remove_post_id_seq OWNER TO lemmy;

--
-- Name: mod_remove_post_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: lemmy
--

ALTER SEQUENCE public.mod_remove_post_id_seq OWNED BY public.mod_remove_post.id;


--
-- Name: mod_sticky_post_id_seq; Type: SEQUENCE; Schema: public; Owner: lemmy
--

CREATE SEQUENCE public.mod_sticky_post_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.mod_sticky_post_id_seq OWNER TO lemmy;

--
-- Name: mod_sticky_post_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: lemmy
--

ALTER SEQUENCE public.mod_sticky_post_id_seq OWNED BY public.mod_feature_post.id;


--
-- Name: mod_transfer_community; Type: TABLE; Schema: public; Owner: lemmy
--

CREATE TABLE public.mod_transfer_community (
    id integer NOT NULL,
    mod_person_id integer NOT NULL,
    other_person_id integer NOT NULL,
    community_id integer NOT NULL,
    when_ timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.mod_transfer_community OWNER TO lemmy;

--
-- Name: mod_transfer_community_id_seq; Type: SEQUENCE; Schema: public; Owner: lemmy
--

CREATE SEQUENCE public.mod_transfer_community_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.mod_transfer_community_id_seq OWNER TO lemmy;

--
-- Name: mod_transfer_community_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: lemmy
--

ALTER SEQUENCE public.mod_transfer_community_id_seq OWNED BY public.mod_transfer_community.id;


--
-- Name: password_reset_request; Type: TABLE; Schema: public; Owner: lemmy
--

CREATE TABLE public.password_reset_request (
    id integer NOT NULL,
    token text NOT NULL,
    published timestamp with time zone DEFAULT now() NOT NULL,
    local_user_id integer NOT NULL
);


ALTER TABLE public.password_reset_request OWNER TO lemmy;

--
-- Name: password_reset_request_id_seq; Type: SEQUENCE; Schema: public; Owner: lemmy
--

CREATE SEQUENCE public.password_reset_request_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.password_reset_request_id_seq OWNER TO lemmy;

--
-- Name: password_reset_request_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: lemmy
--

ALTER SEQUENCE public.password_reset_request_id_seq OWNED BY public.password_reset_request.id;


--
-- Name: person; Type: TABLE; Schema: public; Owner: lemmy
--

CREATE TABLE public.person (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    display_name character varying(255),
    avatar text,
    banned boolean DEFAULT false NOT NULL,
    published timestamp with time zone DEFAULT now() NOT NULL,
    updated timestamp with time zone,
    actor_id character varying(255) DEFAULT public.generate_unique_changeme() NOT NULL,
    bio text,
    local boolean DEFAULT true NOT NULL,
    private_key text,
    public_key text NOT NULL,
    last_refreshed_at timestamp with time zone DEFAULT now() NOT NULL,
    banner text,
    deleted boolean DEFAULT false NOT NULL,
    inbox_url character varying(255) DEFAULT public.generate_unique_changeme() NOT NULL,
    shared_inbox_url character varying(255),
    matrix_user_id text,
    bot_account boolean DEFAULT false NOT NULL,
    ban_expires timestamp with time zone,
    instance_id integer NOT NULL
);


ALTER TABLE public.person OWNER TO lemmy;

--
-- Name: person_aggregates; Type: TABLE; Schema: public; Owner: lemmy
--

CREATE TABLE public.person_aggregates (
    person_id integer NOT NULL,
    post_count bigint DEFAULT 0 NOT NULL,
    post_score bigint DEFAULT 0 NOT NULL,
    comment_count bigint DEFAULT 0 NOT NULL,
    comment_score bigint DEFAULT 0 NOT NULL
);


ALTER TABLE public.person_aggregates OWNER TO lemmy;

--
-- Name: person_ban; Type: TABLE; Schema: public; Owner: lemmy
--

CREATE TABLE public.person_ban (
    person_id integer NOT NULL,
    published timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.person_ban OWNER TO lemmy;

--
-- Name: person_block; Type: TABLE; Schema: public; Owner: lemmy
--

CREATE TABLE public.person_block (
    person_id integer NOT NULL,
    target_id integer NOT NULL,
    published timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.person_block OWNER TO lemmy;

--
-- Name: person_follower; Type: TABLE; Schema: public; Owner: lemmy
--

CREATE TABLE public.person_follower (
    person_id integer NOT NULL,
    follower_id integer NOT NULL,
    published timestamp with time zone DEFAULT now() NOT NULL,
    pending boolean NOT NULL
);


ALTER TABLE public.person_follower OWNER TO lemmy;

--
-- Name: person_id_seq; Type: SEQUENCE; Schema: public; Owner: lemmy
--

CREATE SEQUENCE public.person_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.person_id_seq OWNER TO lemmy;

--
-- Name: person_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: lemmy
--

ALTER SEQUENCE public.person_id_seq OWNED BY public.person.id;


--
-- Name: person_mention; Type: TABLE; Schema: public; Owner: lemmy
--

CREATE TABLE public.person_mention (
    id integer NOT NULL,
    recipient_id integer NOT NULL,
    comment_id integer NOT NULL,
    read boolean DEFAULT false NOT NULL,
    published timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.person_mention OWNER TO lemmy;

--
-- Name: person_mention_id_seq; Type: SEQUENCE; Schema: public; Owner: lemmy
--

CREATE SEQUENCE public.person_mention_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.person_mention_id_seq OWNER TO lemmy;

--
-- Name: person_mention_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: lemmy
--

ALTER SEQUENCE public.person_mention_id_seq OWNED BY public.person_mention.id;


--
-- Name: person_post_aggregates; Type: TABLE; Schema: public; Owner: lemmy
--

CREATE TABLE public.person_post_aggregates (
    person_id integer NOT NULL,
    post_id integer NOT NULL,
    read_comments bigint DEFAULT 0 NOT NULL,
    published timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.person_post_aggregates OWNER TO lemmy;

--
-- Name: post; Type: TABLE; Schema: public; Owner: lemmy
--

CREATE TABLE public.post (
    id integer NOT NULL,
    name character varying(200) NOT NULL,
    url character varying(2000),
    body text,
    creator_id integer NOT NULL,
    community_id integer NOT NULL,
    removed boolean DEFAULT false NOT NULL,
    locked boolean DEFAULT false NOT NULL,
    published timestamp with time zone DEFAULT now() NOT NULL,
    updated timestamp with time zone,
    deleted boolean DEFAULT false NOT NULL,
    nsfw boolean DEFAULT false NOT NULL,
    embed_title text,
    embed_description text,
    thumbnail_url text,
    ap_id character varying(255) NOT NULL,
    local boolean DEFAULT true NOT NULL,
    embed_video_url text,
    language_id integer DEFAULT 0 NOT NULL,
    featured_community boolean DEFAULT false NOT NULL,
    featured_local boolean DEFAULT false NOT NULL,
    url_content_type text,
    alt_text text
);


ALTER TABLE public.post OWNER TO lemmy;

--
-- Name: post_hide; Type: TABLE; Schema: public; Owner: lemmy
--

CREATE TABLE public.post_hide (
    post_id integer NOT NULL,
    person_id integer NOT NULL,
    published timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.post_hide OWNER TO lemmy;

--
-- Name: post_id_seq; Type: SEQUENCE; Schema: public; Owner: lemmy
--

CREATE SEQUENCE public.post_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.post_id_seq OWNER TO lemmy;

--
-- Name: post_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: lemmy
--

ALTER SEQUENCE public.post_id_seq OWNED BY public.post.id;


--
-- Name: post_like; Type: TABLE; Schema: public; Owner: lemmy
--

CREATE TABLE public.post_like (
    post_id integer NOT NULL,
    person_id integer NOT NULL,
    score smallint NOT NULL,
    published timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.post_like OWNER TO lemmy;

--
-- Name: post_read; Type: TABLE; Schema: public; Owner: lemmy
--

CREATE TABLE public.post_read (
    post_id integer NOT NULL,
    person_id integer NOT NULL,
    published timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.post_read OWNER TO lemmy;

--
-- Name: post_report; Type: TABLE; Schema: public; Owner: lemmy
--

CREATE TABLE public.post_report (
    id integer NOT NULL,
    creator_id integer NOT NULL,
    post_id integer NOT NULL,
    original_post_name character varying(200) NOT NULL,
    original_post_url text,
    original_post_body text,
    reason text NOT NULL,
    resolved boolean DEFAULT false NOT NULL,
    resolver_id integer,
    published timestamp with time zone DEFAULT now() NOT NULL,
    updated timestamp with time zone
);


ALTER TABLE public.post_report OWNER TO lemmy;

--
-- Name: post_report_id_seq; Type: SEQUENCE; Schema: public; Owner: lemmy
--

CREATE SEQUENCE public.post_report_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.post_report_id_seq OWNER TO lemmy;

--
-- Name: post_report_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: lemmy
--

ALTER SEQUENCE public.post_report_id_seq OWNED BY public.post_report.id;


--
-- Name: post_saved; Type: TABLE; Schema: public; Owner: lemmy
--

CREATE TABLE public.post_saved (
    post_id integer NOT NULL,
    person_id integer NOT NULL,
    published timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.post_saved OWNER TO lemmy;

--
-- Name: private_message; Type: TABLE; Schema: public; Owner: lemmy
--

CREATE TABLE public.private_message (
    id integer NOT NULL,
    creator_id integer NOT NULL,
    recipient_id integer NOT NULL,
    content text NOT NULL,
    deleted boolean DEFAULT false NOT NULL,
    read boolean DEFAULT false NOT NULL,
    published timestamp with time zone DEFAULT now() NOT NULL,
    updated timestamp with time zone,
    ap_id character varying(255) NOT NULL,
    local boolean DEFAULT true NOT NULL,
    removed boolean DEFAULT false NOT NULL
);


ALTER TABLE public.private_message OWNER TO lemmy;

--
-- Name: private_message_id_seq; Type: SEQUENCE; Schema: public; Owner: lemmy
--

CREATE SEQUENCE public.private_message_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.private_message_id_seq OWNER TO lemmy;

--
-- Name: private_message_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: lemmy
--

ALTER SEQUENCE public.private_message_id_seq OWNED BY public.private_message.id;


--
-- Name: private_message_report; Type: TABLE; Schema: public; Owner: lemmy
--

CREATE TABLE public.private_message_report (
    id integer NOT NULL,
    creator_id integer NOT NULL,
    private_message_id integer NOT NULL,
    original_pm_text text NOT NULL,
    reason text NOT NULL,
    resolved boolean DEFAULT false NOT NULL,
    resolver_id integer,
    published timestamp with time zone DEFAULT now() NOT NULL,
    updated timestamp with time zone
);


ALTER TABLE public.private_message_report OWNER TO lemmy;

--
-- Name: private_message_report_id_seq; Type: SEQUENCE; Schema: public; Owner: lemmy
--

CREATE SEQUENCE public.private_message_report_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.private_message_report_id_seq OWNER TO lemmy;

--
-- Name: private_message_report_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: lemmy
--

ALTER SEQUENCE public.private_message_report_id_seq OWNED BY public.private_message_report.id;


--
-- Name: received_activity; Type: TABLE; Schema: public; Owner: lemmy
--

CREATE TABLE public.received_activity (
    ap_id text NOT NULL,
    published timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.received_activity OWNER TO lemmy;

--
-- Name: registration_application; Type: TABLE; Schema: public; Owner: lemmy
--

CREATE TABLE public.registration_application (
    id integer NOT NULL,
    local_user_id integer NOT NULL,
    answer text NOT NULL,
    admin_id integer,
    deny_reason text,
    published timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.registration_application OWNER TO lemmy;

--
-- Name: registration_application_id_seq; Type: SEQUENCE; Schema: public; Owner: lemmy
--

CREATE SEQUENCE public.registration_application_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.registration_application_id_seq OWNER TO lemmy;

--
-- Name: registration_application_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: lemmy
--

ALTER SEQUENCE public.registration_application_id_seq OWNED BY public.registration_application.id;


--
-- Name: remote_image; Type: TABLE; Schema: public; Owner: lemmy
--

CREATE TABLE public.remote_image (
    link text NOT NULL,
    published timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.remote_image OWNER TO lemmy;

--
-- Name: secret; Type: TABLE; Schema: public; Owner: lemmy
--

CREATE TABLE public.secret (
    id integer NOT NULL,
    jwt_secret character varying DEFAULT gen_random_uuid() NOT NULL
);


ALTER TABLE public.secret OWNER TO lemmy;

--
-- Name: secret_id_seq; Type: SEQUENCE; Schema: public; Owner: lemmy
--

CREATE SEQUENCE public.secret_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.secret_id_seq OWNER TO lemmy;

--
-- Name: secret_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: lemmy
--

ALTER SEQUENCE public.secret_id_seq OWNED BY public.secret.id;


--
-- Name: sent_activity; Type: TABLE; Schema: public; Owner: lemmy
--

CREATE TABLE public.sent_activity (
    id bigint NOT NULL,
    ap_id text NOT NULL,
    data json NOT NULL,
    sensitive boolean NOT NULL,
    published timestamp with time zone DEFAULT now() NOT NULL,
    send_inboxes text[] NOT NULL,
    send_community_followers_of integer,
    send_all_instances boolean NOT NULL,
    actor_type public.actor_type_enum NOT NULL,
    actor_apub_id text
);


ALTER TABLE public.sent_activity OWNER TO lemmy;

--
-- Name: sent_activity_id_seq; Type: SEQUENCE; Schema: public; Owner: lemmy
--

CREATE SEQUENCE public.sent_activity_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.sent_activity_id_seq OWNER TO lemmy;

--
-- Name: sent_activity_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: lemmy
--

ALTER SEQUENCE public.sent_activity_id_seq OWNED BY public.sent_activity.id;


--
-- Name: site; Type: TABLE; Schema: public; Owner: lemmy
--

CREATE TABLE public.site (
    id integer NOT NULL,
    name character varying(20) NOT NULL,
    sidebar text,
    published timestamp with time zone DEFAULT now() NOT NULL,
    updated timestamp with time zone,
    icon text,
    banner text,
    description character varying(150),
    actor_id character varying(255) DEFAULT public.generate_unique_changeme() NOT NULL,
    last_refreshed_at timestamp with time zone DEFAULT now() NOT NULL,
    inbox_url character varying(255) DEFAULT public.generate_unique_changeme() NOT NULL,
    private_key text,
    public_key text DEFAULT public.generate_unique_changeme() NOT NULL,
    instance_id integer NOT NULL,
    content_warning text
);


ALTER TABLE public.site OWNER TO lemmy;

--
-- Name: site_aggregates; Type: TABLE; Schema: public; Owner: lemmy
--

CREATE TABLE public.site_aggregates (
    site_id integer NOT NULL,
    users bigint DEFAULT 1 NOT NULL,
    posts bigint DEFAULT 0 NOT NULL,
    comments bigint DEFAULT 0 NOT NULL,
    communities bigint DEFAULT 0 NOT NULL,
    users_active_day bigint DEFAULT 0 NOT NULL,
    users_active_week bigint DEFAULT 0 NOT NULL,
    users_active_month bigint DEFAULT 0 NOT NULL,
    users_active_half_year bigint DEFAULT 0 NOT NULL
);


ALTER TABLE public.site_aggregates OWNER TO lemmy;

--
-- Name: site_id_seq; Type: SEQUENCE; Schema: public; Owner: lemmy
--

CREATE SEQUENCE public.site_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.site_id_seq OWNER TO lemmy;

--
-- Name: site_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: lemmy
--

ALTER SEQUENCE public.site_id_seq OWNED BY public.site.id;


--
-- Name: site_language; Type: TABLE; Schema: public; Owner: lemmy
--

CREATE TABLE public.site_language (
    site_id integer NOT NULL,
    language_id integer NOT NULL
);


ALTER TABLE public.site_language OWNER TO lemmy;

--
-- Name: tagline; Type: TABLE; Schema: public; Owner: lemmy
--

CREATE TABLE public.tagline (
    id integer NOT NULL,
    local_site_id integer NOT NULL,
    content text NOT NULL,
    published timestamp with time zone DEFAULT now() NOT NULL,
    updated timestamp with time zone
);


ALTER TABLE public.tagline OWNER TO lemmy;

--
-- Name: tagline_id_seq; Type: SEQUENCE; Schema: public; Owner: lemmy
--

CREATE SEQUENCE public.tagline_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tagline_id_seq OWNER TO lemmy;

--
-- Name: tagline_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: lemmy
--

ALTER SEQUENCE public.tagline_id_seq OWNED BY public.tagline.id;


--
-- Name: deps_saved_ddl; Type: TABLE; Schema: utils; Owner: lemmy
--

CREATE TABLE utils.deps_saved_ddl (
    id integer NOT NULL,
    view_schema character varying(255),
    view_name character varying(255),
    ddl_to_run text
);


ALTER TABLE utils.deps_saved_ddl OWNER TO lemmy;

--
-- Name: deps_saved_ddl_id_seq; Type: SEQUENCE; Schema: utils; Owner: lemmy
--

CREATE SEQUENCE utils.deps_saved_ddl_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE utils.deps_saved_ddl_id_seq OWNER TO lemmy;

--
-- Name: deps_saved_ddl_id_seq; Type: SEQUENCE OWNED BY; Schema: utils; Owner: lemmy
--

ALTER SEQUENCE utils.deps_saved_ddl_id_seq OWNED BY utils.deps_saved_ddl.id;


--
-- Name: admin_purge_comment id; Type: DEFAULT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.admin_purge_comment ALTER COLUMN id SET DEFAULT nextval('public.admin_purge_comment_id_seq'::regclass);


--
-- Name: admin_purge_community id; Type: DEFAULT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.admin_purge_community ALTER COLUMN id SET DEFAULT nextval('public.admin_purge_community_id_seq'::regclass);


--
-- Name: admin_purge_person id; Type: DEFAULT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.admin_purge_person ALTER COLUMN id SET DEFAULT nextval('public.admin_purge_person_id_seq'::regclass);


--
-- Name: admin_purge_post id; Type: DEFAULT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.admin_purge_post ALTER COLUMN id SET DEFAULT nextval('public.admin_purge_post_id_seq'::regclass);


--
-- Name: comment id; Type: DEFAULT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.comment ALTER COLUMN id SET DEFAULT nextval('public.comment_id_seq'::regclass);


--
-- Name: comment_reply id; Type: DEFAULT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.comment_reply ALTER COLUMN id SET DEFAULT nextval('public.comment_reply_id_seq'::regclass);


--
-- Name: comment_report id; Type: DEFAULT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.comment_report ALTER COLUMN id SET DEFAULT nextval('public.comment_report_id_seq'::regclass);


--
-- Name: community id; Type: DEFAULT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.community ALTER COLUMN id SET DEFAULT nextval('public.community_id_seq'::regclass);


--
-- Name: custom_emoji id; Type: DEFAULT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.custom_emoji ALTER COLUMN id SET DEFAULT nextval('public.custom_emoji_id_seq'::regclass);


--
-- Name: email_verification id; Type: DEFAULT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.email_verification ALTER COLUMN id SET DEFAULT nextval('public.email_verification_id_seq'::regclass);


--
-- Name: instance id; Type: DEFAULT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.instance ALTER COLUMN id SET DEFAULT nextval('public.instance_id_seq'::regclass);


--
-- Name: language id; Type: DEFAULT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.language ALTER COLUMN id SET DEFAULT nextval('public.language_id_seq'::regclass);


--
-- Name: local_site id; Type: DEFAULT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.local_site ALTER COLUMN id SET DEFAULT nextval('public.local_site_id_seq'::regclass);


--
-- Name: local_site_url_blocklist id; Type: DEFAULT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.local_site_url_blocklist ALTER COLUMN id SET DEFAULT nextval('public.local_site_url_blocklist_id_seq'::regclass);


--
-- Name: local_user id; Type: DEFAULT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.local_user ALTER COLUMN id SET DEFAULT nextval('public.local_user_id_seq'::regclass);


--
-- Name: mod_add id; Type: DEFAULT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.mod_add ALTER COLUMN id SET DEFAULT nextval('public.mod_add_id_seq'::regclass);


--
-- Name: mod_add_community id; Type: DEFAULT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.mod_add_community ALTER COLUMN id SET DEFAULT nextval('public.mod_add_community_id_seq'::regclass);


--
-- Name: mod_ban id; Type: DEFAULT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.mod_ban ALTER COLUMN id SET DEFAULT nextval('public.mod_ban_id_seq'::regclass);


--
-- Name: mod_ban_from_community id; Type: DEFAULT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.mod_ban_from_community ALTER COLUMN id SET DEFAULT nextval('public.mod_ban_from_community_id_seq'::regclass);


--
-- Name: mod_feature_post id; Type: DEFAULT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.mod_feature_post ALTER COLUMN id SET DEFAULT nextval('public.mod_sticky_post_id_seq'::regclass);


--
-- Name: mod_hide_community id; Type: DEFAULT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.mod_hide_community ALTER COLUMN id SET DEFAULT nextval('public.mod_hide_community_id_seq'::regclass);


--
-- Name: mod_lock_post id; Type: DEFAULT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.mod_lock_post ALTER COLUMN id SET DEFAULT nextval('public.mod_lock_post_id_seq'::regclass);


--
-- Name: mod_remove_comment id; Type: DEFAULT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.mod_remove_comment ALTER COLUMN id SET DEFAULT nextval('public.mod_remove_comment_id_seq'::regclass);


--
-- Name: mod_remove_community id; Type: DEFAULT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.mod_remove_community ALTER COLUMN id SET DEFAULT nextval('public.mod_remove_community_id_seq'::regclass);


--
-- Name: mod_remove_post id; Type: DEFAULT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.mod_remove_post ALTER COLUMN id SET DEFAULT nextval('public.mod_remove_post_id_seq'::regclass);


--
-- Name: mod_transfer_community id; Type: DEFAULT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.mod_transfer_community ALTER COLUMN id SET DEFAULT nextval('public.mod_transfer_community_id_seq'::regclass);


--
-- Name: password_reset_request id; Type: DEFAULT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.password_reset_request ALTER COLUMN id SET DEFAULT nextval('public.password_reset_request_id_seq'::regclass);


--
-- Name: person id; Type: DEFAULT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.person ALTER COLUMN id SET DEFAULT nextval('public.person_id_seq'::regclass);


--
-- Name: person_mention id; Type: DEFAULT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.person_mention ALTER COLUMN id SET DEFAULT nextval('public.person_mention_id_seq'::regclass);


--
-- Name: post id; Type: DEFAULT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.post ALTER COLUMN id SET DEFAULT nextval('public.post_id_seq'::regclass);


--
-- Name: post_report id; Type: DEFAULT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.post_report ALTER COLUMN id SET DEFAULT nextval('public.post_report_id_seq'::regclass);


--
-- Name: private_message id; Type: DEFAULT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.private_message ALTER COLUMN id SET DEFAULT nextval('public.private_message_id_seq'::regclass);


--
-- Name: private_message_report id; Type: DEFAULT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.private_message_report ALTER COLUMN id SET DEFAULT nextval('public.private_message_report_id_seq'::regclass);


--
-- Name: registration_application id; Type: DEFAULT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.registration_application ALTER COLUMN id SET DEFAULT nextval('public.registration_application_id_seq'::regclass);


--
-- Name: secret id; Type: DEFAULT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.secret ALTER COLUMN id SET DEFAULT nextval('public.secret_id_seq'::regclass);


--
-- Name: sent_activity id; Type: DEFAULT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.sent_activity ALTER COLUMN id SET DEFAULT nextval('public.sent_activity_id_seq'::regclass);


--
-- Name: site id; Type: DEFAULT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.site ALTER COLUMN id SET DEFAULT nextval('public.site_id_seq'::regclass);


--
-- Name: tagline id; Type: DEFAULT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.tagline ALTER COLUMN id SET DEFAULT nextval('public.tagline_id_seq'::regclass);


--
-- Name: deps_saved_ddl id; Type: DEFAULT; Schema: utils; Owner: lemmy
--

ALTER TABLE ONLY utils.deps_saved_ddl ALTER COLUMN id SET DEFAULT nextval('utils.deps_saved_ddl_id_seq'::regclass);


--
-- Data for Name: __diesel_schema_migrations; Type: TABLE DATA; Schema: public; Owner: lemmy
--

COPY public.__diesel_schema_migrations (version, run_on) FROM stdin;
00000000000000	2025-05-08 04:33:55.032267
20190226002946	2025-05-08 04:33:55.037015
20190227170003	2025-05-08 04:33:55.058874
20190303163336	2025-05-08 04:33:55.107801
20190305233828	2025-05-08 04:33:55.140023
20190330212058	2025-05-08 04:33:55.158035
20190403155205	2025-05-08 04:33:55.164991
20190403155309	2025-05-08 04:33:55.172676
20190407003142	2025-05-08 04:33:55.179001
20190408015947	2025-05-08 04:33:55.210413
20190411144915	2025-05-08 04:33:55.21354
20190429175834	2025-05-08 04:33:55.225428
20190502051656	2025-05-08 04:33:55.249959
20190601222649	2025-05-08 04:33:55.256262
20190811000918	2025-05-08 04:33:55.267932
20190829040006	2025-05-08 04:33:55.282269
20190905230317	2025-05-08 04:33:55.286681
20190909042010	2025-05-08 04:33:55.294843
20191015181630	2025-05-08 04:33:55.310173
20191019052737	2025-05-08 04:33:55.312024
20191021011237	2025-05-08 04:33:55.320644
20191024002614	2025-05-08 04:33:55.323127
20191209060754	2025-05-08 04:33:55.329071
20191211181820	2025-05-08 04:33:55.330968
20191229164820	2025-05-08 04:33:55.336351
20200101200418	2025-05-08 04:33:55.377905
20200102172755	2025-05-08 04:33:55.38151
20200111012452	2025-05-08 04:33:55.385792
20200113025151	2025-05-08 04:33:55.394256
20200121001001	2025-05-08 04:33:55.464812
20200129011901	2025-05-08 04:33:55.492645
20200129030825	2025-05-08 04:33:55.497264
20200202004806	2025-05-08 04:33:55.502153
20200206165953	2025-05-08 04:33:55.562631
20200207210055	2025-05-08 04:33:55.596268
20200208145624	2025-05-08 04:33:55.628136
20200306202329	2025-05-08 04:33:55.818758
20200326192410	2025-05-08 04:33:55.89324
20200403194936	2025-05-08 04:33:55.911538
20200407135912	2025-05-08 04:33:55.917099
20200414163701	2025-05-08 04:33:55.94712
20200421123957	2025-05-08 04:33:56.136093
20200505210233	2025-05-08 04:33:56.138929
20200630135809	2025-05-08 04:33:56.152815
20200708202609	2025-05-08 04:33:56.251305
20200712100442	2025-05-08 04:33:56.307759
20200718234519	2025-05-08 04:33:56.338799
20200803000110	2025-05-08 04:33:56.345141
20200806205355	2025-05-08 04:33:56.441306
20200825132005	2025-05-08 04:33:56.459775
20200907231141	2025-05-08 04:33:56.467089
20201007234221	2025-05-08 04:33:56.471762
20201010035723	2025-05-08 04:33:56.474051
20201013212240	2025-05-08 04:33:56.475758
20201023115011	2025-05-08 04:33:56.494927
20201105152724	2025-05-08 04:33:56.49619
20201110150835	2025-05-08 04:33:56.498887
20201126134531	2025-05-08 04:33:56.5003
20201202152437	2025-05-08 04:33:56.501992
20201203035643	2025-05-08 04:33:56.510277
20201204183345	2025-05-08 04:33:56.544586
20201210152350	2025-05-08 04:33:56.552441
20201214020038	2025-05-08 04:33:56.560263
20201217030456	2025-05-08 04:33:56.566699
20201217031053	2025-05-08 04:33:56.571262
20210105200932	2025-05-08 04:33:56.61738
20210126173850	2025-05-08 04:33:56.628872
20210127202728	2025-05-08 04:33:56.630057
20210131050334	2025-05-08 04:33:56.638889
20210202153240	2025-05-08 04:33:56.640633
20210210164051	2025-05-08 04:33:56.662847
20210213210612	2025-05-08 04:33:56.667701
20210225112959	2025-05-08 04:33:56.669159
20210228162616	2025-05-08 04:33:56.673898
20210304040229	2025-05-08 04:33:56.674847
20210309171136	2025-05-08 04:33:56.677752
20210319014144	2025-05-08 04:33:56.712888
20210320185321	2025-05-08 04:33:56.714457
20210331103917	2025-05-08 04:33:56.721694
20210331105915	2025-05-08 04:33:56.723179
20210331144349	2025-05-08 04:33:56.728545
20210401173552	2025-05-08 04:33:56.729944
20210401181826	2025-05-08 04:33:56.734581
20210402021422	2025-05-08 04:33:56.736162
20210420155001	2025-05-08 04:33:56.739043
20210424174047	2025-05-08 04:33:56.74057
20210719130929	2025-05-08 04:33:56.741922
20210720102033	2025-05-08 04:33:56.743168
20210802002342	2025-05-08 04:33:56.748787
20210804223559	2025-05-08 04:33:56.750384
20210816004209	2025-05-08 04:33:56.759375
20210817210508	2025-05-08 04:33:56.760832
20210920112945	2025-05-08 04:33:56.766076
20211001141650	2025-05-08 04:33:56.776158
20211122135324	2025-05-08 04:33:56.792398
20211122143904	2025-05-08 04:33:56.79532
20211123031528	2025-05-08 04:33:56.797421
20211123132840	2025-05-08 04:33:56.799711
20211123153753	2025-05-08 04:33:56.805948
20211209225529	2025-05-08 04:33:56.813664
20211214181537	2025-05-08 04:33:56.815049
20220104034553	2025-05-08 04:33:56.820482
20220120160328	2025-05-08 04:33:56.826348
20220128104106	2025-05-08 04:33:56.828725
20220201154240	2025-05-08 04:33:56.837367
20220218210946	2025-05-08 04:33:56.839156
20220404183652	2025-05-08 04:33:56.841083
20220411210137	2025-05-08 04:33:56.849182
20220412114352	2025-05-08 04:33:56.850301
20220412185205	2025-05-08 04:33:56.851832
20220419111004	2025-05-08 04:33:56.853392
20220426105145	2025-05-08 04:33:56.855183
20220519153931	2025-05-08 04:33:56.857342
20220520135341	2025-05-08 04:33:56.858639
20220612012121	2025-05-08 04:33:56.860165
20220613124806	2025-05-08 04:33:56.86165
20220621123144	2025-05-08 04:33:56.862923
20220707182650	2025-05-08 04:33:56.877997
20220804150644	2025-05-08 04:33:56.936175
20220804214722	2025-05-08 04:33:56.93797
20220805203502	2025-05-08 04:33:56.939569
20220822193848	2025-05-08 04:33:56.945673
20220907113813	2025-05-08 04:33:56.949133
20220907114618	2025-05-08 04:33:56.950276
20220908102358	2025-05-08 04:33:56.957163
20220924161829	2025-05-08 04:33:56.966871
20221006183632	2025-05-08 04:33:56.96952
20221113181529	2025-05-08 04:33:57.004214
20221120032430	2025-05-08 04:33:57.008916
20221121143249	2025-05-08 04:33:57.018036
20221121204256	2025-05-08 04:33:57.02018
20221205110642	2025-05-08 04:33:57.026054
20230117165819	2025-05-08 04:33:57.029825
20230201012747	2025-05-08 04:33:57.041469
20230205102549	2025-05-08 04:33:57.045252
20230207030958	2025-05-08 04:33:57.047135
20230211173347	2025-05-08 04:33:57.052957
20230213172528	2025-05-08 04:33:57.068226
20230213221303	2025-05-08 04:33:57.070037
20230215212546	2025-05-08 04:33:57.072824
20230216194139	2025-05-08 04:33:57.075636
20230414175955	2025-05-08 04:33:57.077136
20230423164732	2025-05-08 04:33:57.103277
20230510095739	2025-05-08 04:33:57.117537
20230606104440	2025-05-08 04:33:57.119214
20230607105918	2025-05-08 04:33:57.127547
20230617175955	2025-05-08 04:33:57.142304
20230619055530	2025-05-08 04:33:57.143535
20230619120700	2025-05-08 04:33:57.145212
20230620191145	2025-05-08 04:33:57.150334
20230621153242	2025-05-08 04:33:57.151457
20230622051755	2025-05-08 04:33:57.156387
20230622101245	2025-05-08 04:33:57.158749
20230624072904	2025-05-08 04:33:57.161434
20230624185942	2025-05-08 04:33:57.162807
20230627065106	2025-05-08 04:33:57.165234
20230704153335	2025-05-08 04:33:57.166959
20230705000058	2025-05-08 04:33:57.180833
20230706151124	2025-05-08 04:33:57.183518
20230708101154	2025-05-08 04:33:57.184624
20230710075550	2025-05-08 04:33:57.186844
20230711084714	2025-05-08 04:33:57.188402
20230714154840	2025-05-08 04:33:57.200157
20230714215339	2025-05-08 04:33:57.21141
20230718082614	2025-05-08 04:33:57.214607
20230719163511	2025-05-08 04:33:57.221403
20230724232635	2025-05-08 04:33:57.224699
20230726000217	2025-05-08 04:33:57.241336
20230726222023	2025-05-08 04:33:57.24709
20230727134652	2025-05-08 04:33:57.248666
20230801101826	2025-05-08 04:33:57.250412
20230801115243	2025-05-08 04:33:57.254228
20230802144930	2025-05-08 04:33:57.269486
20230802174444	2025-05-08 04:33:57.271444
20230808163911	2025-05-08 04:33:57.369351
20230809101305	2025-05-08 04:33:57.371596
20230823182533	2025-05-08 04:33:57.382515
20230829183053	2025-05-08 04:33:57.418968
20230831205559	2025-05-08 04:33:57.420464
20230901112158	2025-05-08 04:33:57.426464
20230907215546	2025-05-08 04:33:57.428235
20230911110040	2025-05-08 04:33:57.446271
20230912194850	2025-05-08 04:33:57.448003
20230918141700	2025-05-08 04:33:57.449875
20230920110614	2025-05-08 04:33:57.456627
20230928084231	2025-05-08 04:33:57.458262
20231002145002	2025-05-08 04:33:57.460104
20231006133405	2025-05-08 04:33:57.461238
20231013175712	2025-05-08 04:33:57.46259
20231017181800	2025-05-08 04:33:57.464458
20231023184941	2025-05-08 04:33:57.46572
20231024030352	2025-05-08 04:33:57.46698
20231024131607	2025-05-08 04:33:57.552179
20231024183747	2025-05-08 04:33:57.556668
20231027142514	2025-05-08 04:33:57.558157
20231101223740	2025-05-08 04:33:57.559358
20231102120140	2025-05-08 04:33:57.561147
20231107135409	2025-05-08 04:33:57.562964
20231122194806	2025-05-08 04:33:57.566704
20231206180359	2025-05-08 04:33:57.570213
20231219210053	2025-05-08 04:33:57.571714
20231222040137	2025-05-08 04:33:57.575896
20240102094916	2025-05-08 04:33:57.580915
20240105213000	2025-05-08 04:33:57.582807
20240115100133	2025-05-08 04:33:57.587261
20240122105746	2025-05-08 04:33:57.591077
20240125151400	2025-05-08 04:33:57.594821
20240212211114	2025-05-08 04:33:57.598466
20240215171358	2025-05-08 04:33:57.605421
20240224034523	2025-05-08 04:33:57.607029
20240227204628	2025-05-08 04:33:57.63597
20240228144211	2025-05-08 04:33:57.638115
20240306104706	2025-05-08 04:33:57.648616
20240306201637	2025-05-08 04:33:57.651091
20240405153647	2025-05-08 04:33:57.660422
20240415105932	2025-05-08 04:33:57.66993
20240423020604	2025-05-08 04:33:57.672309
20240504140749	2025-05-08 04:33:57.747372
20240505162540	2025-05-08 04:33:57.749133
20240617160323	2025-05-08 04:33:57.757435
20240624000000	2025-05-08 04:33:57.766037
20240701014711	2025-05-08 04:33:57.769107
20240803155932	2025-05-08 04:33:57.770968
20241112090437	2025-05-08 04:33:57.774548
20250110135505	2025-05-08 04:33:57.776153
20250211131045	2025-05-08 04:33:57.786603
20250224173152	2025-05-08 04:33:57.7885
20250307094522	2025-05-08 04:33:57.791811
20250407100344	2025-05-08 04:33:57.794402
\.


--
-- Data for Name: admin_purge_comment; Type: TABLE DATA; Schema: public; Owner: lemmy
--

COPY public.admin_purge_comment (id, admin_person_id, post_id, reason, when_) FROM stdin;
\.


--
-- Data for Name: admin_purge_community; Type: TABLE DATA; Schema: public; Owner: lemmy
--

COPY public.admin_purge_community (id, admin_person_id, reason, when_) FROM stdin;
\.


--
-- Data for Name: admin_purge_person; Type: TABLE DATA; Schema: public; Owner: lemmy
--

COPY public.admin_purge_person (id, admin_person_id, reason, when_) FROM stdin;
\.


--
-- Data for Name: admin_purge_post; Type: TABLE DATA; Schema: public; Owner: lemmy
--

COPY public.admin_purge_post (id, admin_person_id, community_id, reason, when_) FROM stdin;
\.


--
-- Data for Name: captcha_answer; Type: TABLE DATA; Schema: public; Owner: lemmy
--

COPY public.captcha_answer (uuid, answer, published) FROM stdin;
\.


--
-- Data for Name: comment; Type: TABLE DATA; Schema: public; Owner: lemmy
--

COPY public.comment (id, creator_id, post_id, content, removed, published, updated, deleted, ap_id, local, path, distinguished, language_id) FROM stdin;
1	2	1	Jython is the implementation of Python in Java it is not meant to be fast , the only benefit of using it over python is to have access to the **JVM** and the **Java Classes** (Like **Kotlin** does) so you don't need an API to do that\nAlso the JVM is usually slower than the **JIT** compiler on a lot of cases\n\nIf you want a flexible language and want to still access the JVM using modern JVM based languages instead	f	2025-05-08 04:51:54.970633+00	\N	f	https://localhost/comment/1	t	0.1	f	0
\.


--
-- Data for Name: comment_aggregates; Type: TABLE DATA; Schema: public; Owner: lemmy
--

COPY public.comment_aggregates (comment_id, score, upvotes, downvotes, published, child_count, hot_rank, controversy_rank) FROM stdin;
1	1	1	0	2025-05-08 04:51:54.970633+00	0	0.0007303555649147031	0
\.


--
-- Data for Name: comment_like; Type: TABLE DATA; Schema: public; Owner: lemmy
--

COPY public.comment_like (person_id, comment_id, post_id, score, published) FROM stdin;
2	1	1	1	2025-05-08 04:51:55.023539+00
\.


--
-- Data for Name: comment_reply; Type: TABLE DATA; Schema: public; Owner: lemmy
--

COPY public.comment_reply (id, recipient_id, comment_id, read, published) FROM stdin;
\.


--
-- Data for Name: comment_report; Type: TABLE DATA; Schema: public; Owner: lemmy
--

COPY public.comment_report (id, creator_id, comment_id, original_comment_text, reason, resolved, resolver_id, published, updated) FROM stdin;
\.


--
-- Data for Name: comment_saved; Type: TABLE DATA; Schema: public; Owner: lemmy
--

COPY public.comment_saved (comment_id, person_id, published) FROM stdin;
\.


--
-- Data for Name: community; Type: TABLE DATA; Schema: public; Owner: lemmy
--

COPY public.community (id, name, title, description, removed, published, updated, deleted, nsfw, actor_id, local, private_key, public_key, last_refreshed_at, icon, banner, followers_url, inbox_url, shared_inbox_url, hidden, posting_restricted_to_mods, instance_id, moderators_url, featured_url, visibility) FROM stdin;
2	python_official	Python	Official Python community	f	2025-05-08 04:46:20.505514+00	2025-05-09 09:50:19.430673+00	f	f	https://localhost/c/python_official	t	-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDlJKgbSoJF7DwL\nWlUXuEa4T85A6bP7N2GQ1VWBRtU4XzSvEf11rD2r/1OAWgPmLh1MOLEDKKb1C35S\n1xqzlBhoDtsfKiMr/IsODJFzNrSpa48p/2lWp8QtXhKl3KUz+PvNThu4liRGDUvx\nWM6Q2NOiOCuZELzWno7m9HNOCVxyaKJ/RCfrSR7lYnVEYQ1uzhuCgjrkrO0TuefZ\n02Md1UKSUkh/wQbNo/q0U8b0XKWnTqaYVOIqoXVPlRhqSwmSjAysX1tX5u9kV1CD\n8iOTOpzY5+QvimA6i5H7fqC+oojKqwYNwPSDtMNSpxVbU4NUR5PYq7x89lfrtAAT\nrBZL/rMzAgMBAAECggEBAIgx7n0yHxZCYDn7OgJ8NASO4q+weJqDg0kbk9Pf7xGv\nfNfl4HmVo55chxwN5K1mkWFhfMy81+dkKnRAiA1eo9cNpW3zlK4rT9dM3xLU3DKq\nzJAQ0GKCGtdAR+Mvrz2h6sBPgaiIDQ1aD95mg3iSd8++hSNYUHVcDuH1P6eNZtZU\nfMXGSENXWNK7+pYx1mXkcafTAKTQ9RIdIxqsTPGctUU+WHbmzCIy9RXlCxVeX8IU\n5XcWnr8pIr8XUrBlYJOfZJtg8+XVVHWzl1p+CRIlMUypl7ERYKdpnUOGLN7tmdcs\nzPPMp/ny0pwV3w36oNqgbZd4N7224e7/HVM01Mk+SUECgYEA++tepLetCAM5QbCD\nOow7Ws8kRsEp+zsTQS+NYX+0ZNTrW0HUprRJ7zLgoeTZRjeGxtlEnxhFIMAcyuaS\nFEInjo6BTBuVkaf41ehfhh0BxuxlIJR6cBu6LGXHD/zlQ6Mgie+MuF7klk6yFx9M\ny4nFeDY3/X3xrCV2cGhWf3D+cVMCgYEA6NrXVh64RpUoaSUgCHLlWlbyZ/Be4oAJ\n/gc9FzG39S69NnWMFqTAFI5qYLmsSGYRz+8k1WEo9Rmt2mM/6+ckTVw+0U1iRie6\nsnuEtiiE7h99nak81wDkzl5FyAvqJulW0JPioAIe7LqBQkTf0ApGU9AaR52mTj39\nLfeshifNGqECgYB+x8dLsjxcafLowkJotqYwX0rsaM4N538bMSk/xhstG5KOzKSO\nePE0djBiiV9nXQ5xCGrmfjpb7xMOcddWZqytq74aZU9yjExIqrdYMUTxrYp/SPoN\nbYbWTSpPO4DN90yq3mm9Z9Q2aMhrpo7paB5/DxpCcp2revcOPxQ48s66jQKBgQCr\nrNziM5ftAf9fNe3eDMenyT7C/ucV2wyC61dRCGj2LVV3F0cHUsQC49TuJzYr0oUD\nZu8jGpUVz67rugzgofOTzZTKv2DbFGODP6nimxEWdsUoPiQK6C/JLpwIFzC1K4fE\nE6QcEDQ4mHDAKQNR4KFlHaKidkqsmOtWvqnF5wZCwQKBgGo0m0pYfxJ3U2LvzJPh\nQe/lxa38BM9CKz+JivutXfIDUqp9UBxAFvMKSvu6DUUbPMmrwjRFvc42v7KOeUgC\nloEsU9o6VvVaGzIUcID9VtMOq0KxxkgUpzsepYC4SoU3cebqqaieU9wnXnj16u7C\nmkHkVuBcpq/YIdrmHo7aOfdf\n-----END PRIVATE KEY-----\n	-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA5SSoG0qCRew8C1pVF7hG\nuE/OQOmz+zdhkNVVgUbVOF80rxH9daw9q/9TgFoD5i4dTDixAyim9Qt+Utcas5QY\naA7bHyojK/yLDgyRcza0qWuPKf9pVqfELV4SpdylM/j7zU4buJYkRg1L8VjOkNjT\nojgrmRC81p6O5vRzTglccmiif0Qn60ke5WJ1RGENbs4bgoI65KztE7nn2dNjHdVC\nklJIf8EGzaP6tFPG9Fylp06mmFTiKqF1T5UYaksJkowMrF9bV+bvZFdQg/Ijkzqc\n2OfkL4pgOouR+36gvqKIyqsGDcD0g7TDUqcVW1ODVEeT2Ku8fPZX67QAE6wWS/6z\nMwIDAQAB\n-----END PUBLIC KEY-----\n	2025-05-08 04:46:20.505514+00	http://127.0.0.1:10633/pictrs/image/3d7586eb-a0b2-4fbc-ae83-a5d891d93214.jpeg	http://127.0.0.1:10633/pictrs/image/7e46cfee-8fc8-4f19-ad49-f2eb6f89c1cf.jpeg	https://localhost/c/python_official/followers	https://localhost/c/python_official/inbox	https://localhost/inbox	f	f	1	\N	\N	Public
\.


--
-- Data for Name: community_aggregates; Type: TABLE DATA; Schema: public; Owner: lemmy
--

COPY public.community_aggregates (community_id, subscribers, posts, comments, published, users_active_day, users_active_week, users_active_month, users_active_half_year, hot_rank, subscribers_local) FROM stdin;
2	1	1	1	2025-05-08 04:46:20.505514+00	1	1	1	1	0.0007270337340558675	1
\.


--
-- Data for Name: community_block; Type: TABLE DATA; Schema: public; Owner: lemmy
--

COPY public.community_block (person_id, community_id, published) FROM stdin;
\.


--
-- Data for Name: community_follower; Type: TABLE DATA; Schema: public; Owner: lemmy
--

COPY public.community_follower (community_id, person_id, published, pending) FROM stdin;
2	2	2025-05-08 04:46:20.530981+00	f
\.


--
-- Data for Name: community_language; Type: TABLE DATA; Schema: public; Owner: lemmy
--

COPY public.community_language (community_id, language_id) FROM stdin;
2	0
2	1
2	2
2	3
2	4
2	5
2	6
2	7
2	8
2	9
2	10
2	11
2	12
2	13
2	14
2	15
2	16
2	17
2	18
2	19
2	20
2	21
2	22
2	23
2	24
2	25
2	26
2	27
2	28
2	29
2	30
2	31
2	32
2	33
2	34
2	35
2	36
2	37
2	38
2	39
2	40
2	41
2	42
2	43
2	44
2	45
2	46
2	47
2	48
2	49
2	50
2	51
2	52
2	53
2	54
2	55
2	56
2	57
2	58
2	59
2	60
2	61
2	62
2	63
2	64
2	65
2	66
2	67
2	68
2	69
2	70
2	71
2	72
2	73
2	74
2	75
2	76
2	77
2	78
2	79
2	80
2	81
2	82
2	83
2	84
2	85
2	86
2	87
2	88
2	89
2	90
2	91
2	92
2	93
2	94
2	95
2	96
2	97
2	98
2	99
2	100
2	101
2	102
2	103
2	104
2	105
2	106
2	107
2	108
2	109
2	110
2	111
2	112
2	113
2	114
2	115
2	116
2	117
2	118
2	119
2	120
2	121
2	122
2	123
2	124
2	125
2	126
2	127
2	128
2	129
2	130
2	131
2	132
2	133
2	134
2	135
2	136
2	137
2	138
2	139
2	140
2	141
2	142
2	143
2	144
2	145
2	146
2	147
2	148
2	149
2	150
2	151
2	152
2	153
2	154
2	155
2	156
2	157
2	158
2	159
2	160
2	161
2	162
2	163
2	164
2	165
2	166
2	167
2	168
2	169
2	170
2	171
2	172
2	173
2	174
2	175
2	176
2	177
2	178
2	179
2	180
2	181
2	182
2	183
\.


--
-- Data for Name: community_moderator; Type: TABLE DATA; Schema: public; Owner: lemmy
--

COPY public.community_moderator (community_id, person_id, published) FROM stdin;
2	2	2025-05-08 04:46:20.528728+00
\.


--
-- Data for Name: community_person_ban; Type: TABLE DATA; Schema: public; Owner: lemmy
--

COPY public.community_person_ban (community_id, person_id, published, expires) FROM stdin;
\.


--
-- Data for Name: custom_emoji; Type: TABLE DATA; Schema: public; Owner: lemmy
--

COPY public.custom_emoji (id, local_site_id, shortcode, image_url, alt_text, category, published, updated) FROM stdin;
\.


--
-- Data for Name: custom_emoji_keyword; Type: TABLE DATA; Schema: public; Owner: lemmy
--

COPY public.custom_emoji_keyword (custom_emoji_id, keyword) FROM stdin;
\.


--
-- Data for Name: email_verification; Type: TABLE DATA; Schema: public; Owner: lemmy
--

COPY public.email_verification (id, local_user_id, email, verification_token, published) FROM stdin;
\.


--
-- Data for Name: federation_allowlist; Type: TABLE DATA; Schema: public; Owner: lemmy
--

COPY public.federation_allowlist (instance_id, published, updated) FROM stdin;
\.


--
-- Data for Name: federation_blocklist; Type: TABLE DATA; Schema: public; Owner: lemmy
--

COPY public.federation_blocklist (instance_id, published, updated) FROM stdin;
\.


--
-- Data for Name: federation_queue_state; Type: TABLE DATA; Schema: public; Owner: lemmy
--

COPY public.federation_queue_state (instance_id, last_successful_id, fail_count, last_retry, last_successful_published_time) FROM stdin;
\.


--
-- Data for Name: image_details; Type: TABLE DATA; Schema: public; Owner: lemmy
--

COPY public.image_details (link, width, height, content_type) FROM stdin;
https://localhost/pictrs/image/78d0d598-c7c3-4f24-b333-9926eb0807e4.png	1024	1024	image/png
https://localhost/pictrs/image/2c2c8a0c-0617-408a-b47b-e2745a5ebe7f.png	1536	1024	image/png
https://localhost/pictrs/image/87ab1ae3-f868-460f-9991-fc2a797b001b.jpeg	148	148	image/jpeg
https://localhost/pictrs/image/cdc3443f-6adf-4bda-bf1d-5e21c624d87c.jpeg	345	146	image/jpeg
https://localhost/pictrs/image/bc3ae7d3-8c1b-44bd-a171-6ccf95f4b563.png	1024	1024	image/png
https://localhost/pictrs/image/30d45bde-5ec6-4304-a50d-9337692f0ac5.png	1536	1024	image/png
https://localhost/pictrs/image/3d7586eb-a0b2-4fbc-ae83-a5d891d93214.jpeg	148	148	image/jpeg
https://localhost/pictrs/image/7e46cfee-8fc8-4f19-ad49-f2eb6f89c1cf.jpeg	345	146	image/jpeg
\.


--
-- Data for Name: instance; Type: TABLE DATA; Schema: public; Owner: lemmy
--

COPY public.instance (id, domain, published, updated, software, version) FROM stdin;
1	localhost	2025-05-08 04:33:57.894453+00	2025-05-08 04:33:57.894003+00	\N	\N
\.


--
-- Data for Name: instance_block; Type: TABLE DATA; Schema: public; Owner: lemmy
--

COPY public.instance_block (person_id, instance_id, published) FROM stdin;
\.


--
-- Data for Name: language; Type: TABLE DATA; Schema: public; Owner: lemmy
--

COPY public.language (id, code, name) FROM stdin;
0	und	Undetermined
1	aa	Afaraf
2	ab	аҧсуа бызшәа
3	ae	avesta
4	af	Afrikaans
5	ak	Akan
6	am	አማርኛ
7	an	aragonés
8	ar	اَلْعَرَبِيَّةُ
9	as	অসমীয়া
10	av	авар мацӀ
11	ay	aymar aru
12	az	azərbaycan dili
13	ba	башҡорт теле
14	be	беларуская мова
15	bg	български език
16	bi	Bislama
17	bm	bamanankan
18	bn	বাংলা
19	bo	བོད་ཡིག
20	br	brezhoneg
21	bs	bosanski jezik
22	ca	Català
23	ce	нохчийн мотт
24	ch	Chamoru
25	co	corsu
26	cr	ᓀᐦᐃᔭᐍᐏᐣ
27	cs	čeština
28	cu	ѩзыкъ словѣньскъ
29	cv	чӑваш чӗлхи
30	cy	Cymraeg
31	da	dansk
32	de	Deutsch
33	dv	ދިވެހި
34	dz	རྫོང་ཁ
35	ee	Eʋegbe
36	el	Ελληνικά
37	en	English
38	eo	Esperanto
39	es	Español
40	et	eesti
41	eu	euskara
42	fa	فارسی
43	ff	Fulfulde
44	fi	suomi
45	fj	vosa Vakaviti
46	fo	føroyskt
47	fr	Français
48	fy	Frysk
49	ga	Gaeilge
50	gd	Gàidhlig
51	gl	galego
52	gn	Avañe'ẽ
53	gu	ગુજરાતી
54	gv	Gaelg
55	ha	هَوُسَ
56	he	עברית
57	hi	हिन्दी
58	ho	Hiri Motu
59	hr	Hrvatski
60	ht	Kreyòl ayisyen
61	hu	magyar
62	hy	Հայերեն
63	hz	Otjiherero
64	ia	Interlingua
65	id	Bahasa Indonesia
66	ie	Interlingue
67	ig	Asụsụ Igbo
68	ii	ꆈꌠ꒿ Nuosuhxop
69	ik	Iñupiaq
70	io	Ido
71	is	Íslenska
72	it	Italiano
73	iu	ᐃᓄᒃᑎᑐᑦ
74	ja	日本語
75	jv	basa Jawa
76	ka	ქართული
77	kg	Kikongo
78	ki	Gĩkũyũ
79	kj	Kuanyama
80	kk	қазақ тілі
81	kl	kalaallisut
82	km	ខេមរភាសា
83	kn	ಕನ್ನಡ
84	ko	한국어
85	kr	Kanuri
86	ks	कश्मीरी
87	ku	Kurdî
88	kv	коми кыв
89	kw	Kernewek
90	ky	Кыргызча
91	la	latine
92	lb	Lëtzebuergesch
93	lg	Luganda
94	li	Limburgs
95	ln	Lingála
96	lo	ພາສາລາວ
97	lt	lietuvių kalba
98	lu	Kiluba
99	lv	latviešu valoda
100	mg	fiteny malagasy
101	mh	Kajin M̧ajeļ
102	mi	te reo Māori
103	mk	македонски јазик
104	ml	മലയാളം
105	mn	Монгол хэл
106	mr	मराठी
107	ms	Bahasa Melayu
108	mt	Malti
109	my	ဗမာစာ
110	na	Dorerin Naoero
111	nb	Norsk bokmål
112	nd	isiNdebele
113	ne	नेपाली
114	ng	Owambo
115	nl	Nederlands
116	nn	Norsk nynorsk
117	no	Norsk
118	nr	isiNdebele
119	nv	Diné bizaad
120	ny	chiCheŵa
121	oc	occitan
122	oj	ᐊᓂᔑᓈᐯᒧᐎᓐ
123	om	Afaan Oromoo
124	or	ଓଡ଼ିଆ
125	os	ирон æвзаг
126	pa	ਪੰਜਾਬੀ
127	pi	पाऴि
128	pl	Polski
129	ps	پښتو
130	pt	Português
131	qu	Runa Simi
132	rm	rumantsch grischun
133	rn	Ikirundi
134	ro	Română
135	ru	Русский
136	rw	Ikinyarwanda
137	sa	संस्कृतम्
138	sc	sardu
139	sd	सिन्धी
140	se	Davvisámegiella
141	sg	yângâ tî sängö
142	si	සිංහල
143	sk	slovenčina
144	sl	slovenščina
145	sm	gagana fa'a Samoa
146	sn	chiShona
147	so	Soomaaliga
148	sq	Shqip
149	sr	српски језик
150	ss	SiSwati
151	st	Sesotho
152	su	Basa Sunda
153	sv	Svenska
154	sw	Kiswahili
155	ta	தமிழ்
156	te	తెలుగు
157	tg	тоҷикӣ
158	th	ไทย
159	ti	ትግርኛ
160	tk	Türkmençe
161	tl	Wikang Tagalog
162	tn	Setswana
163	to	faka Tonga
164	tr	Türkçe
165	ts	Xitsonga
166	tt	татар теле
167	tw	Twi
168	ty	Reo Tahiti
169	ug	ئۇيغۇرچە‎
170	uk	Українська
171	ur	اردو
172	uz	Ўзбек
173	ve	Tshivenḓa
174	vi	Tiếng Việt
175	vo	Volapük
176	wa	walon
177	wo	Wollof
178	xh	isiXhosa
179	yi	ייִדיש
180	yo	Yorùbá
181	za	Saɯ cueŋƅ
182	zh	中文
183	zu	isiZulu
\.


--
-- Data for Name: local_image; Type: TABLE DATA; Schema: public; Owner: lemmy
--

COPY public.local_image (local_user_id, pictrs_alias, pictrs_delete_token, published) FROM stdin;
1	bc3ae7d3-8c1b-44bd-a171-6ccf95f4b563.png	d6634a5a-c54e-4756-93ac-2f72744b22b7	2025-05-09 09:49:18.350631+00
1	30d45bde-5ec6-4304-a50d-9337692f0ac5.png	77cb9d1b-43ec-4a0d-b0c8-dc3fbdf3defa	2025-05-09 09:49:23.816366+00
1	3d7586eb-a0b2-4fbc-ae83-a5d891d93214.jpeg	179cf9d7-6ffb-401c-b4a8-fadf31391e89	2025-05-09 09:50:12.229538+00
1	7e46cfee-8fc8-4f19-ad49-f2eb6f89c1cf.jpeg	0de73f32-0d59-41c8-9bb7-fc86d8451c01	2025-05-09 09:50:16.647744+00
\.


--
-- Data for Name: local_site; Type: TABLE DATA; Schema: public; Owner: lemmy
--

COPY public.local_site (id, site_id, site_setup, enable_downvotes, enable_nsfw, community_creation_admin_only, require_email_verification, application_question, private_instance, default_theme, default_post_listing_type, legal_information, hide_modlog_mod_names, application_email_admins, slur_filter_regex, actor_name_max_length, federation_enabled, captcha_enabled, captcha_difficulty, published, updated, registration_mode, reports_email_admins, federation_signed_fetch, default_post_listing_mode, default_sort_type) FROM stdin;
1	1	t	t	f	t	f	to verify that you are human, please explain why you want to create an account on this site	f	browser	Local	The platform is for **educational** discussions and content only, anything outside that makes users subject to ban\n\nThe platform runs under Algerian laws anything violating the law results in **immediate** ban	t	f	\N	20	f	t	medium	2025-05-08 04:33:58.485067+00	2025-05-09 09:49:26.455034+00	RequireApplication	f	f	List	Active
\.


--
-- Data for Name: local_site_rate_limit; Type: TABLE DATA; Schema: public; Owner: lemmy
--

COPY public.local_site_rate_limit (local_site_id, message, message_per_second, post, post_per_second, register, register_per_second, image, image_per_second, comment, comment_per_second, search, search_per_second, published, updated, import_user_settings, import_user_settings_per_second) FROM stdin;
1	180	60	6	600	10	3600	6	3600	6	600	60	600	2025-05-08 04:33:58.487819+00	\N	1	86400
\.


--
-- Data for Name: local_site_url_blocklist; Type: TABLE DATA; Schema: public; Owner: lemmy
--

COPY public.local_site_url_blocklist (id, url, published, updated) FROM stdin;
\.


--
-- Data for Name: local_user; Type: TABLE DATA; Schema: public; Owner: lemmy
--

COPY public.local_user (id, person_id, password_encrypted, email, show_nsfw, theme, default_sort_type, default_listing_type, interface_language, show_avatars, send_notifications_to_email, show_scores, show_bot_accounts, show_read_posts, email_verified, accepted_application, totp_2fa_secret, open_links_in_new_tab, blur_nsfw, auto_expand, infinite_scroll_enabled, admin, post_listing_mode, totp_2fa_enabled, enable_keyboard_navigation, enable_animated_images, collapse_bot_comments, last_donation_notification) FROM stdin;
1	2	$2b$12$Bs7YZDbIlpYdfd9ikyQwKeAP.lxx2Z029kfiJZCBprTn5ISnsnyj.	\N	t	browser	Active	Local	en	t	f	t	t	t	f	f	\N	f	t	f	f	t	List	f	f	t	f	2024-09-08 06:28:50.263675+00
\.


--
-- Data for Name: local_user_language; Type: TABLE DATA; Schema: public; Owner: lemmy
--

COPY public.local_user_language (local_user_id, language_id) FROM stdin;
1	0
1	1
1	2
1	3
1	4
1	5
1	6
1	7
1	8
1	9
1	10
1	11
1	12
1	13
1	14
1	15
1	16
1	17
1	18
1	19
1	20
1	21
1	22
1	23
1	24
1	25
1	26
1	27
1	28
1	29
1	30
1	31
1	32
1	33
1	34
1	35
1	36
1	37
1	38
1	39
1	40
1	41
1	42
1	43
1	44
1	45
1	46
1	47
1	48
1	49
1	50
1	51
1	52
1	53
1	54
1	55
1	56
1	57
1	58
1	59
1	60
1	61
1	62
1	63
1	64
1	65
1	66
1	67
1	68
1	69
1	70
1	71
1	72
1	73
1	74
1	75
1	76
1	77
1	78
1	79
1	80
1	81
1	82
1	83
1	84
1	85
1	86
1	87
1	88
1	89
1	90
1	91
1	92
1	93
1	94
1	95
1	96
1	97
1	98
1	99
1	100
1	101
1	102
1	103
1	104
1	105
1	106
1	107
1	108
1	109
1	110
1	111
1	112
1	113
1	114
1	115
1	116
1	117
1	118
1	119
1	120
1	121
1	122
1	123
1	124
1	125
1	126
1	127
1	128
1	129
1	130
1	131
1	132
1	133
1	134
1	135
1	136
1	137
1	138
1	139
1	140
1	141
1	142
1	143
1	144
1	145
1	146
1	147
1	148
1	149
1	150
1	151
1	152
1	153
1	154
1	155
1	156
1	157
1	158
1	159
1	160
1	161
1	162
1	163
1	164
1	165
1	166
1	167
1	168
1	169
1	170
1	171
1	172
1	173
1	174
1	175
1	176
1	177
1	178
1	179
1	180
1	181
1	182
1	183
\.


--
-- Data for Name: local_user_vote_display_mode; Type: TABLE DATA; Schema: public; Owner: lemmy
--

COPY public.local_user_vote_display_mode (local_user_id, score, upvotes, downvotes, upvote_percentage) FROM stdin;
1	f	t	t	f
\.


--
-- Data for Name: login_token; Type: TABLE DATA; Schema: public; Owner: lemmy
--

COPY public.login_token (token, user_id, published, ip, user_agent) FROM stdin;
eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwiaXNzIjoibG9jYWxob3N0IiwiaWF0IjoxNzQ2Njc4ODczfQ.RfGBjDC--zNK7dlONUHVt28rULIe3xTYvlk_Heb9Bls	1	2025-05-08 04:34:33.150982+00	172.18.0.1	Mozilla/5.0 (X11; Linux x86_64; rv:138.0) Gecko/20100101 Firefox/138.0
eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwiaXNzIjoibG9jYWxob3N0IiwiaWF0IjoxNzQ2NzgzMTc5fQ.Sy92bhmFs4UT2AwzfiONyq3UXbt8HcnM4RylSA4uaac	1	2025-05-09 09:32:59.34699+00	172.21.0.1	Mozilla/5.0 (X11; Linux x86_64; rv:138.0) Gecko/20100101 Firefox/138.0
\.


--
-- Data for Name: mod_add; Type: TABLE DATA; Schema: public; Owner: lemmy
--

COPY public.mod_add (id, mod_person_id, other_person_id, removed, when_) FROM stdin;
\.


--
-- Data for Name: mod_add_community; Type: TABLE DATA; Schema: public; Owner: lemmy
--

COPY public.mod_add_community (id, mod_person_id, other_person_id, community_id, removed, when_) FROM stdin;
\.


--
-- Data for Name: mod_ban; Type: TABLE DATA; Schema: public; Owner: lemmy
--

COPY public.mod_ban (id, mod_person_id, other_person_id, reason, banned, expires, when_) FROM stdin;
\.


--
-- Data for Name: mod_ban_from_community; Type: TABLE DATA; Schema: public; Owner: lemmy
--

COPY public.mod_ban_from_community (id, mod_person_id, other_person_id, community_id, reason, banned, expires, when_) FROM stdin;
\.


--
-- Data for Name: mod_feature_post; Type: TABLE DATA; Schema: public; Owner: lemmy
--

COPY public.mod_feature_post (id, mod_person_id, post_id, featured, when_, is_featured_community) FROM stdin;
\.


--
-- Data for Name: mod_hide_community; Type: TABLE DATA; Schema: public; Owner: lemmy
--

COPY public.mod_hide_community (id, community_id, mod_person_id, when_, reason, hidden) FROM stdin;
\.


--
-- Data for Name: mod_lock_post; Type: TABLE DATA; Schema: public; Owner: lemmy
--

COPY public.mod_lock_post (id, mod_person_id, post_id, locked, when_) FROM stdin;
\.


--
-- Data for Name: mod_remove_comment; Type: TABLE DATA; Schema: public; Owner: lemmy
--

COPY public.mod_remove_comment (id, mod_person_id, comment_id, reason, removed, when_) FROM stdin;
\.


--
-- Data for Name: mod_remove_community; Type: TABLE DATA; Schema: public; Owner: lemmy
--

COPY public.mod_remove_community (id, mod_person_id, community_id, reason, removed, when_) FROM stdin;
\.


--
-- Data for Name: mod_remove_post; Type: TABLE DATA; Schema: public; Owner: lemmy
--

COPY public.mod_remove_post (id, mod_person_id, post_id, reason, removed, when_) FROM stdin;
\.


--
-- Data for Name: mod_transfer_community; Type: TABLE DATA; Schema: public; Owner: lemmy
--

COPY public.mod_transfer_community (id, mod_person_id, other_person_id, community_id, when_) FROM stdin;
\.


--
-- Data for Name: password_reset_request; Type: TABLE DATA; Schema: public; Owner: lemmy
--

COPY public.password_reset_request (id, token, published, local_user_id) FROM stdin;
\.


--
-- Data for Name: person; Type: TABLE DATA; Schema: public; Owner: lemmy
--

COPY public.person (id, name, display_name, avatar, banned, published, updated, actor_id, bio, local, private_key, public_key, last_refreshed_at, banner, deleted, inbox_url, shared_inbox_url, matrix_user_id, bot_account, ban_expires, instance_id) FROM stdin;
2	admin	\N	\N	f	2025-05-08 04:34:32.81473+00	\N	https://localhost/u/admin	\N	t	-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDY26dP5SIhfDxJ\n+BmoksyvlOb6Bt0X8VfN5A+wB09XxFxCZEe93HJj8xsuQK/tr5L2POH5uoYZ6SIz\n0gsXfvjSfcnpj3eWkFnPNvBbG2U+sLoeoqc3tQN0Mn3BYe6usQx5BXRNREdTVqu9\n+1yg4hxR/s2tUwzPqUjN6zvz74Rjmw3XKYKn3pcLezAbURsnJWmSsaFvNTKbe88b\nB2Z+4TP/W8/g3NGbfR5od2sT2YC34UTBcQOYdJlJmyQC79cSLB32KovjUCx1/Ei1\nnL6qHbZtHWX1WYaVozQH3I1bMr4aGjjfMUYwqXDTmYcF/0TFi9QTA0ByzsjJBj58\nbRTeuK/BAgMBAAECggEAF8IY1nv3/UsrH796sClFG4dotsPBvTnHsNrnjRV/79Gn\nee6anYZlUeX0eGDF5Xhy1V9eMono3zXXdW3xoSVcBVOap2f8ZhZygG04cALUWMXr\n3idbwpKmSjit5l3gVGs5PpkGYOC2H79DGZFMWKPtDl6oEfEjWizluQmoi9UV4AON\nHhIIoDeOhOnBUh2bfJPurRc3c/HlCWmbQUqVy8r93Z8QnmVDdcXL+Oyse7+JvlR/\n7YoFQdw4hMQTBrq3sU71EDbAPZV0UXQV2iAqCQ6Wr9nHxL0kfgQpniwSppv3XGXY\ntuAITtZ0Fk067OlvUtj9UgfF/plV7KdODCAaBE2/8QKBgQDksKb9o5feKl87Xde3\nLsZuVhHUnucHNKQBbpY7eubYOVRtMXlz8ScyRorTwb3G595yLdG+xaM72l75UFGQ\nBp2+WGksU748FLdNFJWlTkaDyg6IoYFuo3Dcj7HftLWEm+V5d4/bHFz+OAfkOHPM\nScH+YBBOjpIC9IUoUrBjQuoNcwKBgQDywUfzLjMV/g0LR0ghShywwOgWk8l/20SY\n8bBhaTV8aUsxJPswNFhtY+73JS7IlAgE2SaDlHDewROrqtrN0Y8AhPJGcrNi8QOw\nP2elXdClgBmTE32hLMoZxmdnh3KZv1bvugmPDzVhwHXIF7GKlgTfbpiGIU1MP5Eb\nLMxOMGyA+wKBgQDgGfQqjYufHGqiJH3ldqLhMNrcPrMqrn0hIht6Qh/BN7zyHA9m\nfKTqcZJNnIe6STIFNb1acxZY6s8zBXBH8RPXmY/G7nF3Mt3FXSygByq2ruS7I3lQ\n0D0jBnVKQS23u4WOGIoSL6M5Q/MHxAJF6Ol/uud/89pFpxRtxUowmzv83QKBgFBS\nvfDsJ4EuZ7iEpIxHToj5u5HE4taIggEtb5Q70LPSz0t6lhbUKzI+79IdHobF3IVm\nKMU+973tGwohZXbW0T91vgiraUniv7qwsCXajfBFG7E7sMUE4fZ3XL235qaS1jxK\nTWFlwd8PZKmJlXhqvUAFAzjWihIhsmzQfOWeRjjDAoGBAKsFmgHyfwoIdaOUbv2K\nIdOPtYFno6RLMYlwF7mk4iFIBLnBtOErb+n5kNbfolCFpwtmN6jZSj/ke0bZ1y7u\nTN4dGkNTNFPr+Mg2A5vf8WaHsC+xlGAwpJtEJUEGXrYowrySW+9I1R2NhDUbVHJn\nHmmxvc6G3b6gthv4VwTFH+nU\n-----END PRIVATE KEY-----\n	-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA2NunT+UiIXw8SfgZqJLM\nr5Tm+gbdF/FXzeQPsAdPV8RcQmRHvdxyY/MbLkCv7a+S9jzh+bqGGekiM9ILF374\n0n3J6Y93lpBZzzbwWxtlPrC6HqKnN7UDdDJ9wWHurrEMeQV0TURHU1arvftcoOIc\nUf7NrVMMz6lIzes78++EY5sN1ymCp96XC3swG1EbJyVpkrGhbzUym3vPGwdmfuEz\n/1vP4NzRm30eaHdrE9mAt+FEwXEDmHSZSZskAu/XEiwd9iqL41AsdfxItZy+qh22\nbR1l9VmGlaM0B9yNWzK+Gho43zFGMKlw05mHBf9ExYvUEwNAcs7IyQY+fG0U3riv\nwQIDAQAB\n-----END PUBLIC KEY-----\n	2025-05-08 04:34:32.81473+00	\N	f	https://localhost/u/admin/inbox	https://localhost/inbox	\N	f	\N	1
\.


--
-- Data for Name: person_aggregates; Type: TABLE DATA; Schema: public; Owner: lemmy
--

COPY public.person_aggregates (person_id, post_count, post_score, comment_count, comment_score) FROM stdin;
2	1	1	1	1
\.


--
-- Data for Name: person_ban; Type: TABLE DATA; Schema: public; Owner: lemmy
--

COPY public.person_ban (person_id, published) FROM stdin;
\.


--
-- Data for Name: person_block; Type: TABLE DATA; Schema: public; Owner: lemmy
--

COPY public.person_block (person_id, target_id, published) FROM stdin;
\.


--
-- Data for Name: person_follower; Type: TABLE DATA; Schema: public; Owner: lemmy
--

COPY public.person_follower (person_id, follower_id, published, pending) FROM stdin;
\.


--
-- Data for Name: person_mention; Type: TABLE DATA; Schema: public; Owner: lemmy
--

COPY public.person_mention (id, recipient_id, comment_id, read, published) FROM stdin;
\.


--
-- Data for Name: person_post_aggregates; Type: TABLE DATA; Schema: public; Owner: lemmy
--

COPY public.person_post_aggregates (person_id, post_id, read_comments, published) FROM stdin;
2	1	1	2025-05-08 04:47:35.25607+00
\.


--
-- Data for Name: post; Type: TABLE DATA; Schema: public; Owner: lemmy
--

COPY public.post (id, name, url, body, creator_id, community_id, removed, locked, published, updated, deleted, nsfw, embed_title, embed_description, thumbnail_url, ap_id, local, embed_video_url, language_id, featured_community, featured_local, url_content_type, alt_text) FROM stdin;
1	Jython vs python ?	\N	Help me understand the difference between Python and the Jython (JVM Python) implementation ? which is faster ?	2	2	f	f	2025-05-08 04:47:35.011815+00	\N	f	f	\N	\N	\N	https://localhost/post/1	t	\N	0	f	f	\N	\N
\.


--
-- Data for Name: post_aggregates; Type: TABLE DATA; Schema: public; Owner: lemmy
--

COPY public.post_aggregates (post_id, comments, score, upvotes, downvotes, published, newest_comment_time_necro, newest_comment_time, featured_community, featured_local, hot_rank, hot_rank_active, community_id, creator_id, controversy_rank, instance_id, scaled_rank) FROM stdin;
1	1	1	1	0	2025-05-08 04:47:35.011815+00	2025-05-08 04:47:35.011815+00	2025-05-08 04:51:54.970633+00	f	f	0.000727771754278362	0.000727771754278362	2	2	0	1	0.0015253392027273485
\.


--
-- Data for Name: post_hide; Type: TABLE DATA; Schema: public; Owner: lemmy
--

COPY public.post_hide (post_id, person_id, published) FROM stdin;
\.


--
-- Data for Name: post_like; Type: TABLE DATA; Schema: public; Owner: lemmy
--

COPY public.post_like (post_id, person_id, score, published) FROM stdin;
1	2	1	2025-05-08 04:47:35.045824+00
\.


--
-- Data for Name: post_read; Type: TABLE DATA; Schema: public; Owner: lemmy
--

COPY public.post_read (post_id, person_id, published) FROM stdin;
1	2	2025-05-08 04:47:35.054287+00
\.


--
-- Data for Name: post_report; Type: TABLE DATA; Schema: public; Owner: lemmy
--

COPY public.post_report (id, creator_id, post_id, original_post_name, original_post_url, original_post_body, reason, resolved, resolver_id, published, updated) FROM stdin;
\.


--
-- Data for Name: post_saved; Type: TABLE DATA; Schema: public; Owner: lemmy
--

COPY public.post_saved (post_id, person_id, published) FROM stdin;
\.


--
-- Data for Name: private_message; Type: TABLE DATA; Schema: public; Owner: lemmy
--

COPY public.private_message (id, creator_id, recipient_id, content, deleted, read, published, updated, ap_id, local, removed) FROM stdin;
\.


--
-- Data for Name: private_message_report; Type: TABLE DATA; Schema: public; Owner: lemmy
--

COPY public.private_message_report (id, creator_id, private_message_id, original_pm_text, reason, resolved, resolver_id, published, updated) FROM stdin;
\.


--
-- Data for Name: received_activity; Type: TABLE DATA; Schema: public; Owner: lemmy
--

COPY public.received_activity (ap_id, published) FROM stdin;
\.


--
-- Data for Name: registration_application; Type: TABLE DATA; Schema: public; Owner: lemmy
--

COPY public.registration_application (id, local_user_id, answer, admin_id, deny_reason, published) FROM stdin;
\.


--
-- Data for Name: remote_image; Type: TABLE DATA; Schema: public; Owner: lemmy
--

COPY public.remote_image (link, published) FROM stdin;
\.


--
-- Data for Name: secret; Type: TABLE DATA; Schema: public; Owner: lemmy
--

COPY public.secret (id, jwt_secret) FROM stdin;
1	e9cc7a4e-27b4-4fc7-a39a-e5efc905352d
\.


--
-- Data for Name: sent_activity; Type: TABLE DATA; Schema: public; Owner: lemmy
--

COPY public.sent_activity (id, ap_id, data, sensitive, published, send_inboxes, send_community_followers_of, send_all_instances, actor_type, actor_apub_id) FROM stdin;
1	https://localhost/activities/announce/create/e878ff82-7ee6-4b78-b0ea-6c783268b968	{"actor":"https://localhost/c/python_official","to":["https://www.w3.org/ns/activitystreams#Public"],"object":{"id":"https://localhost/activities/create/75cb237a-d0ce-4627-8be6-d747eba34103","actor":"https://localhost/u/admin","to":["https://www.w3.org/ns/activitystreams#Public"],"object":{"type":"Page","id":"https://localhost/post/1","attributedTo":"https://localhost/u/admin","to":["https://localhost/c/python_official","https://www.w3.org/ns/activitystreams#Public"],"name":"Jython vs python ?","cc":[],"content":"<p>Help me understand the difference between Python and the Jython (JVM Python) implementation ? which is faster ?</p>\\n","mediaType":"text/html","source":{"content":"Help me understand the difference between Python and the Jython (JVM Python) implementation ? which is faster ?","mediaType":"text/markdown"},"attachment":[],"sensitive":false,"published":"2025-05-08T04:47:35.011815Z","audience":"https://localhost/c/python_official","tag":[{"href":"https://localhost/post/1","name":"#python_official","type":"Hashtag"}]},"cc":["https://localhost/c/python_official"],"type":"Create","audience":"https://localhost/c/python_official"},"cc":["https://localhost/c/python_official/followers"],"type":"Announce","id":"https://localhost/activities/announce/create/e878ff82-7ee6-4b78-b0ea-6c783268b968"}	f	2025-05-08 04:47:35.061879+00	{}	2	f	community	https://localhost/c/python_official
2	https://localhost/activities/announce/page/f024f2e6-e40a-418c-b627-7480f2631d1f	{"actor":"https://localhost/c/python_official","to":["https://www.w3.org/ns/activitystreams#Public"],"object":{"id":"https://localhost/post/1","actor":"https://localhost/u/admin","type":"Page","attributedTo":"https://localhost/u/admin","to":["https://localhost/c/python_official","https://www.w3.org/ns/activitystreams#Public"],"name":"Jython vs python ?","cc":[],"content":"<p>Help me understand the difference between Python and the Jython (JVM Python) implementation ? which is faster ?</p>\\n","mediaType":"text/html","source":{"content":"Help me understand the difference between Python and the Jython (JVM Python) implementation ? which is faster ?","mediaType":"text/markdown"},"attachment":[],"sensitive":false,"published":"2025-05-08T04:47:35.011815Z","audience":"https://localhost/c/python_official","tag":[{"href":"https://localhost/post/1","name":"#python_official","type":"Hashtag"}]},"cc":["https://localhost/c/python_official/followers"],"type":"Announce","id":"https://localhost/activities/announce/page/f024f2e6-e40a-418c-b627-7480f2631d1f"}	f	2025-05-08 04:47:35.068124+00	{}	2	f	community	https://localhost/c/python_official
3	https://localhost/activities/create/75cb237a-d0ce-4627-8be6-d747eba34103	{"actor":"https://localhost/u/admin","to":["https://www.w3.org/ns/activitystreams#Public"],"object":{"type":"Page","id":"https://localhost/post/1","attributedTo":"https://localhost/u/admin","to":["https://localhost/c/python_official","https://www.w3.org/ns/activitystreams#Public"],"name":"Jython vs python ?","cc":[],"content":"<p>Help me understand the difference between Python and the Jython (JVM Python) implementation ? which is faster ?</p>\\n","mediaType":"text/html","source":{"content":"Help me understand the difference between Python and the Jython (JVM Python) implementation ? which is faster ?","mediaType":"text/markdown"},"attachment":[],"sensitive":false,"published":"2025-05-08T04:47:35.011815Z","audience":"https://localhost/c/python_official","tag":[{"href":"https://localhost/post/1","name":"#python_official","type":"Hashtag"}]},"cc":["https://localhost/c/python_official"],"type":"Create","id":"https://localhost/activities/create/75cb237a-d0ce-4627-8be6-d747eba34103","audience":"https://localhost/c/python_official"}	f	2025-05-08 04:47:35.073196+00	{}	\N	f	person	https://localhost/u/admin
4	https://localhost/activities/announce/create/b5893ae0-ccf1-4674-b091-fbd96436cb1f	{"actor":"https://localhost/c/python_official","to":["https://www.w3.org/ns/activitystreams#Public"],"object":{"id":"https://localhost/activities/create/b5ed0805-eb44-4618-a6d9-4fb3dd0cc09f","actor":"https://localhost/u/admin","to":["https://www.w3.org/ns/activitystreams#Public"],"object":{"type":"Note","id":"https://localhost/comment/1","attributedTo":"https://localhost/u/admin","to":["https://www.w3.org/ns/activitystreams#Public"],"cc":["https://localhost/c/python_official","https://localhost/u/admin"],"content":"<p>Jython is the implementation of Python in Java it is not meant to be fast , the only benefit of using it over python is to have access to the <strong>JVM</strong> and the <strong>Java Classes</strong> (Like <strong>Kotlin</strong> does) so you don’t need an API to do that\\nAlso the JVM is usually slower than the <strong>JIT</strong> compiler on a lot of cases</p>\\n<p>If you want a flexible language and want to still access the JVM using modern JVM based languages instead</p>\\n","inReplyTo":"https://localhost/post/1","mediaType":"text/html","source":{"content":"Jython is the implementation of Python in Java it is not meant to be fast , the only benefit of using it over python is to have access to the **JVM** and the **Java Classes** (Like **Kotlin** does) so you don't need an API to do that\\nAlso the JVM is usually slower than the **JIT** compiler on a lot of cases\\n\\nIf you want a flexible language and want to still access the JVM using modern JVM based languages instead","mediaType":"text/markdown"},"published":"2025-05-08T04:51:54.970633Z","tag":[{"href":"https://localhost/u/admin","name":"@admin@localhost","type":"Mention"}],"distinguished":false,"audience":"https://localhost/c/python_official","attachment":[]},"cc":["https://localhost/c/python_official","https://localhost/u/admin"],"tag":[{"href":"https://localhost/u/admin","name":"@admin@localhost","type":"Mention"}],"type":"Create","audience":"https://localhost/c/python_official"},"cc":["https://localhost/c/python_official/followers"],"type":"Announce","id":"https://localhost/activities/announce/create/b5893ae0-ccf1-4674-b091-fbd96436cb1f"}	f	2025-05-08 04:51:55.06962+00	{}	2	f	community	https://localhost/c/python_official
5	https://localhost/activities/create/b5ed0805-eb44-4618-a6d9-4fb3dd0cc09f	{"actor":"https://localhost/u/admin","to":["https://www.w3.org/ns/activitystreams#Public"],"object":{"type":"Note","id":"https://localhost/comment/1","attributedTo":"https://localhost/u/admin","to":["https://www.w3.org/ns/activitystreams#Public"],"cc":["https://localhost/c/python_official","https://localhost/u/admin"],"content":"<p>Jython is the implementation of Python in Java it is not meant to be fast , the only benefit of using it over python is to have access to the <strong>JVM</strong> and the <strong>Java Classes</strong> (Like <strong>Kotlin</strong> does) so you don’t need an API to do that\\nAlso the JVM is usually slower than the <strong>JIT</strong> compiler on a lot of cases</p>\\n<p>If you want a flexible language and want to still access the JVM using modern JVM based languages instead</p>\\n","inReplyTo":"https://localhost/post/1","mediaType":"text/html","source":{"content":"Jython is the implementation of Python in Java it is not meant to be fast , the only benefit of using it over python is to have access to the **JVM** and the **Java Classes** (Like **Kotlin** does) so you don't need an API to do that\\nAlso the JVM is usually slower than the **JIT** compiler on a lot of cases\\n\\nIf you want a flexible language and want to still access the JVM using modern JVM based languages instead","mediaType":"text/markdown"},"published":"2025-05-08T04:51:54.970633Z","tag":[{"href":"https://localhost/u/admin","name":"@admin@localhost","type":"Mention"}],"distinguished":false,"audience":"https://localhost/c/python_official","attachment":[]},"cc":["https://localhost/c/python_official","https://localhost/u/admin"],"tag":[{"href":"https://localhost/u/admin","name":"@admin@localhost","type":"Mention"}],"type":"Create","id":"https://localhost/activities/create/b5ed0805-eb44-4618-a6d9-4fb3dd0cc09f","audience":"https://localhost/c/python_official"}	f	2025-05-08 04:51:55.072435+00	{https://localhost/inbox}	\N	f	person	https://localhost/u/admin
6	https://localhost/activities/announce/update/48ae93a4-2a31-4b23-b049-c80af3312c3b	{"actor":"https://localhost/c/python_official","to":["https://www.w3.org/ns/activitystreams#Public"],"object":{"id":"https://localhost/activities/update/9bafe802-1c4a-4146-8ae7-c88b35b77f6a","actor":"https://localhost/u/admin","to":["https://www.w3.org/ns/activitystreams#Public"],"object":{"type":"Group","id":"https://localhost/c/python_official","preferredUsername":"python_official","inbox":"https://localhost/c/python_official/inbox","followers":"https://localhost/c/python_official/followers","publicKey":{"id":"https://localhost/c/python_official#main-key","owner":"https://localhost/c/python_official","publicKeyPem":"-----BEGIN PUBLIC KEY-----\\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA5SSoG0qCRew8C1pVF7hG\\nuE/OQOmz+zdhkNVVgUbVOF80rxH9daw9q/9TgFoD5i4dTDixAyim9Qt+Utcas5QY\\naA7bHyojK/yLDgyRcza0qWuPKf9pVqfELV4SpdylM/j7zU4buJYkRg1L8VjOkNjT\\nojgrmRC81p6O5vRzTglccmiif0Qn60ke5WJ1RGENbs4bgoI65KztE7nn2dNjHdVC\\nklJIf8EGzaP6tFPG9Fylp06mmFTiKqF1T5UYaksJkowMrF9bV+bvZFdQg/Ijkzqc\\n2OfkL4pgOouR+36gvqKIyqsGDcD0g7TDUqcVW1ODVEeT2Ku8fPZX67QAE6wWS/6z\\nMwIDAQAB\\n-----END PUBLIC KEY-----\\n"},"name":"Python","summary":"<p>Official Python community</p>\\n","source":{"content":"Official Python community","mediaType":"text/markdown"},"icon":{"type":"Image","url":"http://127.0.0.1:10633/pictrs/image/3d7586eb-a0b2-4fbc-ae83-a5d891d93214.jpeg"},"image":{"type":"Image","url":"http://127.0.0.1:10633/pictrs/image/7e46cfee-8fc8-4f19-ad49-f2eb6f89c1cf.jpeg"},"sensitive":false,"attributedTo":"https://localhost/c/python_official/moderators","postingRestrictedToMods":false,"outbox":"https://localhost/c/python_official/outbox","endpoints":{"sharedInbox":"https://localhost/inbox"},"featured":"https://localhost/c/python_official/featured","language":[],"published":"2025-05-08T04:46:20.505514Z","updated":"2025-05-09T09:50:19.430673Z"},"cc":["https://localhost/c/python_official"],"type":"Update","audience":"https://localhost/c/python_official"},"cc":["https://localhost/c/python_official/followers"],"type":"Announce","id":"https://localhost/activities/announce/update/48ae93a4-2a31-4b23-b049-c80af3312c3b"}	f	2025-05-09 09:50:19.440316+00	{}	2	f	community	https://localhost/c/python_official
7	https://localhost/activities/update/9bafe802-1c4a-4146-8ae7-c88b35b77f6a	{"actor":"https://localhost/u/admin","to":["https://www.w3.org/ns/activitystreams#Public"],"object":{"type":"Group","id":"https://localhost/c/python_official","preferredUsername":"python_official","inbox":"https://localhost/c/python_official/inbox","followers":"https://localhost/c/python_official/followers","publicKey":{"id":"https://localhost/c/python_official#main-key","owner":"https://localhost/c/python_official","publicKeyPem":"-----BEGIN PUBLIC KEY-----\\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA5SSoG0qCRew8C1pVF7hG\\nuE/OQOmz+zdhkNVVgUbVOF80rxH9daw9q/9TgFoD5i4dTDixAyim9Qt+Utcas5QY\\naA7bHyojK/yLDgyRcza0qWuPKf9pVqfELV4SpdylM/j7zU4buJYkRg1L8VjOkNjT\\nojgrmRC81p6O5vRzTglccmiif0Qn60ke5WJ1RGENbs4bgoI65KztE7nn2dNjHdVC\\nklJIf8EGzaP6tFPG9Fylp06mmFTiKqF1T5UYaksJkowMrF9bV+bvZFdQg/Ijkzqc\\n2OfkL4pgOouR+36gvqKIyqsGDcD0g7TDUqcVW1ODVEeT2Ku8fPZX67QAE6wWS/6z\\nMwIDAQAB\\n-----END PUBLIC KEY-----\\n"},"name":"Python","summary":"<p>Official Python community</p>\\n","source":{"content":"Official Python community","mediaType":"text/markdown"},"icon":{"type":"Image","url":"http://127.0.0.1:10633/pictrs/image/3d7586eb-a0b2-4fbc-ae83-a5d891d93214.jpeg"},"image":{"type":"Image","url":"http://127.0.0.1:10633/pictrs/image/7e46cfee-8fc8-4f19-ad49-f2eb6f89c1cf.jpeg"},"sensitive":false,"attributedTo":"https://localhost/c/python_official/moderators","postingRestrictedToMods":false,"outbox":"https://localhost/c/python_official/outbox","endpoints":{"sharedInbox":"https://localhost/inbox"},"featured":"https://localhost/c/python_official/featured","language":[],"published":"2025-05-08T04:46:20.505514Z","updated":"2025-05-09T09:50:19.430673Z"},"cc":["https://localhost/c/python_official"],"type":"Update","id":"https://localhost/activities/update/9bafe802-1c4a-4146-8ae7-c88b35b77f6a","audience":"https://localhost/c/python_official"}	f	2025-05-09 09:50:19.443704+00	{}	\N	f	person	https://localhost/u/admin
\.


--
-- Data for Name: site; Type: TABLE DATA; Schema: public; Owner: lemmy
--

COPY public.site (id, name, sidebar, published, updated, icon, banner, description, actor_id, last_refreshed_at, inbox_url, private_key, public_key, instance_id, content_warning) FROM stdin;
1	Taalomi	**Welcome to Taalomi !**\n\nthe social networking community-based platform solely for Learners where we share knowledge, resources and learning in a distraction-free environment	2025-05-08 04:33:58.393769+00	2025-05-09 09:49:26.453865+00	http://127.0.0.1:10633/pictrs/image/bc3ae7d3-8c1b-44bd-a171-6ccf95f4b563.png	http://127.0.0.1:10633/pictrs/image/30d45bde-5ec6-4304-a50d-9337692f0ac5.png	Taalomi were we Learn, Share and Thrive Together !	https://localhost/	2025-05-08 04:44:18.556897+00	https://localhost/inbox	-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDjiFnNhZJAwQ7h\no6hOKOYz+lAkQjxfb+99KLoOO4uQf+jddsMEhLYDoXOna8wamZyPcKtmbrDbY6uS\nsvEE7vW81yjiS9wk3FWzo5ezDu6O2AqQouZxehq6Kb9Cv5i96lDDu9F52ZG/auNe\nUwl0RBGjL/Y1h7syzLotKbAx8d3YcE8/bjb3u2kae4tOTxeOmssoMwWIQ3fkfKvD\n9Fhjzkewy6IoLdEYOPa6/rz4Gx6k0+olFDfUo2uMyytmCnL0C/IQa4n//Y1Zf0Dh\n3uhcdnFdHbSREKKQg2wn+8N3Fyzqhupo0P2XHxmbTND7ryrrHi8zI+f318PV0T7K\nNcFzTtXvAgMBAAECggEBALOZxmEPRUGt4mRDfa+sYwG2XRox2lvvDFh8FFj1sZWv\nEY32l7tyUgYNpDAMTADXLhifc/wX9axHQYA7lToysXCNWa0++hdygIea4zyo1a+V\nYsmGfGYoXv6Bw4IZoKSQV44ZLCGFlqFE6xJiczz+Gfn4+tyINkDED1Vk6bqS021q\nxBu6ktoEpgUnZw0GDDYcxUlTqvOPmpfC6ETxBnXdnEqk+2zKungfT0pZxyAvEuxH\nbT5p7QYLaLua8Vist1bqo4HyvZJXUN6LT8kT2L/VTyhb/H7FpMp8WWelOdWAnFkP\nu0A/Py5aMeodxde8rIyyYabJUqaeEQEg1Rc7cL8LfukCgYEA+4ni2qSDvHdIkYFD\ndJ/bs/wkQxELiCOjT3BKciOe1XyCy/S4A630rORfhp3nFh73cP7N+8FVY9UTXY47\n1Qe7uki7HNjUNhbUV2HzJ6D2fAW811TTbyQjVBf40rfhmYbyoVb5Ng9zKHl+h9g3\naAB+KHo5xUbWnA3R3QIWTHyiPCsCgYEA55F3E/4GBiuA3fATn1lWCbxn5NF6yFIJ\nK29EFBIxJc4oRip7hZNuUgj5cG4ispKRVHc73ra8146bIbXKIiD6LtwPx6TiF/4G\nDN2vcHJZJBfWLuZKLa/rTkZ7wAYJmPuMOjlJTMjz5jk/zbiRoviQ3J4/DXoLwJw6\nM2rRYbiAt00CgYA7VGCftaIk9/Wz7Ete3L3TjCt5bjHMIKvKdu/4UBKMxFuNg+FL\nbOKDTTKC7Aevngo7Kr6nHQjpDT8OGBhgvPw4iiMoQLR9NZFMMxxJQpwg0LGkEKv2\nUQ3MLgNQoHKj5cKg74TEjYxaBZ4kqIkZDNS0829g6r5//Hp9qJpd3B/gFQKBgBNy\npA2Jx/e8r5X0E7HOTuuCZzdQYH9yZFLBhXYqEPab2cYKy1TsjNdW6ZwHo+JbbNkr\nKlwJ/NIdp+ms2s0C9//3e1vI/TQGoXtzIsjO0a22UsadkJ1FqP1p7fqyhxvSBHTf\nWsiYF+O96x3b4l9NgN0GbUU0esgyVrD6x5rtY+IBAoGBANSnQRM2nqs3Px7NIT4J\nAN5sdr1vVurYfSUb9jknipJ7WRefnLzM+YCJMcmwn83mOXb8FmRPiEHLOnV83cNZ\nbXaDgrRKh9htUc/ChaSRV4lgYU7H1qbJkZ7vWqx0YmwsAs7kPa75MGg3somERMKj\naZ7u8moA8zb45WqC993nWoW+\n-----END PRIVATE KEY-----\n	-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA44hZzYWSQMEO4aOoTijm\nM/pQJEI8X2/vfSi6DjuLkH/o3XbDBIS2A6Fzp2vMGpmcj3CrZm6w22OrkrLxBO71\nvNco4kvcJNxVs6OXsw7ujtgKkKLmcXoauim/Qr+YvepQw7vRedmRv2rjXlMJdEQR\noy/2NYe7Msy6LSmwMfHd2HBPP24297tpGnuLTk8XjprLKDMFiEN35Hyrw/RYY85H\nsMuiKC3RGDj2uv68+BsepNPqJRQ31KNrjMsrZgpy9AvyEGuJ//2NWX9A4d7oXHZx\nXR20kRCikINsJ/vDdxcs6obqaND9lx8Zm0zQ+68q6x4vMyPn99fD1dE+yjXBc07V\n7wIDAQAB\n-----END PUBLIC KEY-----\n	1	\N
\.


--
-- Data for Name: site_aggregates; Type: TABLE DATA; Schema: public; Owner: lemmy
--

COPY public.site_aggregates (site_id, users, posts, comments, communities, users_active_day, users_active_week, users_active_month, users_active_half_year) FROM stdin;
1	2	1	1	1	0	1	1	1
\.


--
-- Data for Name: site_language; Type: TABLE DATA; Schema: public; Owner: lemmy
--

COPY public.site_language (site_id, language_id) FROM stdin;
1	0
1	1
1	2
1	3
1	4
1	5
1	6
1	7
1	8
1	9
1	10
1	11
1	12
1	13
1	14
1	15
1	16
1	17
1	18
1	19
1	20
1	21
1	22
1	23
1	24
1	25
1	26
1	27
1	28
1	29
1	30
1	31
1	32
1	33
1	34
1	35
1	36
1	37
1	38
1	39
1	40
1	41
1	42
1	43
1	44
1	45
1	46
1	47
1	48
1	49
1	50
1	51
1	52
1	53
1	54
1	55
1	56
1	57
1	58
1	59
1	60
1	61
1	62
1	63
1	64
1	65
1	66
1	67
1	68
1	69
1	70
1	71
1	72
1	73
1	74
1	75
1	76
1	77
1	78
1	79
1	80
1	81
1	82
1	83
1	84
1	85
1	86
1	87
1	88
1	89
1	90
1	91
1	92
1	93
1	94
1	95
1	96
1	97
1	98
1	99
1	100
1	101
1	102
1	103
1	104
1	105
1	106
1	107
1	108
1	109
1	110
1	111
1	112
1	113
1	114
1	115
1	116
1	117
1	118
1	119
1	120
1	121
1	122
1	123
1	124
1	125
1	126
1	127
1	128
1	129
1	130
1	131
1	132
1	133
1	134
1	135
1	136
1	137
1	138
1	139
1	140
1	141
1	142
1	143
1	144
1	145
1	146
1	147
1	148
1	149
1	150
1	151
1	152
1	153
1	154
1	155
1	156
1	157
1	158
1	159
1	160
1	161
1	162
1	163
1	164
1	165
1	166
1	167
1	168
1	169
1	170
1	171
1	172
1	173
1	174
1	175
1	176
1	177
1	178
1	179
1	180
1	181
1	182
1	183
\.


--
-- Data for Name: tagline; Type: TABLE DATA; Schema: public; Owner: lemmy
--

COPY public.tagline (id, local_site_id, content, published, updated) FROM stdin;
\.


--
-- Data for Name: deps_saved_ddl; Type: TABLE DATA; Schema: utils; Owner: lemmy
--

COPY utils.deps_saved_ddl (id, view_schema, view_name, ddl_to_run) FROM stdin;
\.


--
-- Name: admin_purge_comment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: lemmy
--

SELECT pg_catalog.setval('public.admin_purge_comment_id_seq', 1, false);


--
-- Name: admin_purge_community_id_seq; Type: SEQUENCE SET; Schema: public; Owner: lemmy
--

SELECT pg_catalog.setval('public.admin_purge_community_id_seq', 1, false);


--
-- Name: admin_purge_person_id_seq; Type: SEQUENCE SET; Schema: public; Owner: lemmy
--

SELECT pg_catalog.setval('public.admin_purge_person_id_seq', 1, false);


--
-- Name: admin_purge_post_id_seq; Type: SEQUENCE SET; Schema: public; Owner: lemmy
--

SELECT pg_catalog.setval('public.admin_purge_post_id_seq', 1, false);


--
-- Name: changeme_seq; Type: SEQUENCE SET; Schema: public; Owner: lemmy
--

SELECT pg_catalog.setval('public.changeme_seq', 1, false);


--
-- Name: comment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: lemmy
--

SELECT pg_catalog.setval('public.comment_id_seq', 1, true);


--
-- Name: comment_reply_id_seq; Type: SEQUENCE SET; Schema: public; Owner: lemmy
--

SELECT pg_catalog.setval('public.comment_reply_id_seq', 1, false);


--
-- Name: comment_report_id_seq; Type: SEQUENCE SET; Schema: public; Owner: lemmy
--

SELECT pg_catalog.setval('public.comment_report_id_seq', 1, false);


--
-- Name: community_id_seq; Type: SEQUENCE SET; Schema: public; Owner: lemmy
--

SELECT pg_catalog.setval('public.community_id_seq', 2, true);


--
-- Name: custom_emoji_id_seq; Type: SEQUENCE SET; Schema: public; Owner: lemmy
--

SELECT pg_catalog.setval('public.custom_emoji_id_seq', 1, false);


--
-- Name: email_verification_id_seq; Type: SEQUENCE SET; Schema: public; Owner: lemmy
--

SELECT pg_catalog.setval('public.email_verification_id_seq', 1, false);


--
-- Name: instance_id_seq; Type: SEQUENCE SET; Schema: public; Owner: lemmy
--

SELECT pg_catalog.setval('public.instance_id_seq', 1, true);


--
-- Name: language_id_seq; Type: SEQUENCE SET; Schema: public; Owner: lemmy
--

SELECT pg_catalog.setval('public.language_id_seq', 183, true);


--
-- Name: local_site_id_seq; Type: SEQUENCE SET; Schema: public; Owner: lemmy
--

SELECT pg_catalog.setval('public.local_site_id_seq', 1, true);


--
-- Name: local_site_url_blocklist_id_seq; Type: SEQUENCE SET; Schema: public; Owner: lemmy
--

SELECT pg_catalog.setval('public.local_site_url_blocklist_id_seq', 1, false);


--
-- Name: local_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: lemmy
--

SELECT pg_catalog.setval('public.local_user_id_seq', 1, true);


--
-- Name: mod_add_community_id_seq; Type: SEQUENCE SET; Schema: public; Owner: lemmy
--

SELECT pg_catalog.setval('public.mod_add_community_id_seq', 1, false);


--
-- Name: mod_add_id_seq; Type: SEQUENCE SET; Schema: public; Owner: lemmy
--

SELECT pg_catalog.setval('public.mod_add_id_seq', 1, false);


--
-- Name: mod_ban_from_community_id_seq; Type: SEQUENCE SET; Schema: public; Owner: lemmy
--

SELECT pg_catalog.setval('public.mod_ban_from_community_id_seq', 1, false);


--
-- Name: mod_ban_id_seq; Type: SEQUENCE SET; Schema: public; Owner: lemmy
--

SELECT pg_catalog.setval('public.mod_ban_id_seq', 1, false);


--
-- Name: mod_hide_community_id_seq; Type: SEQUENCE SET; Schema: public; Owner: lemmy
--

SELECT pg_catalog.setval('public.mod_hide_community_id_seq', 1, false);


--
-- Name: mod_lock_post_id_seq; Type: SEQUENCE SET; Schema: public; Owner: lemmy
--

SELECT pg_catalog.setval('public.mod_lock_post_id_seq', 1, false);


--
-- Name: mod_remove_comment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: lemmy
--

SELECT pg_catalog.setval('public.mod_remove_comment_id_seq', 1, false);


--
-- Name: mod_remove_community_id_seq; Type: SEQUENCE SET; Schema: public; Owner: lemmy
--

SELECT pg_catalog.setval('public.mod_remove_community_id_seq', 1, false);


--
-- Name: mod_remove_post_id_seq; Type: SEQUENCE SET; Schema: public; Owner: lemmy
--

SELECT pg_catalog.setval('public.mod_remove_post_id_seq', 1, false);


--
-- Name: mod_sticky_post_id_seq; Type: SEQUENCE SET; Schema: public; Owner: lemmy
--

SELECT pg_catalog.setval('public.mod_sticky_post_id_seq', 1, false);


--
-- Name: mod_transfer_community_id_seq; Type: SEQUENCE SET; Schema: public; Owner: lemmy
--

SELECT pg_catalog.setval('public.mod_transfer_community_id_seq', 1, false);


--
-- Name: password_reset_request_id_seq; Type: SEQUENCE SET; Schema: public; Owner: lemmy
--

SELECT pg_catalog.setval('public.password_reset_request_id_seq', 1, false);


--
-- Name: person_id_seq; Type: SEQUENCE SET; Schema: public; Owner: lemmy
--

SELECT pg_catalog.setval('public.person_id_seq', 2, true);


--
-- Name: person_mention_id_seq; Type: SEQUENCE SET; Schema: public; Owner: lemmy
--

SELECT pg_catalog.setval('public.person_mention_id_seq', 1, false);


--
-- Name: post_id_seq; Type: SEQUENCE SET; Schema: public; Owner: lemmy
--

SELECT pg_catalog.setval('public.post_id_seq', 1, true);


--
-- Name: post_report_id_seq; Type: SEQUENCE SET; Schema: public; Owner: lemmy
--

SELECT pg_catalog.setval('public.post_report_id_seq', 1, false);


--
-- Name: private_message_id_seq; Type: SEQUENCE SET; Schema: public; Owner: lemmy
--

SELECT pg_catalog.setval('public.private_message_id_seq', 1, false);


--
-- Name: private_message_report_id_seq; Type: SEQUENCE SET; Schema: public; Owner: lemmy
--

SELECT pg_catalog.setval('public.private_message_report_id_seq', 1, false);


--
-- Name: registration_application_id_seq; Type: SEQUENCE SET; Schema: public; Owner: lemmy
--

SELECT pg_catalog.setval('public.registration_application_id_seq', 1, false);


--
-- Name: secret_id_seq; Type: SEQUENCE SET; Schema: public; Owner: lemmy
--

SELECT pg_catalog.setval('public.secret_id_seq', 1, true);


--
-- Name: sent_activity_id_seq; Type: SEQUENCE SET; Schema: public; Owner: lemmy
--

SELECT pg_catalog.setval('public.sent_activity_id_seq', 7, true);


--
-- Name: site_id_seq; Type: SEQUENCE SET; Schema: public; Owner: lemmy
--

SELECT pg_catalog.setval('public.site_id_seq', 1, true);


--
-- Name: tagline_id_seq; Type: SEQUENCE SET; Schema: public; Owner: lemmy
--

SELECT pg_catalog.setval('public.tagline_id_seq', 1, false);


--
-- Name: deps_saved_ddl_id_seq; Type: SEQUENCE SET; Schema: utils; Owner: lemmy
--

SELECT pg_catalog.setval('utils.deps_saved_ddl_id_seq', 1, false);


--
-- Name: __diesel_schema_migrations __diesel_schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.__diesel_schema_migrations
    ADD CONSTRAINT __diesel_schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: admin_purge_comment admin_purge_comment_pkey; Type: CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.admin_purge_comment
    ADD CONSTRAINT admin_purge_comment_pkey PRIMARY KEY (id);


--
-- Name: admin_purge_community admin_purge_community_pkey; Type: CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.admin_purge_community
    ADD CONSTRAINT admin_purge_community_pkey PRIMARY KEY (id);


--
-- Name: admin_purge_person admin_purge_person_pkey; Type: CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.admin_purge_person
    ADD CONSTRAINT admin_purge_person_pkey PRIMARY KEY (id);


--
-- Name: admin_purge_post admin_purge_post_pkey; Type: CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.admin_purge_post
    ADD CONSTRAINT admin_purge_post_pkey PRIMARY KEY (id);


--
-- Name: captcha_answer captcha_answer_pkey; Type: CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.captcha_answer
    ADD CONSTRAINT captcha_answer_pkey PRIMARY KEY (uuid);


--
-- Name: comment_aggregates comment_aggregates_pkey; Type: CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.comment_aggregates
    ADD CONSTRAINT comment_aggregates_pkey PRIMARY KEY (comment_id);


--
-- Name: comment_like comment_like_pkey; Type: CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.comment_like
    ADD CONSTRAINT comment_like_pkey PRIMARY KEY (person_id, comment_id);


--
-- Name: comment comment_pkey; Type: CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.comment
    ADD CONSTRAINT comment_pkey PRIMARY KEY (id);


--
-- Name: comment_reply comment_reply_pkey; Type: CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.comment_reply
    ADD CONSTRAINT comment_reply_pkey PRIMARY KEY (id);


--
-- Name: comment_reply comment_reply_recipient_id_comment_id_key; Type: CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.comment_reply
    ADD CONSTRAINT comment_reply_recipient_id_comment_id_key UNIQUE (recipient_id, comment_id);


--
-- Name: comment_report comment_report_comment_id_creator_id_key; Type: CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.comment_report
    ADD CONSTRAINT comment_report_comment_id_creator_id_key UNIQUE (comment_id, creator_id);


--
-- Name: comment_report comment_report_pkey; Type: CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.comment_report
    ADD CONSTRAINT comment_report_pkey PRIMARY KEY (id);


--
-- Name: comment_saved comment_saved_pkey; Type: CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.comment_saved
    ADD CONSTRAINT comment_saved_pkey PRIMARY KEY (person_id, comment_id);


--
-- Name: community_aggregates community_aggregates_pkey; Type: CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.community_aggregates
    ADD CONSTRAINT community_aggregates_pkey PRIMARY KEY (community_id);


--
-- Name: community_block community_block_pkey; Type: CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.community_block
    ADD CONSTRAINT community_block_pkey PRIMARY KEY (person_id, community_id);


--
-- Name: community community_featured_url_key; Type: CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.community
    ADD CONSTRAINT community_featured_url_key UNIQUE (featured_url);


--
-- Name: community_follower community_follower_pkey; Type: CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.community_follower
    ADD CONSTRAINT community_follower_pkey PRIMARY KEY (person_id, community_id);


--
-- Name: community_language community_language_pkey; Type: CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.community_language
    ADD CONSTRAINT community_language_pkey PRIMARY KEY (community_id, language_id);


--
-- Name: community_moderator community_moderator_pkey; Type: CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.community_moderator
    ADD CONSTRAINT community_moderator_pkey PRIMARY KEY (person_id, community_id);


--
-- Name: community community_moderators_url_key; Type: CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.community
    ADD CONSTRAINT community_moderators_url_key UNIQUE (moderators_url);


--
-- Name: community_person_ban community_person_ban_pkey; Type: CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.community_person_ban
    ADD CONSTRAINT community_person_ban_pkey PRIMARY KEY (person_id, community_id);


--
-- Name: community community_pkey; Type: CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.community
    ADD CONSTRAINT community_pkey PRIMARY KEY (id);


--
-- Name: custom_emoji custom_emoji_image_url_key; Type: CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.custom_emoji
    ADD CONSTRAINT custom_emoji_image_url_key UNIQUE (image_url);


--
-- Name: custom_emoji_keyword custom_emoji_keyword_pkey; Type: CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.custom_emoji_keyword
    ADD CONSTRAINT custom_emoji_keyword_pkey PRIMARY KEY (custom_emoji_id, keyword);


--
-- Name: custom_emoji custom_emoji_pkey; Type: CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.custom_emoji
    ADD CONSTRAINT custom_emoji_pkey PRIMARY KEY (id);


--
-- Name: custom_emoji custom_emoji_shortcode_key; Type: CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.custom_emoji
    ADD CONSTRAINT custom_emoji_shortcode_key UNIQUE (shortcode);


--
-- Name: email_verification email_verification_pkey; Type: CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.email_verification
    ADD CONSTRAINT email_verification_pkey PRIMARY KEY (id);


--
-- Name: federation_allowlist federation_allowlist_pkey; Type: CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.federation_allowlist
    ADD CONSTRAINT federation_allowlist_pkey PRIMARY KEY (instance_id);


--
-- Name: federation_blocklist federation_blocklist_pkey; Type: CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.federation_blocklist
    ADD CONSTRAINT federation_blocklist_pkey PRIMARY KEY (instance_id);


--
-- Name: federation_queue_state federation_queue_state_pkey; Type: CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.federation_queue_state
    ADD CONSTRAINT federation_queue_state_pkey PRIMARY KEY (instance_id);


--
-- Name: comment idx_comment_ap_id; Type: CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.comment
    ADD CONSTRAINT idx_comment_ap_id UNIQUE (ap_id);


--
-- Name: community idx_community_actor_id; Type: CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.community
    ADD CONSTRAINT idx_community_actor_id UNIQUE (actor_id);


--
-- Name: community idx_community_followers_url; Type: CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.community
    ADD CONSTRAINT idx_community_followers_url UNIQUE (followers_url);


--
-- Name: person idx_person_actor_id; Type: CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.person
    ADD CONSTRAINT idx_person_actor_id UNIQUE (actor_id);


--
-- Name: post idx_post_ap_id; Type: CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.post
    ADD CONSTRAINT idx_post_ap_id UNIQUE (ap_id);


--
-- Name: private_message idx_private_message_ap_id; Type: CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.private_message
    ADD CONSTRAINT idx_private_message_ap_id UNIQUE (ap_id);


--
-- Name: site idx_site_instance_unique; Type: CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.site
    ADD CONSTRAINT idx_site_instance_unique UNIQUE (instance_id);


--
-- Name: image_details image_details_pkey; Type: CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.image_details
    ADD CONSTRAINT image_details_pkey PRIMARY KEY (link);


--
-- Name: local_image image_upload_pkey; Type: CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.local_image
    ADD CONSTRAINT image_upload_pkey PRIMARY KEY (pictrs_alias);


--
-- Name: instance_block instance_block_pkey; Type: CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.instance_block
    ADD CONSTRAINT instance_block_pkey PRIMARY KEY (person_id, instance_id);


--
-- Name: instance instance_domain_key; Type: CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.instance
    ADD CONSTRAINT instance_domain_key UNIQUE (domain);


--
-- Name: instance instance_pkey; Type: CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.instance
    ADD CONSTRAINT instance_pkey PRIMARY KEY (id);


--
-- Name: language language_pkey; Type: CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.language
    ADD CONSTRAINT language_pkey PRIMARY KEY (id);


--
-- Name: local_site local_site_pkey; Type: CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.local_site
    ADD CONSTRAINT local_site_pkey PRIMARY KEY (id);


--
-- Name: local_site_rate_limit local_site_rate_limit_pkey; Type: CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.local_site_rate_limit
    ADD CONSTRAINT local_site_rate_limit_pkey PRIMARY KEY (local_site_id);


--
-- Name: local_site local_site_site_id_key; Type: CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.local_site
    ADD CONSTRAINT local_site_site_id_key UNIQUE (site_id);


--
-- Name: local_site_url_blocklist local_site_url_blocklist_pkey; Type: CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.local_site_url_blocklist
    ADD CONSTRAINT local_site_url_blocklist_pkey PRIMARY KEY (id);


--
-- Name: local_site_url_blocklist local_site_url_blocklist_url_key; Type: CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.local_site_url_blocklist
    ADD CONSTRAINT local_site_url_blocklist_url_key UNIQUE (url);


--
-- Name: local_user local_user_email_key; Type: CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.local_user
    ADD CONSTRAINT local_user_email_key UNIQUE (email);


--
-- Name: local_user_language local_user_language_pkey; Type: CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.local_user_language
    ADD CONSTRAINT local_user_language_pkey PRIMARY KEY (local_user_id, language_id);


--
-- Name: local_user local_user_person_id_key; Type: CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.local_user
    ADD CONSTRAINT local_user_person_id_key UNIQUE (person_id);


--
-- Name: local_user local_user_pkey; Type: CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.local_user
    ADD CONSTRAINT local_user_pkey PRIMARY KEY (id);


--
-- Name: local_user_vote_display_mode local_user_vote_display_mode_pkey; Type: CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.local_user_vote_display_mode
    ADD CONSTRAINT local_user_vote_display_mode_pkey PRIMARY KEY (local_user_id);


--
-- Name: login_token login_token_pkey; Type: CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.login_token
    ADD CONSTRAINT login_token_pkey PRIMARY KEY (token);


--
-- Name: mod_add_community mod_add_community_pkey; Type: CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.mod_add_community
    ADD CONSTRAINT mod_add_community_pkey PRIMARY KEY (id);


--
-- Name: mod_add mod_add_pkey; Type: CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.mod_add
    ADD CONSTRAINT mod_add_pkey PRIMARY KEY (id);


--
-- Name: mod_ban_from_community mod_ban_from_community_pkey; Type: CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.mod_ban_from_community
    ADD CONSTRAINT mod_ban_from_community_pkey PRIMARY KEY (id);


--
-- Name: mod_ban mod_ban_pkey; Type: CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.mod_ban
    ADD CONSTRAINT mod_ban_pkey PRIMARY KEY (id);


--
-- Name: mod_hide_community mod_hide_community_pkey; Type: CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.mod_hide_community
    ADD CONSTRAINT mod_hide_community_pkey PRIMARY KEY (id);


--
-- Name: mod_lock_post mod_lock_post_pkey; Type: CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.mod_lock_post
    ADD CONSTRAINT mod_lock_post_pkey PRIMARY KEY (id);


--
-- Name: mod_remove_comment mod_remove_comment_pkey; Type: CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.mod_remove_comment
    ADD CONSTRAINT mod_remove_comment_pkey PRIMARY KEY (id);


--
-- Name: mod_remove_community mod_remove_community_pkey; Type: CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.mod_remove_community
    ADD CONSTRAINT mod_remove_community_pkey PRIMARY KEY (id);


--
-- Name: mod_remove_post mod_remove_post_pkey; Type: CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.mod_remove_post
    ADD CONSTRAINT mod_remove_post_pkey PRIMARY KEY (id);


--
-- Name: mod_feature_post mod_sticky_post_pkey; Type: CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.mod_feature_post
    ADD CONSTRAINT mod_sticky_post_pkey PRIMARY KEY (id);


--
-- Name: mod_transfer_community mod_transfer_community_pkey; Type: CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.mod_transfer_community
    ADD CONSTRAINT mod_transfer_community_pkey PRIMARY KEY (id);


--
-- Name: password_reset_request password_reset_request_pkey; Type: CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.password_reset_request
    ADD CONSTRAINT password_reset_request_pkey PRIMARY KEY (id);


--
-- Name: person person__pkey; Type: CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.person
    ADD CONSTRAINT person__pkey PRIMARY KEY (id);


--
-- Name: person_aggregates person_aggregates_pkey; Type: CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.person_aggregates
    ADD CONSTRAINT person_aggregates_pkey PRIMARY KEY (person_id);


--
-- Name: person_ban person_ban_pkey; Type: CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.person_ban
    ADD CONSTRAINT person_ban_pkey PRIMARY KEY (person_id);


--
-- Name: person_block person_block_pkey; Type: CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.person_block
    ADD CONSTRAINT person_block_pkey PRIMARY KEY (person_id, target_id);


--
-- Name: person_follower person_follower_pkey; Type: CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.person_follower
    ADD CONSTRAINT person_follower_pkey PRIMARY KEY (follower_id, person_id);


--
-- Name: person_mention person_mention_pkey; Type: CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.person_mention
    ADD CONSTRAINT person_mention_pkey PRIMARY KEY (id);


--
-- Name: person_mention person_mention_recipient_id_comment_id_key; Type: CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.person_mention
    ADD CONSTRAINT person_mention_recipient_id_comment_id_key UNIQUE (recipient_id, comment_id);


--
-- Name: person_post_aggregates person_post_aggregates_pkey; Type: CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.person_post_aggregates
    ADD CONSTRAINT person_post_aggregates_pkey PRIMARY KEY (person_id, post_id);


--
-- Name: post_aggregates post_aggregates_pkey; Type: CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.post_aggregates
    ADD CONSTRAINT post_aggregates_pkey PRIMARY KEY (post_id);


--
-- Name: post_hide post_hide_pkey; Type: CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.post_hide
    ADD CONSTRAINT post_hide_pkey PRIMARY KEY (person_id, post_id);


--
-- Name: post_like post_like_pkey; Type: CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.post_like
    ADD CONSTRAINT post_like_pkey PRIMARY KEY (person_id, post_id);


--
-- Name: post post_pkey; Type: CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.post
    ADD CONSTRAINT post_pkey PRIMARY KEY (id);


--
-- Name: post_read post_read_pkey; Type: CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.post_read
    ADD CONSTRAINT post_read_pkey PRIMARY KEY (person_id, post_id);


--
-- Name: post_report post_report_pkey; Type: CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.post_report
    ADD CONSTRAINT post_report_pkey PRIMARY KEY (id);


--
-- Name: post_report post_report_post_id_creator_id_key; Type: CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.post_report
    ADD CONSTRAINT post_report_post_id_creator_id_key UNIQUE (post_id, creator_id);


--
-- Name: post_saved post_saved_pkey; Type: CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.post_saved
    ADD CONSTRAINT post_saved_pkey PRIMARY KEY (person_id, post_id);


--
-- Name: private_message private_message_pkey; Type: CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.private_message
    ADD CONSTRAINT private_message_pkey PRIMARY KEY (id);


--
-- Name: private_message_report private_message_report_pkey; Type: CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.private_message_report
    ADD CONSTRAINT private_message_report_pkey PRIMARY KEY (id);


--
-- Name: private_message_report private_message_report_private_message_id_creator_id_key; Type: CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.private_message_report
    ADD CONSTRAINT private_message_report_private_message_id_creator_id_key UNIQUE (private_message_id, creator_id);


--
-- Name: received_activity received_activity_pkey; Type: CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.received_activity
    ADD CONSTRAINT received_activity_pkey PRIMARY KEY (ap_id);


--
-- Name: registration_application registration_application_local_user_id_key; Type: CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.registration_application
    ADD CONSTRAINT registration_application_local_user_id_key UNIQUE (local_user_id);


--
-- Name: registration_application registration_application_pkey; Type: CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.registration_application
    ADD CONSTRAINT registration_application_pkey PRIMARY KEY (id);


--
-- Name: remote_image remote_image_pkey; Type: CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.remote_image
    ADD CONSTRAINT remote_image_pkey PRIMARY KEY (link);


--
-- Name: secret secret_pkey; Type: CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.secret
    ADD CONSTRAINT secret_pkey PRIMARY KEY (id);


--
-- Name: sent_activity sent_activity_ap_id_key; Type: CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.sent_activity
    ADD CONSTRAINT sent_activity_ap_id_key UNIQUE (ap_id);


--
-- Name: sent_activity sent_activity_pkey; Type: CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.sent_activity
    ADD CONSTRAINT sent_activity_pkey PRIMARY KEY (id);


--
-- Name: site site_actor_id_key; Type: CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.site
    ADD CONSTRAINT site_actor_id_key UNIQUE (actor_id);


--
-- Name: site_aggregates site_aggregates_pkey; Type: CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.site_aggregates
    ADD CONSTRAINT site_aggregates_pkey PRIMARY KEY (site_id);


--
-- Name: site_language site_language_pkey; Type: CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.site_language
    ADD CONSTRAINT site_language_pkey PRIMARY KEY (site_id, language_id);


--
-- Name: site site_pkey; Type: CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.site
    ADD CONSTRAINT site_pkey PRIMARY KEY (id);


--
-- Name: tagline tagline_pkey; Type: CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.tagline
    ADD CONSTRAINT tagline_pkey PRIMARY KEY (id);


--
-- Name: deps_saved_ddl deps_saved_ddl_pkey; Type: CONSTRAINT; Schema: utils; Owner: lemmy
--

ALTER TABLE ONLY utils.deps_saved_ddl
    ADD CONSTRAINT deps_saved_ddl_pkey PRIMARY KEY (id);


--
-- Name: idx_comment_aggregates_controversy; Type: INDEX; Schema: public; Owner: lemmy
--

CREATE INDEX idx_comment_aggregates_controversy ON public.comment_aggregates USING btree (controversy_rank DESC);


--
-- Name: idx_comment_aggregates_hot; Type: INDEX; Schema: public; Owner: lemmy
--

CREATE INDEX idx_comment_aggregates_hot ON public.comment_aggregates USING btree (hot_rank DESC, score DESC);


--
-- Name: idx_comment_aggregates_nonzero_hotrank; Type: INDEX; Schema: public; Owner: lemmy
--

CREATE INDEX idx_comment_aggregates_nonzero_hotrank ON public.comment_aggregates USING btree (published) WHERE (hot_rank <> (0)::double precision);


--
-- Name: idx_comment_aggregates_published; Type: INDEX; Schema: public; Owner: lemmy
--

CREATE INDEX idx_comment_aggregates_published ON public.comment_aggregates USING btree (published DESC);


--
-- Name: idx_comment_aggregates_score; Type: INDEX; Schema: public; Owner: lemmy
--

CREATE INDEX idx_comment_aggregates_score ON public.comment_aggregates USING btree (score DESC);


--
-- Name: idx_comment_content_trigram; Type: INDEX; Schema: public; Owner: lemmy
--

CREATE INDEX idx_comment_content_trigram ON public.comment USING gin (content public.gin_trgm_ops);


--
-- Name: idx_comment_creator; Type: INDEX; Schema: public; Owner: lemmy
--

CREATE INDEX idx_comment_creator ON public.comment USING btree (creator_id);


--
-- Name: idx_comment_language; Type: INDEX; Schema: public; Owner: lemmy
--

CREATE INDEX idx_comment_language ON public.comment USING btree (language_id);


--
-- Name: idx_comment_like_comment; Type: INDEX; Schema: public; Owner: lemmy
--

CREATE INDEX idx_comment_like_comment ON public.comment_like USING btree (comment_id);


--
-- Name: idx_comment_like_post; Type: INDEX; Schema: public; Owner: lemmy
--

CREATE INDEX idx_comment_like_post ON public.comment_like USING btree (post_id);


--
-- Name: idx_comment_post; Type: INDEX; Schema: public; Owner: lemmy
--

CREATE INDEX idx_comment_post ON public.comment USING btree (post_id);


--
-- Name: idx_comment_published; Type: INDEX; Schema: public; Owner: lemmy
--

CREATE INDEX idx_comment_published ON public.comment USING btree (published DESC);


--
-- Name: idx_comment_reply_comment; Type: INDEX; Schema: public; Owner: lemmy
--

CREATE INDEX idx_comment_reply_comment ON public.comment_reply USING btree (comment_id);


--
-- Name: idx_comment_reply_published; Type: INDEX; Schema: public; Owner: lemmy
--

CREATE INDEX idx_comment_reply_published ON public.comment_reply USING btree (published DESC);


--
-- Name: idx_comment_reply_recipient; Type: INDEX; Schema: public; Owner: lemmy
--

CREATE INDEX idx_comment_reply_recipient ON public.comment_reply USING btree (recipient_id);


--
-- Name: idx_comment_report_published; Type: INDEX; Schema: public; Owner: lemmy
--

CREATE INDEX idx_comment_report_published ON public.comment_report USING btree (published DESC);


--
-- Name: idx_comment_saved_comment; Type: INDEX; Schema: public; Owner: lemmy
--

CREATE INDEX idx_comment_saved_comment ON public.comment_saved USING btree (comment_id);


--
-- Name: idx_comment_saved_person; Type: INDEX; Schema: public; Owner: lemmy
--

CREATE INDEX idx_comment_saved_person ON public.comment_saved USING btree (person_id);


--
-- Name: idx_community_aggregates_hot; Type: INDEX; Schema: public; Owner: lemmy
--

CREATE INDEX idx_community_aggregates_hot ON public.community_aggregates USING btree (hot_rank DESC);


--
-- Name: idx_community_aggregates_nonzero_hotrank; Type: INDEX; Schema: public; Owner: lemmy
--

CREATE INDEX idx_community_aggregates_nonzero_hotrank ON public.community_aggregates USING btree (published) WHERE (hot_rank <> (0)::double precision);


--
-- Name: idx_community_aggregates_published; Type: INDEX; Schema: public; Owner: lemmy
--

CREATE INDEX idx_community_aggregates_published ON public.community_aggregates USING btree (published DESC);


--
-- Name: idx_community_aggregates_subscribers; Type: INDEX; Schema: public; Owner: lemmy
--

CREATE INDEX idx_community_aggregates_subscribers ON public.community_aggregates USING btree (subscribers DESC);


--
-- Name: idx_community_aggregates_users_active_month; Type: INDEX; Schema: public; Owner: lemmy
--

CREATE INDEX idx_community_aggregates_users_active_month ON public.community_aggregates USING btree (users_active_month DESC);


--
-- Name: idx_community_block_community; Type: INDEX; Schema: public; Owner: lemmy
--

CREATE INDEX idx_community_block_community ON public.community_block USING btree (community_id);


--
-- Name: idx_community_follower_community; Type: INDEX; Schema: public; Owner: lemmy
--

CREATE INDEX idx_community_follower_community ON public.community_follower USING btree (community_id);


--
-- Name: idx_community_follower_published; Type: INDEX; Schema: public; Owner: lemmy
--

CREATE INDEX idx_community_follower_published ON public.community_follower USING btree (published);


--
-- Name: idx_community_lower_actor_id; Type: INDEX; Schema: public; Owner: lemmy
--

CREATE UNIQUE INDEX idx_community_lower_actor_id ON public.community USING btree (lower((actor_id)::text));


--
-- Name: idx_community_lower_name; Type: INDEX; Schema: public; Owner: lemmy
--

CREATE INDEX idx_community_lower_name ON public.community USING btree (lower((name)::text));


--
-- Name: idx_community_moderator_community; Type: INDEX; Schema: public; Owner: lemmy
--

CREATE INDEX idx_community_moderator_community ON public.community_moderator USING btree (community_id);


--
-- Name: idx_community_moderator_published; Type: INDEX; Schema: public; Owner: lemmy
--

CREATE INDEX idx_community_moderator_published ON public.community_moderator USING btree (published);


--
-- Name: idx_community_published; Type: INDEX; Schema: public; Owner: lemmy
--

CREATE INDEX idx_community_published ON public.community USING btree (published DESC);


--
-- Name: idx_community_title; Type: INDEX; Schema: public; Owner: lemmy
--

CREATE INDEX idx_community_title ON public.community USING btree (title);


--
-- Name: idx_community_trigram; Type: INDEX; Schema: public; Owner: lemmy
--

CREATE INDEX idx_community_trigram ON public.community USING gin (name public.gin_trgm_ops, title public.gin_trgm_ops);


--
-- Name: idx_custom_emoji_category; Type: INDEX; Schema: public; Owner: lemmy
--

CREATE INDEX idx_custom_emoji_category ON public.custom_emoji USING btree (id, category);


--
-- Name: idx_image_upload_local_user_id; Type: INDEX; Schema: public; Owner: lemmy
--

CREATE INDEX idx_image_upload_local_user_id ON public.local_image USING btree (local_user_id);


--
-- Name: idx_login_token_user_token; Type: INDEX; Schema: public; Owner: lemmy
--

CREATE INDEX idx_login_token_user_token ON public.login_token USING btree (user_id, token);


--
-- Name: idx_path_gist; Type: INDEX; Schema: public; Owner: lemmy
--

CREATE INDEX idx_path_gist ON public.comment USING gist (path);


--
-- Name: idx_person_aggregates_comment_score; Type: INDEX; Schema: public; Owner: lemmy
--

CREATE INDEX idx_person_aggregates_comment_score ON public.person_aggregates USING btree (comment_score DESC);


--
-- Name: idx_person_aggregates_person; Type: INDEX; Schema: public; Owner: lemmy
--

CREATE INDEX idx_person_aggregates_person ON public.person_aggregates USING btree (person_id);


--
-- Name: idx_person_block_person; Type: INDEX; Schema: public; Owner: lemmy
--

CREATE INDEX idx_person_block_person ON public.person_block USING btree (person_id);


--
-- Name: idx_person_block_target; Type: INDEX; Schema: public; Owner: lemmy
--

CREATE INDEX idx_person_block_target ON public.person_block USING btree (target_id);


--
-- Name: idx_person_local_instance; Type: INDEX; Schema: public; Owner: lemmy
--

CREATE INDEX idx_person_local_instance ON public.person USING btree (local DESC, instance_id);


--
-- Name: idx_person_lower_actor_id; Type: INDEX; Schema: public; Owner: lemmy
--

CREATE UNIQUE INDEX idx_person_lower_actor_id ON public.person USING btree (lower((actor_id)::text));


--
-- Name: idx_person_lower_name; Type: INDEX; Schema: public; Owner: lemmy
--

CREATE INDEX idx_person_lower_name ON public.person USING btree (lower((name)::text));


--
-- Name: idx_person_post_aggregates_person; Type: INDEX; Schema: public; Owner: lemmy
--

CREATE INDEX idx_person_post_aggregates_person ON public.person_post_aggregates USING btree (person_id);


--
-- Name: idx_person_post_aggregates_post; Type: INDEX; Schema: public; Owner: lemmy
--

CREATE INDEX idx_person_post_aggregates_post ON public.person_post_aggregates USING btree (post_id);


--
-- Name: idx_person_published; Type: INDEX; Schema: public; Owner: lemmy
--

CREATE INDEX idx_person_published ON public.person USING btree (published DESC);


--
-- Name: idx_person_trigram; Type: INDEX; Schema: public; Owner: lemmy
--

CREATE INDEX idx_person_trigram ON public.person USING gin (name public.gin_trgm_ops, display_name public.gin_trgm_ops);


--
-- Name: idx_post_aggregates_community_active; Type: INDEX; Schema: public; Owner: lemmy
--

CREATE INDEX idx_post_aggregates_community_active ON public.post_aggregates USING btree (community_id, featured_local DESC, hot_rank_active DESC, published DESC, post_id DESC);


--
-- Name: idx_post_aggregates_community_controversy; Type: INDEX; Schema: public; Owner: lemmy
--

CREATE INDEX idx_post_aggregates_community_controversy ON public.post_aggregates USING btree (community_id, featured_local DESC, controversy_rank DESC, post_id DESC);


--
-- Name: idx_post_aggregates_community_hot; Type: INDEX; Schema: public; Owner: lemmy
--

CREATE INDEX idx_post_aggregates_community_hot ON public.post_aggregates USING btree (community_id, featured_local DESC, hot_rank DESC, published DESC, post_id DESC);


--
-- Name: idx_post_aggregates_community_most_comments; Type: INDEX; Schema: public; Owner: lemmy
--

CREATE INDEX idx_post_aggregates_community_most_comments ON public.post_aggregates USING btree (community_id, featured_local DESC, comments DESC, published DESC, post_id DESC);


--
-- Name: idx_post_aggregates_community_newest_comment_time; Type: INDEX; Schema: public; Owner: lemmy
--

CREATE INDEX idx_post_aggregates_community_newest_comment_time ON public.post_aggregates USING btree (community_id, featured_local DESC, newest_comment_time DESC, post_id DESC);


--
-- Name: idx_post_aggregates_community_newest_comment_time_necro; Type: INDEX; Schema: public; Owner: lemmy
--

CREATE INDEX idx_post_aggregates_community_newest_comment_time_necro ON public.post_aggregates USING btree (community_id, featured_local DESC, newest_comment_time_necro DESC, post_id DESC);


--
-- Name: idx_post_aggregates_community_published; Type: INDEX; Schema: public; Owner: lemmy
--

CREATE INDEX idx_post_aggregates_community_published ON public.post_aggregates USING btree (community_id, featured_local DESC, published DESC, post_id DESC);


--
-- Name: idx_post_aggregates_community_published_asc; Type: INDEX; Schema: public; Owner: lemmy
--

CREATE INDEX idx_post_aggregates_community_published_asc ON public.post_aggregates USING btree (community_id, featured_local DESC, public.reverse_timestamp_sort(published) DESC, post_id DESC);


--
-- Name: idx_post_aggregates_community_scaled; Type: INDEX; Schema: public; Owner: lemmy
--

CREATE INDEX idx_post_aggregates_community_scaled ON public.post_aggregates USING btree (community_id, featured_local DESC, scaled_rank DESC, published DESC, post_id DESC);


--
-- Name: idx_post_aggregates_community_score; Type: INDEX; Schema: public; Owner: lemmy
--

CREATE INDEX idx_post_aggregates_community_score ON public.post_aggregates USING btree (community_id, featured_local DESC, score DESC, published DESC, post_id DESC);


--
-- Name: idx_post_aggregates_featured_community_active; Type: INDEX; Schema: public; Owner: lemmy
--

CREATE INDEX idx_post_aggregates_featured_community_active ON public.post_aggregates USING btree (community_id, featured_community DESC, hot_rank_active DESC, published DESC, post_id DESC);


--
-- Name: idx_post_aggregates_featured_community_controversy; Type: INDEX; Schema: public; Owner: lemmy
--

CREATE INDEX idx_post_aggregates_featured_community_controversy ON public.post_aggregates USING btree (community_id, featured_community DESC, controversy_rank DESC, post_id DESC);


--
-- Name: idx_post_aggregates_featured_community_hot; Type: INDEX; Schema: public; Owner: lemmy
--

CREATE INDEX idx_post_aggregates_featured_community_hot ON public.post_aggregates USING btree (community_id, featured_community DESC, hot_rank DESC, published DESC, post_id DESC);


--
-- Name: idx_post_aggregates_featured_community_most_comments; Type: INDEX; Schema: public; Owner: lemmy
--

CREATE INDEX idx_post_aggregates_featured_community_most_comments ON public.post_aggregates USING btree (community_id, featured_community DESC, comments DESC, published DESC, post_id DESC);


--
-- Name: idx_post_aggregates_featured_community_newest_comment_time; Type: INDEX; Schema: public; Owner: lemmy
--

CREATE INDEX idx_post_aggregates_featured_community_newest_comment_time ON public.post_aggregates USING btree (community_id, featured_community DESC, newest_comment_time DESC, post_id DESC);


--
-- Name: idx_post_aggregates_featured_community_newest_comment_time_necr; Type: INDEX; Schema: public; Owner: lemmy
--

CREATE INDEX idx_post_aggregates_featured_community_newest_comment_time_necr ON public.post_aggregates USING btree (community_id, featured_community DESC, newest_comment_time_necro DESC, post_id DESC);


--
-- Name: idx_post_aggregates_featured_community_published; Type: INDEX; Schema: public; Owner: lemmy
--

CREATE INDEX idx_post_aggregates_featured_community_published ON public.post_aggregates USING btree (community_id, featured_community DESC, published DESC, post_id DESC);


--
-- Name: idx_post_aggregates_featured_community_published_asc; Type: INDEX; Schema: public; Owner: lemmy
--

CREATE INDEX idx_post_aggregates_featured_community_published_asc ON public.post_aggregates USING btree (community_id, featured_community DESC, public.reverse_timestamp_sort(published) DESC, post_id DESC);


--
-- Name: idx_post_aggregates_featured_community_scaled; Type: INDEX; Schema: public; Owner: lemmy
--

CREATE INDEX idx_post_aggregates_featured_community_scaled ON public.post_aggregates USING btree (community_id, featured_community DESC, scaled_rank DESC, published DESC, post_id DESC);


--
-- Name: idx_post_aggregates_featured_community_score; Type: INDEX; Schema: public; Owner: lemmy
--

CREATE INDEX idx_post_aggregates_featured_community_score ON public.post_aggregates USING btree (community_id, featured_community DESC, score DESC, published DESC, post_id DESC);


--
-- Name: idx_post_aggregates_featured_local_active; Type: INDEX; Schema: public; Owner: lemmy
--

CREATE INDEX idx_post_aggregates_featured_local_active ON public.post_aggregates USING btree (featured_local DESC, hot_rank_active DESC, published DESC, post_id DESC);


--
-- Name: idx_post_aggregates_featured_local_controversy; Type: INDEX; Schema: public; Owner: lemmy
--

CREATE INDEX idx_post_aggregates_featured_local_controversy ON public.post_aggregates USING btree (featured_local DESC, controversy_rank DESC, post_id DESC);


--
-- Name: idx_post_aggregates_featured_local_hot; Type: INDEX; Schema: public; Owner: lemmy
--

CREATE INDEX idx_post_aggregates_featured_local_hot ON public.post_aggregates USING btree (featured_local DESC, hot_rank DESC, published DESC, post_id DESC);


--
-- Name: idx_post_aggregates_featured_local_most_comments; Type: INDEX; Schema: public; Owner: lemmy
--

CREATE INDEX idx_post_aggregates_featured_local_most_comments ON public.post_aggregates USING btree (featured_local DESC, comments DESC, published DESC, post_id DESC);


--
-- Name: idx_post_aggregates_featured_local_newest_comment_time; Type: INDEX; Schema: public; Owner: lemmy
--

CREATE INDEX idx_post_aggregates_featured_local_newest_comment_time ON public.post_aggregates USING btree (featured_local DESC, newest_comment_time DESC, post_id DESC);


--
-- Name: idx_post_aggregates_featured_local_newest_comment_time_necro; Type: INDEX; Schema: public; Owner: lemmy
--

CREATE INDEX idx_post_aggregates_featured_local_newest_comment_time_necro ON public.post_aggregates USING btree (featured_local DESC, newest_comment_time_necro DESC, post_id DESC);


--
-- Name: idx_post_aggregates_featured_local_published; Type: INDEX; Schema: public; Owner: lemmy
--

CREATE INDEX idx_post_aggregates_featured_local_published ON public.post_aggregates USING btree (featured_local DESC, published DESC, post_id DESC);


--
-- Name: idx_post_aggregates_featured_local_published_asc; Type: INDEX; Schema: public; Owner: lemmy
--

CREATE INDEX idx_post_aggregates_featured_local_published_asc ON public.post_aggregates USING btree (featured_local DESC, public.reverse_timestamp_sort(published) DESC, post_id DESC);


--
-- Name: idx_post_aggregates_featured_local_scaled; Type: INDEX; Schema: public; Owner: lemmy
--

CREATE INDEX idx_post_aggregates_featured_local_scaled ON public.post_aggregates USING btree (featured_local DESC, scaled_rank DESC, published DESC, post_id DESC);


--
-- Name: idx_post_aggregates_featured_local_score; Type: INDEX; Schema: public; Owner: lemmy
--

CREATE INDEX idx_post_aggregates_featured_local_score ON public.post_aggregates USING btree (featured_local DESC, score DESC, published DESC, post_id DESC);


--
-- Name: idx_post_aggregates_nonzero_hotrank; Type: INDEX; Schema: public; Owner: lemmy
--

CREATE INDEX idx_post_aggregates_nonzero_hotrank ON public.post_aggregates USING btree (published DESC) WHERE ((hot_rank <> (0)::double precision) OR (hot_rank_active <> (0)::double precision));


--
-- Name: idx_post_aggregates_published; Type: INDEX; Schema: public; Owner: lemmy
--

CREATE INDEX idx_post_aggregates_published ON public.post_aggregates USING btree (published DESC);


--
-- Name: idx_post_aggregates_published_asc; Type: INDEX; Schema: public; Owner: lemmy
--

CREATE INDEX idx_post_aggregates_published_asc ON public.post_aggregates USING btree (public.reverse_timestamp_sort(published) DESC);


--
-- Name: idx_post_community; Type: INDEX; Schema: public; Owner: lemmy
--

CREATE INDEX idx_post_community ON public.post USING btree (community_id);


--
-- Name: idx_post_creator; Type: INDEX; Schema: public; Owner: lemmy
--

CREATE INDEX idx_post_creator ON public.post USING btree (creator_id);


--
-- Name: idx_post_language; Type: INDEX; Schema: public; Owner: lemmy
--

CREATE INDEX idx_post_language ON public.post USING btree (language_id);


--
-- Name: idx_post_like_post; Type: INDEX; Schema: public; Owner: lemmy
--

CREATE INDEX idx_post_like_post ON public.post_like USING btree (post_id);


--
-- Name: idx_post_report_published; Type: INDEX; Schema: public; Owner: lemmy
--

CREATE INDEX idx_post_report_published ON public.post_report USING btree (published DESC);


--
-- Name: idx_post_trigram; Type: INDEX; Schema: public; Owner: lemmy
--

CREATE INDEX idx_post_trigram ON public.post USING gin (name public.gin_trgm_ops, body public.gin_trgm_ops, alt_text public.gin_trgm_ops);


--
-- Name: idx_post_url; Type: INDEX; Schema: public; Owner: lemmy
--

CREATE INDEX idx_post_url ON public.post USING btree (url);


--
-- Name: idx_registration_application_published; Type: INDEX; Schema: public; Owner: lemmy
--

CREATE INDEX idx_registration_application_published ON public.registration_application USING btree (published DESC);


--
-- Name: idx_site_aggregates_1_row_only; Type: INDEX; Schema: public; Owner: lemmy
--

CREATE UNIQUE INDEX idx_site_aggregates_1_row_only ON public.site_aggregates USING btree ((true));


--
-- Name: comment aggregates; Type: TRIGGER; Schema: public; Owner: lemmy
--

CREATE TRIGGER aggregates AFTER INSERT ON public.comment REFERENCING NEW TABLE AS new_comment FOR EACH STATEMENT EXECUTE FUNCTION r.comment_aggregates_from_comment();


--
-- Name: community aggregates; Type: TRIGGER; Schema: public; Owner: lemmy
--

CREATE TRIGGER aggregates AFTER INSERT ON public.community REFERENCING NEW TABLE AS new_community FOR EACH STATEMENT EXECUTE FUNCTION r.community_aggregates_from_community();


--
-- Name: person aggregates; Type: TRIGGER; Schema: public; Owner: lemmy
--

CREATE TRIGGER aggregates AFTER INSERT ON public.person REFERENCING NEW TABLE AS new_person FOR EACH STATEMENT EXECUTE FUNCTION r.person_aggregates_from_person();


--
-- Name: post aggregates; Type: TRIGGER; Schema: public; Owner: lemmy
--

CREATE TRIGGER aggregates AFTER INSERT ON public.post REFERENCING NEW TABLE AS new_post FOR EACH STATEMENT EXECUTE FUNCTION r.post_aggregates_from_post();


--
-- Name: site aggregates; Type: TRIGGER; Schema: public; Owner: lemmy
--

CREATE TRIGGER aggregates AFTER INSERT ON public.site FOR EACH ROW EXECUTE FUNCTION r.site_aggregates_from_site();


--
-- Name: post aggregates_update; Type: TRIGGER; Schema: public; Owner: lemmy
--

CREATE TRIGGER aggregates_update AFTER UPDATE ON public.post REFERENCING OLD TABLE AS old_post NEW TABLE AS new_post FOR EACH STATEMENT EXECUTE FUNCTION r.post_aggregates_from_post_update();


--
-- Name: comment change_values; Type: TRIGGER; Schema: public; Owner: lemmy
--

CREATE TRIGGER change_values BEFORE INSERT OR UPDATE ON public.comment FOR EACH ROW EXECUTE FUNCTION r.comment_change_values();


--
-- Name: post change_values; Type: TRIGGER; Schema: public; Owner: lemmy
--

CREATE TRIGGER change_values BEFORE INSERT ON public.post FOR EACH ROW EXECUTE FUNCTION r.post_change_values();


--
-- Name: private_message change_values; Type: TRIGGER; Schema: public; Owner: lemmy
--

CREATE TRIGGER change_values BEFORE INSERT ON public.private_message FOR EACH ROW EXECUTE FUNCTION r.private_message_change_values();


--
-- Name: post comment_count; Type: TRIGGER; Schema: public; Owner: lemmy
--

CREATE TRIGGER comment_count AFTER UPDATE ON public.post REFERENCING OLD TABLE AS old_post NEW TABLE AS new_post FOR EACH STATEMENT EXECUTE FUNCTION r.update_comment_count_from_post();


--
-- Name: post delete_comments; Type: TRIGGER; Schema: public; Owner: lemmy
--

CREATE TRIGGER delete_comments BEFORE DELETE ON public.post FOR EACH ROW EXECUTE FUNCTION r.delete_comments_before_post();


--
-- Name: person delete_follow; Type: TRIGGER; Schema: public; Owner: lemmy
--

CREATE TRIGGER delete_follow BEFORE DELETE ON public.person FOR EACH ROW EXECUTE FUNCTION r.delete_follow_before_person();


--
-- Name: comment delete_statement; Type: TRIGGER; Schema: public; Owner: lemmy
--

CREATE TRIGGER delete_statement AFTER DELETE ON public.comment REFERENCING OLD TABLE AS select_old_rows FOR EACH STATEMENT EXECUTE FUNCTION r.comment_delete_statement();


--
-- Name: comment_like delete_statement; Type: TRIGGER; Schema: public; Owner: lemmy
--

CREATE TRIGGER delete_statement AFTER DELETE ON public.comment_like REFERENCING OLD TABLE AS select_old_rows FOR EACH STATEMENT EXECUTE FUNCTION r.comment_like_delete_statement();


--
-- Name: community delete_statement; Type: TRIGGER; Schema: public; Owner: lemmy
--

CREATE TRIGGER delete_statement AFTER DELETE ON public.community REFERENCING OLD TABLE AS select_old_rows FOR EACH STATEMENT EXECUTE FUNCTION r.community_delete_statement();


--
-- Name: community_follower delete_statement; Type: TRIGGER; Schema: public; Owner: lemmy
--

CREATE TRIGGER delete_statement AFTER DELETE ON public.community_follower REFERENCING OLD TABLE AS select_old_rows FOR EACH STATEMENT EXECUTE FUNCTION r.community_follower_delete_statement();


--
-- Name: person delete_statement; Type: TRIGGER; Schema: public; Owner: lemmy
--

CREATE TRIGGER delete_statement AFTER DELETE ON public.person REFERENCING OLD TABLE AS select_old_rows FOR EACH STATEMENT EXECUTE FUNCTION r.person_delete_statement();


--
-- Name: post delete_statement; Type: TRIGGER; Schema: public; Owner: lemmy
--

CREATE TRIGGER delete_statement AFTER DELETE ON public.post REFERENCING OLD TABLE AS select_old_rows FOR EACH STATEMENT EXECUTE FUNCTION r.post_delete_statement();


--
-- Name: post_like delete_statement; Type: TRIGGER; Schema: public; Owner: lemmy
--

CREATE TRIGGER delete_statement AFTER DELETE ON public.post_like REFERENCING OLD TABLE AS select_old_rows FOR EACH STATEMENT EXECUTE FUNCTION r.post_like_delete_statement();


--
-- Name: comment insert_statement; Type: TRIGGER; Schema: public; Owner: lemmy
--

CREATE TRIGGER insert_statement AFTER INSERT ON public.comment REFERENCING NEW TABLE AS select_new_rows FOR EACH STATEMENT EXECUTE FUNCTION r.comment_insert_statement();


--
-- Name: comment_like insert_statement; Type: TRIGGER; Schema: public; Owner: lemmy
--

CREATE TRIGGER insert_statement AFTER INSERT ON public.comment_like REFERENCING NEW TABLE AS select_new_rows FOR EACH STATEMENT EXECUTE FUNCTION r.comment_like_insert_statement();


--
-- Name: community insert_statement; Type: TRIGGER; Schema: public; Owner: lemmy
--

CREATE TRIGGER insert_statement AFTER INSERT ON public.community REFERENCING NEW TABLE AS select_new_rows FOR EACH STATEMENT EXECUTE FUNCTION r.community_insert_statement();


--
-- Name: community_follower insert_statement; Type: TRIGGER; Schema: public; Owner: lemmy
--

CREATE TRIGGER insert_statement AFTER INSERT ON public.community_follower REFERENCING NEW TABLE AS select_new_rows FOR EACH STATEMENT EXECUTE FUNCTION r.community_follower_insert_statement();


--
-- Name: person insert_statement; Type: TRIGGER; Schema: public; Owner: lemmy
--

CREATE TRIGGER insert_statement AFTER INSERT ON public.person REFERENCING NEW TABLE AS select_new_rows FOR EACH STATEMENT EXECUTE FUNCTION r.person_insert_statement();


--
-- Name: post insert_statement; Type: TRIGGER; Schema: public; Owner: lemmy
--

CREATE TRIGGER insert_statement AFTER INSERT ON public.post REFERENCING NEW TABLE AS select_new_rows FOR EACH STATEMENT EXECUTE FUNCTION r.post_insert_statement();


--
-- Name: post_like insert_statement; Type: TRIGGER; Schema: public; Owner: lemmy
--

CREATE TRIGGER insert_statement AFTER INSERT ON public.post_like REFERENCING NEW TABLE AS select_new_rows FOR EACH STATEMENT EXECUTE FUNCTION r.post_like_insert_statement();


--
-- Name: comment update_statement; Type: TRIGGER; Schema: public; Owner: lemmy
--

CREATE TRIGGER update_statement AFTER UPDATE ON public.comment REFERENCING OLD TABLE AS select_old_rows NEW TABLE AS select_new_rows FOR EACH STATEMENT EXECUTE FUNCTION r.comment_update_statement();


--
-- Name: comment_like update_statement; Type: TRIGGER; Schema: public; Owner: lemmy
--

CREATE TRIGGER update_statement AFTER UPDATE ON public.comment_like REFERENCING OLD TABLE AS select_old_rows NEW TABLE AS select_new_rows FOR EACH STATEMENT EXECUTE FUNCTION r.comment_like_update_statement();


--
-- Name: community update_statement; Type: TRIGGER; Schema: public; Owner: lemmy
--

CREATE TRIGGER update_statement AFTER UPDATE ON public.community REFERENCING OLD TABLE AS select_old_rows NEW TABLE AS select_new_rows FOR EACH STATEMENT EXECUTE FUNCTION r.community_update_statement();


--
-- Name: community_follower update_statement; Type: TRIGGER; Schema: public; Owner: lemmy
--

CREATE TRIGGER update_statement AFTER UPDATE ON public.community_follower REFERENCING OLD TABLE AS select_old_rows NEW TABLE AS select_new_rows FOR EACH STATEMENT EXECUTE FUNCTION r.community_follower_update_statement();


--
-- Name: person update_statement; Type: TRIGGER; Schema: public; Owner: lemmy
--

CREATE TRIGGER update_statement AFTER UPDATE ON public.person REFERENCING OLD TABLE AS select_old_rows NEW TABLE AS select_new_rows FOR EACH STATEMENT EXECUTE FUNCTION r.person_update_statement();


--
-- Name: post update_statement; Type: TRIGGER; Schema: public; Owner: lemmy
--

CREATE TRIGGER update_statement AFTER UPDATE ON public.post REFERENCING OLD TABLE AS select_old_rows NEW TABLE AS select_new_rows FOR EACH STATEMENT EXECUTE FUNCTION r.post_update_statement();


--
-- Name: post_like update_statement; Type: TRIGGER; Schema: public; Owner: lemmy
--

CREATE TRIGGER update_statement AFTER UPDATE ON public.post_like REFERENCING OLD TABLE AS select_old_rows NEW TABLE AS select_new_rows FOR EACH STATEMENT EXECUTE FUNCTION r.post_like_update_statement();


--
-- Name: admin_purge_comment admin_purge_comment_admin_person_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.admin_purge_comment
    ADD CONSTRAINT admin_purge_comment_admin_person_id_fkey FOREIGN KEY (admin_person_id) REFERENCES public.person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: admin_purge_comment admin_purge_comment_post_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.admin_purge_comment
    ADD CONSTRAINT admin_purge_comment_post_id_fkey FOREIGN KEY (post_id) REFERENCES public.post(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: admin_purge_community admin_purge_community_admin_person_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.admin_purge_community
    ADD CONSTRAINT admin_purge_community_admin_person_id_fkey FOREIGN KEY (admin_person_id) REFERENCES public.person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: admin_purge_person admin_purge_person_admin_person_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.admin_purge_person
    ADD CONSTRAINT admin_purge_person_admin_person_id_fkey FOREIGN KEY (admin_person_id) REFERENCES public.person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: admin_purge_post admin_purge_post_admin_person_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.admin_purge_post
    ADD CONSTRAINT admin_purge_post_admin_person_id_fkey FOREIGN KEY (admin_person_id) REFERENCES public.person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: admin_purge_post admin_purge_post_community_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.admin_purge_post
    ADD CONSTRAINT admin_purge_post_community_id_fkey FOREIGN KEY (community_id) REFERENCES public.community(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: comment_aggregates comment_aggregates_comment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.comment_aggregates
    ADD CONSTRAINT comment_aggregates_comment_id_fkey FOREIGN KEY (comment_id) REFERENCES public.comment(id) ON UPDATE CASCADE ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED;


--
-- Name: comment comment_creator_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.comment
    ADD CONSTRAINT comment_creator_id_fkey FOREIGN KEY (creator_id) REFERENCES public.person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: comment comment_language_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.comment
    ADD CONSTRAINT comment_language_id_fkey FOREIGN KEY (language_id) REFERENCES public.language(id);


--
-- Name: comment_like comment_like_comment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.comment_like
    ADD CONSTRAINT comment_like_comment_id_fkey FOREIGN KEY (comment_id) REFERENCES public.comment(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: comment_like comment_like_person_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.comment_like
    ADD CONSTRAINT comment_like_person_id_fkey FOREIGN KEY (person_id) REFERENCES public.person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: comment_like comment_like_post_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.comment_like
    ADD CONSTRAINT comment_like_post_id_fkey FOREIGN KEY (post_id) REFERENCES public.post(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: comment comment_post_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.comment
    ADD CONSTRAINT comment_post_id_fkey FOREIGN KEY (post_id) REFERENCES public.post(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: comment_reply comment_reply_comment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.comment_reply
    ADD CONSTRAINT comment_reply_comment_id_fkey FOREIGN KEY (comment_id) REFERENCES public.comment(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: comment_reply comment_reply_recipient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.comment_reply
    ADD CONSTRAINT comment_reply_recipient_id_fkey FOREIGN KEY (recipient_id) REFERENCES public.person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: comment_report comment_report_comment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.comment_report
    ADD CONSTRAINT comment_report_comment_id_fkey FOREIGN KEY (comment_id) REFERENCES public.comment(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: comment_report comment_report_creator_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.comment_report
    ADD CONSTRAINT comment_report_creator_id_fkey FOREIGN KEY (creator_id) REFERENCES public.person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: comment_report comment_report_resolver_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.comment_report
    ADD CONSTRAINT comment_report_resolver_id_fkey FOREIGN KEY (resolver_id) REFERENCES public.person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: comment_saved comment_saved_comment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.comment_saved
    ADD CONSTRAINT comment_saved_comment_id_fkey FOREIGN KEY (comment_id) REFERENCES public.comment(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: comment_saved comment_saved_person_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.comment_saved
    ADD CONSTRAINT comment_saved_person_id_fkey FOREIGN KEY (person_id) REFERENCES public.person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: community_aggregates community_aggregates_community_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.community_aggregates
    ADD CONSTRAINT community_aggregates_community_id_fkey FOREIGN KEY (community_id) REFERENCES public.community(id) ON UPDATE CASCADE ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED;


--
-- Name: community_block community_block_community_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.community_block
    ADD CONSTRAINT community_block_community_id_fkey FOREIGN KEY (community_id) REFERENCES public.community(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: community_block community_block_person_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.community_block
    ADD CONSTRAINT community_block_person_id_fkey FOREIGN KEY (person_id) REFERENCES public.person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: community_follower community_follower_community_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.community_follower
    ADD CONSTRAINT community_follower_community_id_fkey FOREIGN KEY (community_id) REFERENCES public.community(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: community_follower community_follower_person_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.community_follower
    ADD CONSTRAINT community_follower_person_id_fkey FOREIGN KEY (person_id) REFERENCES public.person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: community community_instance_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.community
    ADD CONSTRAINT community_instance_id_fkey FOREIGN KEY (instance_id) REFERENCES public.instance(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: community_language community_language_community_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.community_language
    ADD CONSTRAINT community_language_community_id_fkey FOREIGN KEY (community_id) REFERENCES public.community(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: community_language community_language_language_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.community_language
    ADD CONSTRAINT community_language_language_id_fkey FOREIGN KEY (language_id) REFERENCES public.language(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: community_moderator community_moderator_community_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.community_moderator
    ADD CONSTRAINT community_moderator_community_id_fkey FOREIGN KEY (community_id) REFERENCES public.community(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: community_moderator community_moderator_person_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.community_moderator
    ADD CONSTRAINT community_moderator_person_id_fkey FOREIGN KEY (person_id) REFERENCES public.person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: community_person_ban community_person_ban_community_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.community_person_ban
    ADD CONSTRAINT community_person_ban_community_id_fkey FOREIGN KEY (community_id) REFERENCES public.community(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: community_person_ban community_person_ban_person_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.community_person_ban
    ADD CONSTRAINT community_person_ban_person_id_fkey FOREIGN KEY (person_id) REFERENCES public.person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: custom_emoji_keyword custom_emoji_keyword_custom_emoji_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.custom_emoji_keyword
    ADD CONSTRAINT custom_emoji_keyword_custom_emoji_id_fkey FOREIGN KEY (custom_emoji_id) REFERENCES public.custom_emoji(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: custom_emoji custom_emoji_local_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.custom_emoji
    ADD CONSTRAINT custom_emoji_local_site_id_fkey FOREIGN KEY (local_site_id) REFERENCES public.local_site(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: email_verification email_verification_local_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.email_verification
    ADD CONSTRAINT email_verification_local_user_id_fkey FOREIGN KEY (local_user_id) REFERENCES public.local_user(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: federation_allowlist federation_allowlist_instance_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.federation_allowlist
    ADD CONSTRAINT federation_allowlist_instance_id_fkey FOREIGN KEY (instance_id) REFERENCES public.instance(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: federation_blocklist federation_blocklist_instance_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.federation_blocklist
    ADD CONSTRAINT federation_blocklist_instance_id_fkey FOREIGN KEY (instance_id) REFERENCES public.instance(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: federation_queue_state federation_queue_state_instance_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.federation_queue_state
    ADD CONSTRAINT federation_queue_state_instance_id_fkey FOREIGN KEY (instance_id) REFERENCES public.instance(id);


--
-- Name: local_image image_upload_local_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.local_image
    ADD CONSTRAINT image_upload_local_user_id_fkey FOREIGN KEY (local_user_id) REFERENCES public.local_user(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: instance_block instance_block_instance_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.instance_block
    ADD CONSTRAINT instance_block_instance_id_fkey FOREIGN KEY (instance_id) REFERENCES public.instance(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: instance_block instance_block_person_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.instance_block
    ADD CONSTRAINT instance_block_person_id_fkey FOREIGN KEY (person_id) REFERENCES public.person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: local_site_rate_limit local_site_rate_limit_local_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.local_site_rate_limit
    ADD CONSTRAINT local_site_rate_limit_local_site_id_fkey FOREIGN KEY (local_site_id) REFERENCES public.local_site(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: local_site local_site_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.local_site
    ADD CONSTRAINT local_site_site_id_fkey FOREIGN KEY (site_id) REFERENCES public.site(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: local_user_language local_user_language_language_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.local_user_language
    ADD CONSTRAINT local_user_language_language_id_fkey FOREIGN KEY (language_id) REFERENCES public.language(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: local_user_language local_user_language_local_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.local_user_language
    ADD CONSTRAINT local_user_language_local_user_id_fkey FOREIGN KEY (local_user_id) REFERENCES public.local_user(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: local_user local_user_person_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.local_user
    ADD CONSTRAINT local_user_person_id_fkey FOREIGN KEY (person_id) REFERENCES public.person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: local_user_vote_display_mode local_user_vote_display_mode_local_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.local_user_vote_display_mode
    ADD CONSTRAINT local_user_vote_display_mode_local_user_id_fkey FOREIGN KEY (local_user_id) REFERENCES public.local_user(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: login_token login_token_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.login_token
    ADD CONSTRAINT login_token_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.local_user(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: mod_add_community mod_add_community_community_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.mod_add_community
    ADD CONSTRAINT mod_add_community_community_id_fkey FOREIGN KEY (community_id) REFERENCES public.community(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: mod_add_community mod_add_community_mod_person_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.mod_add_community
    ADD CONSTRAINT mod_add_community_mod_person_id_fkey FOREIGN KEY (mod_person_id) REFERENCES public.person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: mod_add_community mod_add_community_other_person_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.mod_add_community
    ADD CONSTRAINT mod_add_community_other_person_id_fkey FOREIGN KEY (other_person_id) REFERENCES public.person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: mod_add mod_add_mod_person_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.mod_add
    ADD CONSTRAINT mod_add_mod_person_id_fkey FOREIGN KEY (mod_person_id) REFERENCES public.person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: mod_add mod_add_other_person_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.mod_add
    ADD CONSTRAINT mod_add_other_person_id_fkey FOREIGN KEY (other_person_id) REFERENCES public.person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: mod_ban_from_community mod_ban_from_community_community_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.mod_ban_from_community
    ADD CONSTRAINT mod_ban_from_community_community_id_fkey FOREIGN KEY (community_id) REFERENCES public.community(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: mod_ban_from_community mod_ban_from_community_mod_person_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.mod_ban_from_community
    ADD CONSTRAINT mod_ban_from_community_mod_person_id_fkey FOREIGN KEY (mod_person_id) REFERENCES public.person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: mod_ban_from_community mod_ban_from_community_other_person_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.mod_ban_from_community
    ADD CONSTRAINT mod_ban_from_community_other_person_id_fkey FOREIGN KEY (other_person_id) REFERENCES public.person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: mod_ban mod_ban_mod_person_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.mod_ban
    ADD CONSTRAINT mod_ban_mod_person_id_fkey FOREIGN KEY (mod_person_id) REFERENCES public.person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: mod_ban mod_ban_other_person_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.mod_ban
    ADD CONSTRAINT mod_ban_other_person_id_fkey FOREIGN KEY (other_person_id) REFERENCES public.person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: mod_hide_community mod_hide_community_community_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.mod_hide_community
    ADD CONSTRAINT mod_hide_community_community_id_fkey FOREIGN KEY (community_id) REFERENCES public.community(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: mod_hide_community mod_hide_community_mod_person_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.mod_hide_community
    ADD CONSTRAINT mod_hide_community_mod_person_id_fkey FOREIGN KEY (mod_person_id) REFERENCES public.person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: mod_lock_post mod_lock_post_mod_person_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.mod_lock_post
    ADD CONSTRAINT mod_lock_post_mod_person_id_fkey FOREIGN KEY (mod_person_id) REFERENCES public.person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: mod_lock_post mod_lock_post_post_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.mod_lock_post
    ADD CONSTRAINT mod_lock_post_post_id_fkey FOREIGN KEY (post_id) REFERENCES public.post(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: mod_remove_comment mod_remove_comment_comment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.mod_remove_comment
    ADD CONSTRAINT mod_remove_comment_comment_id_fkey FOREIGN KEY (comment_id) REFERENCES public.comment(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: mod_remove_comment mod_remove_comment_mod_person_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.mod_remove_comment
    ADD CONSTRAINT mod_remove_comment_mod_person_id_fkey FOREIGN KEY (mod_person_id) REFERENCES public.person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: mod_remove_community mod_remove_community_community_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.mod_remove_community
    ADD CONSTRAINT mod_remove_community_community_id_fkey FOREIGN KEY (community_id) REFERENCES public.community(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: mod_remove_community mod_remove_community_mod_person_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.mod_remove_community
    ADD CONSTRAINT mod_remove_community_mod_person_id_fkey FOREIGN KEY (mod_person_id) REFERENCES public.person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: mod_remove_post mod_remove_post_mod_person_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.mod_remove_post
    ADD CONSTRAINT mod_remove_post_mod_person_id_fkey FOREIGN KEY (mod_person_id) REFERENCES public.person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: mod_remove_post mod_remove_post_post_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.mod_remove_post
    ADD CONSTRAINT mod_remove_post_post_id_fkey FOREIGN KEY (post_id) REFERENCES public.post(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: mod_feature_post mod_sticky_post_mod_person_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.mod_feature_post
    ADD CONSTRAINT mod_sticky_post_mod_person_id_fkey FOREIGN KEY (mod_person_id) REFERENCES public.person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: mod_feature_post mod_sticky_post_post_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.mod_feature_post
    ADD CONSTRAINT mod_sticky_post_post_id_fkey FOREIGN KEY (post_id) REFERENCES public.post(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: mod_transfer_community mod_transfer_community_community_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.mod_transfer_community
    ADD CONSTRAINT mod_transfer_community_community_id_fkey FOREIGN KEY (community_id) REFERENCES public.community(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: mod_transfer_community mod_transfer_community_mod_person_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.mod_transfer_community
    ADD CONSTRAINT mod_transfer_community_mod_person_id_fkey FOREIGN KEY (mod_person_id) REFERENCES public.person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: mod_transfer_community mod_transfer_community_other_person_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.mod_transfer_community
    ADD CONSTRAINT mod_transfer_community_other_person_id_fkey FOREIGN KEY (other_person_id) REFERENCES public.person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: password_reset_request password_reset_request_local_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.password_reset_request
    ADD CONSTRAINT password_reset_request_local_user_id_fkey FOREIGN KEY (local_user_id) REFERENCES public.local_user(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: person_aggregates person_aggregates_person_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.person_aggregates
    ADD CONSTRAINT person_aggregates_person_id_fkey FOREIGN KEY (person_id) REFERENCES public.person(id) ON UPDATE CASCADE ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED;


--
-- Name: person_ban person_ban_person_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.person_ban
    ADD CONSTRAINT person_ban_person_id_fkey FOREIGN KEY (person_id) REFERENCES public.person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: person_block person_block_person_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.person_block
    ADD CONSTRAINT person_block_person_id_fkey FOREIGN KEY (person_id) REFERENCES public.person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: person_block person_block_target_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.person_block
    ADD CONSTRAINT person_block_target_id_fkey FOREIGN KEY (target_id) REFERENCES public.person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: person_follower person_follower_follower_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.person_follower
    ADD CONSTRAINT person_follower_follower_id_fkey FOREIGN KEY (follower_id) REFERENCES public.person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: person_follower person_follower_person_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.person_follower
    ADD CONSTRAINT person_follower_person_id_fkey FOREIGN KEY (person_id) REFERENCES public.person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: person person_instance_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.person
    ADD CONSTRAINT person_instance_id_fkey FOREIGN KEY (instance_id) REFERENCES public.instance(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: person_mention person_mention_comment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.person_mention
    ADD CONSTRAINT person_mention_comment_id_fkey FOREIGN KEY (comment_id) REFERENCES public.comment(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: person_mention person_mention_recipient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.person_mention
    ADD CONSTRAINT person_mention_recipient_id_fkey FOREIGN KEY (recipient_id) REFERENCES public.person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: person_post_aggregates person_post_aggregates_person_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.person_post_aggregates
    ADD CONSTRAINT person_post_aggregates_person_id_fkey FOREIGN KEY (person_id) REFERENCES public.person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: person_post_aggregates person_post_aggregates_post_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.person_post_aggregates
    ADD CONSTRAINT person_post_aggregates_post_id_fkey FOREIGN KEY (post_id) REFERENCES public.post(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: post_aggregates post_aggregates_community_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.post_aggregates
    ADD CONSTRAINT post_aggregates_community_id_fkey FOREIGN KEY (community_id) REFERENCES public.community(id) ON UPDATE CASCADE ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED;


--
-- Name: post_aggregates post_aggregates_creator_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.post_aggregates
    ADD CONSTRAINT post_aggregates_creator_id_fkey FOREIGN KEY (creator_id) REFERENCES public.person(id) ON UPDATE CASCADE ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED;


--
-- Name: post_aggregates post_aggregates_instance_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.post_aggregates
    ADD CONSTRAINT post_aggregates_instance_id_fkey FOREIGN KEY (instance_id) REFERENCES public.instance(id) ON UPDATE CASCADE ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED;


--
-- Name: post_aggregates post_aggregates_post_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.post_aggregates
    ADD CONSTRAINT post_aggregates_post_id_fkey FOREIGN KEY (post_id) REFERENCES public.post(id) ON UPDATE CASCADE ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED;


--
-- Name: post post_community_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.post
    ADD CONSTRAINT post_community_id_fkey FOREIGN KEY (community_id) REFERENCES public.community(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: post post_creator_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.post
    ADD CONSTRAINT post_creator_id_fkey FOREIGN KEY (creator_id) REFERENCES public.person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: post_hide post_hide_person_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.post_hide
    ADD CONSTRAINT post_hide_person_id_fkey FOREIGN KEY (person_id) REFERENCES public.person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: post_hide post_hide_post_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.post_hide
    ADD CONSTRAINT post_hide_post_id_fkey FOREIGN KEY (post_id) REFERENCES public.post(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: post post_language_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.post
    ADD CONSTRAINT post_language_id_fkey FOREIGN KEY (language_id) REFERENCES public.language(id);


--
-- Name: post_like post_like_person_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.post_like
    ADD CONSTRAINT post_like_person_id_fkey FOREIGN KEY (person_id) REFERENCES public.person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: post_like post_like_post_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.post_like
    ADD CONSTRAINT post_like_post_id_fkey FOREIGN KEY (post_id) REFERENCES public.post(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: post_read post_read_person_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.post_read
    ADD CONSTRAINT post_read_person_id_fkey FOREIGN KEY (person_id) REFERENCES public.person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: post_read post_read_post_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.post_read
    ADD CONSTRAINT post_read_post_id_fkey FOREIGN KEY (post_id) REFERENCES public.post(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: post_report post_report_creator_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.post_report
    ADD CONSTRAINT post_report_creator_id_fkey FOREIGN KEY (creator_id) REFERENCES public.person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: post_report post_report_post_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.post_report
    ADD CONSTRAINT post_report_post_id_fkey FOREIGN KEY (post_id) REFERENCES public.post(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: post_report post_report_resolver_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.post_report
    ADD CONSTRAINT post_report_resolver_id_fkey FOREIGN KEY (resolver_id) REFERENCES public.person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: post_saved post_saved_person_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.post_saved
    ADD CONSTRAINT post_saved_person_id_fkey FOREIGN KEY (person_id) REFERENCES public.person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: post_saved post_saved_post_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.post_saved
    ADD CONSTRAINT post_saved_post_id_fkey FOREIGN KEY (post_id) REFERENCES public.post(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: private_message private_message_creator_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.private_message
    ADD CONSTRAINT private_message_creator_id_fkey FOREIGN KEY (creator_id) REFERENCES public.person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: private_message private_message_recipient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.private_message
    ADD CONSTRAINT private_message_recipient_id_fkey FOREIGN KEY (recipient_id) REFERENCES public.person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: private_message_report private_message_report_creator_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.private_message_report
    ADD CONSTRAINT private_message_report_creator_id_fkey FOREIGN KEY (creator_id) REFERENCES public.person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: private_message_report private_message_report_private_message_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.private_message_report
    ADD CONSTRAINT private_message_report_private_message_id_fkey FOREIGN KEY (private_message_id) REFERENCES public.private_message(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: private_message_report private_message_report_resolver_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.private_message_report
    ADD CONSTRAINT private_message_report_resolver_id_fkey FOREIGN KEY (resolver_id) REFERENCES public.person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: registration_application registration_application_admin_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.registration_application
    ADD CONSTRAINT registration_application_admin_id_fkey FOREIGN KEY (admin_id) REFERENCES public.person(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: registration_application registration_application_local_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.registration_application
    ADD CONSTRAINT registration_application_local_user_id_fkey FOREIGN KEY (local_user_id) REFERENCES public.local_user(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: site_aggregates site_aggregates_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.site_aggregates
    ADD CONSTRAINT site_aggregates_site_id_fkey FOREIGN KEY (site_id) REFERENCES public.site(id) ON UPDATE CASCADE ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED;


--
-- Name: site site_instance_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.site
    ADD CONSTRAINT site_instance_id_fkey FOREIGN KEY (instance_id) REFERENCES public.instance(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: site_language site_language_language_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.site_language
    ADD CONSTRAINT site_language_language_id_fkey FOREIGN KEY (language_id) REFERENCES public.language(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: site_language site_language_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.site_language
    ADD CONSTRAINT site_language_site_id_fkey FOREIGN KEY (site_id) REFERENCES public.site(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: tagline tagline_local_site_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: lemmy
--

ALTER TABLE ONLY public.tagline
    ADD CONSTRAINT tagline_local_site_id_fkey FOREIGN KEY (local_site_id) REFERENCES public.local_site(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

