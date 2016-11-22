SELECT [schemas].[name]                AS [schema]
       , [tables].[name]               AS [table]
       , [key_constraints].[name]      AS [constraint]
       , [columns].[name]              AS [column]
       , [index_columns].[key_ordinal] AS [key_ordinal]
FROM   [sys].[key_constraints] AS [key_constraints]
       JOIN [sys].[tables] AS [tables]
         ON [tables].[object_id] = [key_constraints].[parent_object_id]
       JOIN [sys].[schemas] AS [schemas]
         ON [schemas].[schema_id] = [tables].[schema_id]
       JOIN [sys].[index_columns] AS [index_columns]
         ON [index_columns].[object_id] = [tables].[object_id]
            AND [index_columns].[index_id] = [key_constraints].[unique_index_id]
       JOIN [sys].[columns] AS [columns]
         ON [columns].[object_id] = [tables].[object_id]
            AND [columns].[column_id] = [index_columns].[column_id]
WHERE  [key_constraints].[type] = 'PK'
       AND [columns].[name] = N'<name>'; 