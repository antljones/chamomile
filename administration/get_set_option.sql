BEGIN
    --
    -------------------------------------------------
    DECLARE @OptionsList AS TABLE
      (
         [option]  [SYSNAME],
         [setting] [SYSNAME] CHECK ( [setting] IN ( N'ON', N'OFF' ) )
      );
    DECLARE @Options [INT] = @@OPTIONS;

    --
    INSERT INTO @OptionsList
                ([option],
                 [setting])
    VALUES      ( N'DISABLE_DEF_CNST_CHK',
                  CASE
                    WHEN ( 1 & @Options ) = 1 THEN N'ON'
                    ELSE N'OFF'
                  END );

    --
    INSERT INTO @OptionsList
                ([option],
                 [setting])
    VALUES      ( N'IMPLICIT_TRANSACTIONS',
                  CASE
                    WHEN ( 2 & @Options ) = 2 THEN N'ON'
                    ELSE N'OFF'
                  END );

    --
    INSERT INTO @OptionsList
                ([option],
                 [setting])
    VALUES      ( N'CURSOR_CLOSE_ON_COMMIT',
                  CASE
                    WHEN ( 4 & @Options ) = 4 THEN N'ON'
                    ELSE N'OFF'
                  END );

    --
    INSERT INTO @OptionsList
                ([option],
                 [setting])
    VALUES      ( N'ANSI_WARNINGS',
                  CASE
                    WHEN ( 8 & @Options ) = 8 THEN N'ON'
                    ELSE N'OFF'
                  END );

    --
    INSERT INTO @OptionsList
                ([option],
                 [setting])
    VALUES      ( N'ANSI_PADDING',
                  CASE
                    WHEN ( 16 & @Options ) = 16 THEN N'ON'
                    ELSE N'OFF'
                  END );

    --
    INSERT INTO @OptionsList
                ([option],
                 [setting])
    VALUES      ( N'ANSI_NULLS',
                  CASE
                    WHEN ( 32 & @Options ) = 32 THEN N'ON'
                    ELSE N'OFF'
                  END );

    --
    INSERT INTO @OptionsList
                ([option],
                 [setting])
    VALUES      ( N'ARITHABORT',
                  CASE
                    WHEN ( 64 & @Options ) = 64 THEN N'ON'
                    ELSE N'OFF'
                  END );

    --
    INSERT INTO @OptionsList
                ([option],
                 [setting])
    VALUES      ( N'ARITHIGNORE',
                  CASE
                    WHEN ( 128 & @Options ) = 128 THEN N'ON'
                    ELSE N'OFF'
                  END );

    --
    INSERT INTO @OptionsList
                ([option],
                 [setting])
    VALUES      ( N'QUOTED_idENTIFIER',
                  CASE
                    WHEN ( 256 & @Options ) = 256 THEN N'ON'
                    ELSE N'OFF'
                  END );

    --
    INSERT INTO @OptionsList
                ([option],
                 [setting])
    VALUES      ( N'NOCOUNT',
                  CASE
                    WHEN ( 512 & @Options ) = 512 THEN N'ON'
                    ELSE N'OFF'
                  END );

    --
    INSERT INTO @OptionsList
                ([option],
                 [setting])
    VALUES      ( N'ANSI_NULL_DFLT_ON',
                  CASE
                    WHEN ( 1024 & @Options ) = 1024 THEN N'ON'
                    ELSE N'OFF'
                  END );

    --
    INSERT INTO @OptionsList
                ([option],
                 [setting])
    VALUES      ( N'ANSI_NULL_DFLT_OFF',
                  CASE
                    WHEN ( 2048 & @Options ) = 2048 THEN N'ON'
                    ELSE N'OFF'
                  END );

    --
    INSERT INTO @OptionsList
                ([option],
                 [setting])
    VALUES      ( N'CONCAT_NULL_YIELDS_NULL',
                  CASE
                    WHEN ( 4096 & @Options ) = 4096 THEN N'ON'
                    ELSE N'OFF'
                  END );

    --
    INSERT INTO @OptionsList
                ([option],
                 [setting])
    VALUES      ( N'NUMERIC_ROUNDABORT',
                  CASE
                    WHEN ( 8192 & @Options ) = 8192 THEN N'ON'
                    ELSE N'OFF'
                  END );

    --
    INSERT INTO @OptionsList
                ([option],
                 [setting])
    VALUES      ( N'XACT_ABORT',
                  CASE
                    WHEN ( 16384 & @Options ) = 16384 THEN N'ON'
                    ELSE N'OFF'
                  END );

    SELECT [options_list].[option],
           [options_list].[setting]
    FROM   @OptionsList AS [options_list];
END; 
