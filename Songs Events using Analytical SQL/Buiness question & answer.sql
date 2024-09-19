--1-Rank users according to the number of distinct songs they played. If two users shared the same counts, they should have the same rank
   select userid 
, count(distinct song) as number_of_songs 
, rank() over(order by count(distinct song) desc) as ranking
from songs_events
group by 1

--2-Rank users according to the number of distinct songs they played. If two users shared the same counts, each user should have his/her own number.
select userid 
, count(distinct song) as number_of_songs 
, row_number() over(order by count(distinct song) desc) as ranking
from songs_events
group by 1

--3-Find the next song a user listened to during the session
         PS: for the last song in the session print "No Next" 
select userid , sessionid , ts , song
 , lead( song , 1, 'No Next') over( partition by sessionid order by ts) as Next_song
FROM songs_events
where page = 'NextSong'

--4-Select the third highest userid who listened to paid songs
select userid , "No.Paid Songs"
from
(
	select userid, count(song) "No.Paid Songs"
	, dense_rank() over(order by count(song) desc) as dn
	from songs_events
	where level = 'paid'
	group by  userid) tab
where tab.dn = 3

--5-Select the user, session, first song and last song played per session
select distinct userid , sessionid
, FIRST_VALUE (song) over( partition by sessionid  order by ts ) "First Song"
, FIRST_VALUE (song) over( partition by sessionid  order by ts desc ) "Last Song"
from songs_events
where page='NextSong'
order by userid , sessionid

--6.Select the userId of the longest session duration using time_stamp column
select distinct userid ,  sessionid
,(last_value(ts)over(partition by sessionid order by ts rows between unbounded preceding and unbounded following )
- first_value(ts)over(partition by sessionid order by ts)) / 1000 / 60 duration_in_mins
from songs_events
where userid is not null
order by duration_in_mins desc
limit 1

--7.For each song in this session Calculate the count of songs that the user played during 2 hours interval (1 hour before and 1 hour after)
select * from songs_events
select distinct sessionid , song , timezone('America/New_york' ,  to_timestamp(ts/1000)) timezone
, count(*) over(partition by sessionid order by timezone('America/New_york' ,  to_timestamp(ts/1000)) range between interval '1' hour preceding 
                                                                    and interval '1' hour following)
from songs_events
where song is not null
order by sessionid , timezone
