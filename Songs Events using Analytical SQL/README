#Data Analysis Project

##Introduction
This project contains various SQL queries and scripts for analyzing song play events. The database schema and queries are designed to extract meaningful insights from the song play data.

## Features
1.**Rank Users by Distinct Songs Played**:
   - Rank users according to the number of distinct songs they played. Users with the same count share the same rank.
   - Rank users with unique ranks even if they have the same count of distinct songs played.

2.**Next Song in Session**:
   - Identify the next song a user listened to during a session. For the last song in the session, "No Next" is displayed.

3.**Third Highest User by Paid Songs**:
   - Select the third highest user who listened to paid songs.

4.**First and Last Song per Session**:
   - Select the user, session, first song, and last song played per session.

5.**Longest Session Duration**:
   - Identify the user with the longest session duration using the timestamp column.

6.**Songs Played in 2-Hour Interval**:
   - Calculate the count of songs that the user played during a 2-hour interval (1 hour before and 1 hour after).

##Database Schema
The database schema for the `Songs_Events` table is as follows:

```sql
CREATE TABLE IF NOT EXISTS Songs_Events(
   artist        VARCHAR(100),
   auth          VARCHAR(10),
   firstName     VARCHAR(10),
   gender        VARCHAR(1),
   itemInSession INTEGER,
   lastName      VARCHAR(9),
   length        VARCHAR(25),
   level         VARCHAR(4),
   location      VARCHAR(46),
   method        VARCHAR(3),
   page          VARCHAR(16),
   registration  NUMERIC(15,1),
   sessionId     INTEGER,
   song          VARCHAR(200),
   status        BIGINT,
   ts            BIGINT,
   userAgent     VARCHAR(139),
   userId        BIGINT
);
