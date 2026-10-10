import pymssql
import csv
import os

db_password = None
with open(".env", "r") as env_f:
    db_password = env_f.read()

conn = pymssql.connect(
    server="localhost",
    database="cricket",
    autocommit=False,
    user="sa",
    password=db_password
)

cursor = conn.cursor()

data_folder = r"C:\Yash\KenexAI\airflow_dbt_test_2\Data"
files_to_be_loaded = []
listdir = os.listdir(data_folder)
for i in listdir:
    # print(i)
    if i.split('.')[-1] == 'csv':
        # print(i)
        files_to_be_loaded.append(i)

files_loaded_query = """
    select distinct _file_name
    from bronze.raw_cricket
"""

exec_obj = cursor.execute(files_loaded_query)
files_loaded = set()
files_loaded_list = cursor.fetchall()
for i in files_loaded_list:
    files_loaded.add(i[0])
print(files_loaded)
for file in files_to_be_loaded:
    
    if file not in files_loaded:
        cursor.execute("DROP TABLE IF EXISTS bronze.temp")
        conn.commit()
        cursor.execute("""create table bronze.temp(
            delivery_id varchar(MAX),
            delivery_timestamp varchar(MAX),
            innings_no int,
            over_no int,
            ball_in_over int,
            runs_off_bat int,
            extra_type varchar(MAX),
            extra_runs int,
            total_runs int,
            is_wicket varchar(MAX),
            dismissal_type varchar(MAX),
            ball_speed float,
            non_striker_id varchar(MAX),
            shot_type varchar(MAX),
            shot_region varchar(MAX),
            match_id varchar(MAX),
            match_date varchar(MAX),
            match_format varchar(MAX),
            tournament_name varchar(MAX),
            season int,
            match_stage varchar(MAX),
            toss_decision varchar(MAX),
            venue_id varchar(MAX),
            venue_name varchar(MAX),
            venue_city varchar(MAX),
            venue_country varchar(MAX),
            batting_team_id varchar(MAX),
            batting_team_name varchar(MAX),
            bowling_team_id varchar(MAX),
            bowling_team_name varchar(MAX),
            batsman_id varchar(MAX),
            batsman_name varchar(MAX),
            batsman_dob varchar(MAX),
            batsman_nationality varchar(MAX),
            batting_hand varchar(MAX),
            batsman_role varchar(MAX),
            batsman_email varchar(MAX),
            batsman_phone varchar(MAX),
            batsman_icc_rating int,
            bowler_id varchar(MAX),
            bowler_name varchar(MAX),
            bowler_nationality varchar(MAX),
            bowling_style varchar(MAX),
            bowler_icc_rating int,
            contract_id varchar(MAX),
            contract_grade varchar(MAX),
            annual_retainer_usd float,
            contract_status varchar(MAX),
            drs_review_id varchar(MAX),
            drs_reviewed_by varchar(MAX),
            drs_original_decision varchar(MAX),
            drs_outcome varchar(MAX)
        )""")
        conn.commit()
        cursor.execute("delete from bronze.temp")
        conn.commit()
        query = f"""
        BULK INSERT bronze.temp
        FROM '{data_folder}\\{file}'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '\\n',
            TABLOCK
        );
"""
        cursor.execute(query)
        conn.commit()
        cursor.execute(f"""
        INSERT INTO bronze.raw_cricket
        SELECT *, '{file}' as _file_name
        from bronze.temp
""")
        conn.commit()
        cursor.execute("DROP TABLE bronze.temp")
        conn.commit()
print("Files loaded successfully")