{{ config(materialized="table", schema="silver") }}
with cleaned_cricket as (
    SELECT
        delivery_id,
        case
            when TRY_CAST(delivery_timestamp as datetime) is not null 
            then cast(delivery_timestamp as datetime)
            when TRY_CAST(CONCAT(
                substring(delivery_timestamp, 7, 4), '-',
                SUBSTRING(delivery_timestamp, 4, 2), '-',
                SUBSTRING(delivery_timestamp, 1, 2), ' ',
                SUBSTRING(delivery_timestamp, 12, 5)
            ) as datetime) is not null 
            then cast(CONCAT(
                substring(delivery_timestamp, 7, 4), '-',
                SUBSTRING(delivery_timestamp, 4, 2), '-',
                SUBSTRING(delivery_timestamp, 1, 2), ' ',
                SUBSTRING(delivery_timestamp, 12, 5)
            ) as datetime)
            else null
        end as delivery_timestamp,
        innings_no,
        over_no,
        ball_in_over,
        runs_off_bat,
        extra_type,
        extra_runs,
        total_runs,
        is_wicket,
        dismissal_type,
        ball_speed,
        non_striker_id,
        shot_type,
        shot_region,
        match_id,
        case
            when TRY_CAST(match_date as date) is not null
            then cast(match_date as date)
            when TRY_CAST(concat(
            substring(match_date, 7, 4), '-',
            substring(match_date, 4, 2), '-',
            substring(match_date, 1, 2)
            ) as date) is not null 
            then CAST(concat(
            substring(match_date, 7, 4), '-',
            substring(match_date, 4, 2), '-',
            substring(match_date, 1, 2)
            ) as date)
            else null
        end as match_date,
        match_format,
        tournament_name,
        season,
        match_stage,
        toss_decision,
        venue_id,
        concat(upper(substring(trim(venue_name), 1, 1)),
        lower(substring(trim(venue_name), 2, len(trim(venue_name))-1))) as venue_name,
        concat(upper(substring(trim(venue_city), 1, 1)),
        lower(substring(trim(venue_city), 2, len(trim(venue_city))-1))) as venue_city,
        venue_country,
        batting_team_id,
        case when trim(batting_team_name) like '% %' then
        concat(upper(substring(trim(batting_team_name),1 ,1)), 
        lower(substring(trim(batting_team_name), 2, 
        CHARINDEX(' ', trim(batting_team_name))-2))
        ,' ',
        upper(substring(trim(batting_team_name), 
        CHARINDEX(' ', trim(batting_team_name))+1, 1)),
        lower(substring(trim(batting_team_name), 
        CHARINDEX(' ', trim(batting_team_name))+2, len(trim(batting_team_name))-
        CHARINDEX(' ', trim(batting_team_name))-1)))
        else concat(upper(substring(trim(batting_team_name), 1, 1)),
        lower(substring(trim(batting_team_name), 2, len(trim(batting_team_name))-1)))
        end as batting_team_name,
        bowling_team_id,
        case when trim(bowling_team_name) like '% %' then
        concat(upper(substring(trim(bowling_team_name),1 ,1)), 
        lower(substring(trim(bowling_team_name), 2, 
        CHARINDEX(' ', trim(bowling_team_name))-2))
        ,' ',
        upper(substring(trim(bowling_team_name), 
        CHARINDEX(' ', trim(bowling_team_name))+1, 1)),
        lower(substring(trim(bowling_team_name), 
        CHARINDEX(' ', trim(bowling_team_name))+2, len(trim(bowling_team_name))-
        CHARINDEX(' ', trim(bowling_team_name))-1)))
        else concat(upper(substring(trim(bowling_team_name), 1, 1)),
        lower(substring(trim(bowling_team_name), 2, len(trim(bowling_team_name))-1))) end
        as bowling_team_name,
        batsman_id,
        concat(upper(substring(trim(batsman_name),1 ,1)), 
        lower(substring(trim(batsman_name), 2, 
        CHARINDEX(' ', trim(batsman_name))-2))
        ,' ',
        upper(substring(trim(batsman_name), 
        CHARINDEX(' ', trim(batsman_name))+1, 1)),
        lower(substring(trim(batsman_name), 
        CHARINDEX(' ', trim(batsman_name))+2, len(trim(batsman_name))-
        CHARINDEX(' ', trim(batsman_name))-1)))
        as batsman_name,
        case
            when try_cast(batsman_dob as date) is not null
            then cast(batsman_dob as date)
            when try_cast(concat(
                substring(batsman_dob, 7, 4), '-',
                substring(batsman_dob, 1, 2), '-',
                substring(batsman_dob, 4, 2)
            ) as date) is not null then cast(concat(
                substring(batsman_dob, 7, 4), '-',
                substring(batsman_dob, 1, 2), '-',
                substring(batsman_dob, 4, 2)
            ) as date)
            when try_cast(concat(
                substring(batsman_dob, 7, 4), '-',
                substring(batsman_dob, 4, 2), '-',
                substring(batsman_dob, 1, 2)
            ) as date) is not null then cast(concat(
                substring(batsman_dob, 7, 4), '-',
                substring(batsman_dob, 4, 2), '-',
                substring(batsman_dob, 1, 2)
            ) as date)
            else null
        end as batsman_dob,
        batsman_nationality,
        batting_hand,
        batsman_role,
        lower(trim(batsman_email)) as batsman_email,
        batsman_phone,
        batsman_icc_rating,
        bowler_id,
        concat(upper(substring(trim(bowler_name),1 ,1)), 
        lower(substring(trim(bowler_name), 2, 
        CHARINDEX(' ', trim(bowler_name))-2))
        ,' ',
        upper(substring(trim(bowler_name), 
        CHARINDEX(' ', trim(bowler_name))+1, 1)),
        lower(substring(trim(bowler_name), 
        CHARINDEX(' ', trim(bowler_name))+2, len(trim(bowler_name))-
        CHARINDEX(' ', trim(bowler_name))-1)))
        as bowler_name,
        bowler_nationality,
        bowling_style,
        bowler_icc_rating,
        contract_id,
        contract_grade,
        annual_retainer_usd,
        contract_status,
        drs_review_id,
        drs_reviewed_by,
        drs_original_decision,
        drs_outcome
    FROM {{ source("bronze", "raw_cricket") }}
)
select *
from cleaned_cricket;