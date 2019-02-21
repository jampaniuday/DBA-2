

--  ----------------------------------------------------------------------------------------------------
--
--  FILE NAME      : STATEMENTS_WITHOUT_BINDS.SQL
--  DESCRIPTION    : Look for statements without bind variables
--  AUTHOR         : Antonio NAVARRO - /\/\/
--  CREATE         : 11.08.10
--  LAST MODIFIED  : 11.08.10
--  USAGE          : Look for statements without bind variables
--  CALL SYNTAXIS  : @statements_without_binds.sql 
--  [NOTES]        :
--   
--  ----------------------------------------------------------------------------------------------------



set pages 1000
set lines 1000
set echo on 

column schema format a20
column sql_text format a80 
WITH force_matches AS
       (SELECT force_matching_signature,
               COUNT( * )  matches,
               MAX(sql_id || child_number) max_sql_child,
               DENSE_RANK() OVER (ORDER BY COUNT( * ) DESC)
                  ranking
        FROM v$sql
        WHERE force_matching_signature <> 0
          AND parsing_schema_name <> 'SYS'
        GROUP BY force_matching_signature
        HAVING COUNT( * ) > 5)
SELECT sql_id,  matches, parsing_schema_name schema, sql_text
  FROM    v$sql JOIN force_matches
    ON (sql_id || child_number = max_sql_child)
WHERE ranking <= 10
ORDER BY matches DESC; 

