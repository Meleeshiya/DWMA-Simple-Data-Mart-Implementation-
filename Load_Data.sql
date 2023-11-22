-- For the data loading into tables
-- Load data into dimensions and fact table
-- Load data into TIME_DIM

DROP sequence time_seq;

create sequence time_seq
start with 1
increment by 1
maxvalue 10000
minvalue 1;

DROP table tmp_years;

Create table tmp_years as SELECT DISTINCT PRESENTING_YEAR FROM STUVLEINFO_S2STAGE
AREA;

INSERT INTO TIME_DIM SELECT time_seq.nextval, PRESENTING_YEAR FROM tmp_years;

-- Loading data into VLE_DIM

DROP sequence vle_seq;

create sequence vle_seq
start with 1
increment by 1
maxvalue 10000
minvalue 1;

INSERT INTO VLE_DIM SELECT vle_seq.nextval, VLE_MATERIAL_TYPE, VLE_MATERIAL_TYPE,
ROW_EFFECTIVE_DATE,ROW_EXPIRATION_DATE,CURRENT_ROW_INDICATOR FROM tmp_vleType;

-- Load data into dimensions and fact table
-- Load data into TIME_DIM

DROP sequence fact_seq;

create sequence fact_seq
start with 1
increment by 1
maxvalue 10000
minvalue 1;

-- create a table to get all the no of days, activity types and years by Joining VLEINFO_S1STAGEAREA and STUVLEINFO_S2STAGEAREA

DROP table tmp_fact_table1;
CREATE TABLE tmp_fact_table1 AS SELECT SV.PRESENTING_YEAR, V.VLE_MATERIAL_TYPE, SV.NO_OF_DAYS, SV.SUM_CLICK
FROM STUVLEINFO_S2STAGEAREA SV
INNER JOIN VLEINFO_S1STAGEAREA V ON SV.ID_SITE=V.ID_SITE;

select count (*) from tmp_fact_table1;

-- GROUP BY ACTIVITY TYPE AND PRESENTING YEAR

DROP table tmp_fact_table2;
CREATE TABLE tmp_fact_table2 AS SELECT PRESENTING_YEAR, VLE_MATERIAL_TYPE, SUM(NO_OF_DAYS) AS TOTAL_NO_OFDAYS , SUM(SUM_CLICK) AS TOTAL_SUMCLICKS FROM tmp_fact_table1
GROUP BY PRESENTING_YEAR, VLE_MTERIAL_TYPE ;

select count (*) from tmp_fact_table2;

-- Inserting data into fact_table

INSERT INTO FACT_TABLE (FACT_ID, FK1_VLE_ID, FK2_TIME_ID , NO_OF_DAYS,TOTAL_SUMCLICKS)

SELECT fact_seq.nextval, VLE_DIM.VLE_ID,TIME_DIM.TIME_ID, TMP_FACT_TABLE2.TOTAL_
NO_OFDAYS, TMP_FACT_TABLE2.TOTAL_SUMCLICKS
FROM TIME_DIM, VLE_DIM, TMP_FACT_TABLE2
WHERE TMP_FACT_TABLE2.PRESENTING_YEAR = TIME_DIM.THE_YEAR AND TMP_FACT_TABLE2.VLE_MATERIAL_TYPE = VLE_DIM.CURRENT_VLE_MATERIALTYPE;

Select * from FACT_TABLE;