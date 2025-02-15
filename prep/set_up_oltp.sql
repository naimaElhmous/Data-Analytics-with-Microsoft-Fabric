-- 1. Create the watermark table
IF NOT EXISTS (
    SELECT 1 
    FROM sys.tables t
    JOIN sys.schemas s ON t.schema_id = s.schema_id
    WHERE t.name = 'watermarktable'
      AND s.name = 'dbo'
)
BEGIN
    CREATE TABLE [dbo].[watermarktable]
    (
        [table_name]     VARCHAR(128) NOT NULL,
        [watermark_value] DATETIME2   NULL,
        CONSTRAINT PK_watermarktable PRIMARY KEY ([table_name])
    );
END

GO

-- 2. Create/update the stored procedure
IF OBJECT_ID('[dbo].[usp_write_watermark]', 'P') IS NOT NULL
BEGIN
    DROP PROCEDURE [dbo].[usp_write_watermark];
END
GO

CREATE PROCEDURE [dbo].[usp_write_watermark]
    @LastModifiedtime DATETIME2,
    @TableName        VARCHAR(128)
AS
BEGIN
    SET NOCOUNT ON;

    -- Try to update the existing watermark record
    UPDATE [dbo].[watermarktable]
       SET [watermark_value] = @LastModifiedtime
     WHERE [table_name] = @TableName;

    -- If no rows were updated, insert a new record
    IF @@ROWCOUNT = 0
    BEGIN
        INSERT INTO [dbo].[watermarktable] ([table_name], [watermark_value])
        VALUES (@TableName, @LastModifiedtime);
    END
END
GO


INSERT INTO [dbo].[watermarktable]
VALUES
    ('[dbo].[sales]', '2001-01-01T00:00:00.0000000'),
    ('[dbo].[customers]', '2001-01-01T00:00:00.0000000'),
    ('[dbo].[locations]', '2001-01-01T00:00:00.0000000'),
    ('[dbo].[products]', '2001-01-01T00:00:00.0000000');
