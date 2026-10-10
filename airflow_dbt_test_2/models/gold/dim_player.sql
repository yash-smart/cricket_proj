{{ config(materialized="table", schema="gold") }}
with player_details_combined as (
	select batsman_id as player_id, batsman_name as player_name, batsman_dob as player_dob, 
	batsman_nationality as player_nationality,
	batting_hand as player_batting_hand, batsman_role as player_role, batsman_email as player_email, 
	batsman_phone as player_phone, batsman_icc_rating as player_icc_rating_bat, null as player_icc_rating_bowl
	, null as bowling_style, delivery_timestamp as active_date
	from {{ ref("silver_cricket") }}
	union all
	select bowler_id as player_id, bowler_name as player_name, null as player_dob, 
	bowler_nationality as player_nationality,
	null as player_batting_hand, null as player_role, null as player_email, null as player_phone, 
	null as player_icc_rating_bat, bowler_icc_rating as player_icc_rating_bowl, bowling_style, 
	delivery_timestamp as active_date
	from {{ ref("silver_cricket") }}
), player_group as (
	select *, 
	sum(case when player_name is null then 0 else 1 end) over(PARTITION BY player_id ORDER BY active_date) as row_player_name,
	sum(case when player_dob is null then 0 else 1 end) over(PARTITION BY player_id ORDER BY active_date) as row_player_dob,
	sum(case when player_nationality is null then 0 else 1 end) over(PARTITION BY player_id ORDER BY active_date) as row_player_nationality,
	sum(case when player_batting_hand is null then 0 else 1 end) over(PARTITION BY player_id ORDER BY active_date) as row_player_batting_hand,
	sum(case when player_role is null then 0 else 1 end) over(PARTITION BY player_id ORDER BY active_date) as row_player_role,
	sum(case when player_email is null then 0 else 1 end) over(PARTITION BY player_id ORDER BY active_date) as row_player_email,
	sum(case when player_phone is null then 0 else 1 end) over(PARTITION BY player_id ORDER BY active_date) as row_player_phone,
	sum(case when player_icc_rating_bat is null then 0 else 1 end) over(PARTITION BY player_id ORDER BY active_date) as row_player_icc_rating_bat,
	sum(case when player_icc_rating_bowl is null then 0 else 1 end) over(PARTITION BY player_id ORDER BY active_date) as row_player_icc_rating_bowl,
	sum(case when bowling_style is null then 0 else 1 end) over(PARTITION BY player_id ORDER BY active_date) as row_bowling_style
	from player_details_combined
),
prev_data as (
	select 
		player_id,
		player_name,
		player_dob,
		player_nationality,
		player_batting_hand,
		player_role,
		player_email,
		player_phone,
		player_icc_rating_bat,
		player_icc_rating_bowl,
		bowling_style,
		active_date, 
		FIRST_VALUE(player_name) over (PARTITION BY player_id ORDER BY row_player_name desc, active_date) as prev_player_name,
		FIRST_VALUE(player_dob) over (PARTITION BY player_id ORDER BY row_player_dob desc, active_date) as prev_player_dob,
		first_value(player_nationality) over (PARTITION BY player_id ORDER BY row_player_nationality desc, active_date) as prev_player_nationality,
		first_value(player_batting_hand) over (PARTITION BY player_id ORDER BY row_player_batting_hand desc, active_date) as prev_player_batting_hand,
		first_value(player_role) over (PARTITION BY player_id ORDER BY row_player_role desc, active_date) as prev_player_role,
		first_value(player_email) over (PARTITION BY player_id ORDER BY row_player_email desc, active_date) as prev_player_email,
		first_value(player_phone) over (PARTITION BY player_id ORDER BY row_player_phone desc, active_date) as prev_player_phone,
		first_value(player_icc_rating_bat) over (PARTITION BY player_id ORDER BY row_player_icc_rating_bat desc, active_date) as prev_player_icc_rating_bat,
		first_value(player_icc_rating_bowl) over (PARTITION BY player_id ORDER BY row_player_icc_rating_bowl desc, active_date) as prev_player_icc_rating_bowl,
		first_value(bowling_style) over (PARTITION BY player_id ORDER BY row_bowling_style desc, active_date) as prev_bowling_style
	from player_group
)
select
	player_id,
	case when player_name is null then prev_player_name else player_name end as player_name,
    case when player_dob is null then prev_player_dob else player_dob end as player_dob,
    case when player_nationality is null then prev_player_nationality else player_nationality end as player_nationality,
    case when player_batting_hand is null then prev_player_batting_hand else player_batting_hand end as player_batting_hand,
    case when player_role is null then prev_player_role else player_role end as player_role,
    case when player_email is null then prev_player_email else player_email end as player_email,
    case when player_phone is null then prev_player_phone else player_phone end as player_phone,
    case when player_icc_rating_bat is null then prev_player_icc_rating_bat else player_icc_rating_bat end as player_icc_rating_bat,
    case when player_icc_rating_bowl is null then prev_player_icc_rating_bowl else player_icc_rating_bowl end as player_icc_rating_bowl,
    case when bowling_style is null then prev_bowling_style else bowling_style end as bowling_style,
	active_date
from prev_data;
