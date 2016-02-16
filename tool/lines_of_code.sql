SELECT o.type_desc                                                        AS ROUTINE_TYPE
       , QUOTENAME(s.[name]) + '.'
         + QUOTENAME(o.[name])                                            AS [OBJECT_NAME]
       , ( LEN(m.definition) - LEN(REPLACE(m.definition, CHAR(10), '')) ) AS LINES_OF_CODE
FROM   sys.sql_modules AS m
       INNER JOIN sys.objects AS o
               ON m.[object_id] = o.[OBJECT_ID]
       INNER JOIN sys.schemas AS s
               ON s.[schema_id] = o.[schema_id];

SELECT sum (LEN(m.definition) - LEN(REPLACE(m.definition, CHAR(10), ''))) AS [total_lines_of_code]
       , count(*)                                                         AS [total_objects]
FROM   sys.sql_modules AS m
       INNER JOIN sys.objects AS o
               ON m.[object_id] = o.[OBJECT_ID]
       INNER JOIN sys.schemas AS s
               ON s.[schema_id] = o.[schema_id]; 
