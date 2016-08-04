IF EXISTS (SELECT *
           FROM   [sys].[objects]
           WHERE  [object_id] = OBJECT_ID(N'[conversion].[binary_to_decimal]')
                  AND [type] IN ( N'FN', N'IF', N'TF', N'FS', N'FT' ))
  DROP FUNCTION [conversion].[binary_to_decimal];

GO

CREATE FUNCTION [conversion].[binary_to_decimal] (
  @input VARCHAR(255))
RETURNS BIGINT
AS
  BEGIN
      DECLARE @count    TINYINT = 1
              , @length TINYINT = LEN(@input);

      DECLARE @output BIGINT = CAST(SUBSTRING(@input
                       , @length
                       , 1) AS BIGINT);

      WHILE ( @count < @length )
        BEGIN
            SET @output = @output
                          + POWER(CAST(SUBSTRING(@input, @length - @count, 1) * 2 AS BIGINT), @count);

            SET @count = @count + 1;
        END;

      RETURN @output;
  END;

GO 
