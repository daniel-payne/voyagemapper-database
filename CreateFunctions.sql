 -----------------------------------------------------------------------------------------------------------------------------------------------------
--Drop Functions
-----------------------------------------------------------------------------------------------------------------------------------------------------
IF EXISTS (SELECT 1 FROM SYSOBJECTS WHERE name = 'ListToTable'                 AND type = 'TF') drop function dbo.ListToTable
IF EXISTS (SELECT 1 FROM SYSOBJECTS WHERE name = 'TextToLines'                 AND type = 'TF') drop function dbo.TextToLines
GO
 
IF EXISTS (SELECT 1 FROM SYSOBJECTS WHERE name = 'Base64Decode'                AND type = 'FN') drop function dbo.Base64Decode
IF EXISTS (SELECT 1 FROM SYSOBJECTS WHERE name = 'Base64Encode'                AND type = 'FN') drop function dbo.Base64Encode
IF EXISTS (SELECT 1 FROM SYSOBJECTS WHERE name = 'BigIntegerToBinaryString'    AND type = 'FN') drop function dbo.BigIntegerToBinaryString
IF EXISTS (SELECT 1 FROM SYSOBJECTS WHERE name = 'BinaryStringToBigInteger'    AND type = 'FN') drop function dbo.BinaryStringToBigInteger
IF EXISTS (SELECT 1 FROM SYSOBJECTS WHERE name = 'CastAsGeoJSON'               AND type = 'FN') drop function dbo.CastAsGeoJSON
IF EXISTS (SELECT 1 FROM SYSOBJECTS WHERE name = 'CastAsGoogleArray'           AND type = 'FN') drop function dbo.CastAsGoogleArray
IF EXISTS (SELECT 1 FROM SYSOBJECTS WHERE name = 'ExtractAmount'               AND type = 'FN') drop function dbo.ExtractAmount
IF EXISTS (SELECT 1 FROM SYSOBJECTS WHERE name = 'ExtractUnits'                AND type = 'FN') drop function dbo.ExtractUnits
IF EXISTS (SELECT 1 FROM SYSOBJECTS WHERE name = 'CountOccurancesOfString'     AND type = 'FN') drop function dbo.CountOccurancesOfString
IF EXISTS (SELECT 1 FROM SYSOBJECTS WHERE name = 'ExtractLongestWordCode'      AND type = 'FN') drop function dbo.ExtractLongestWordCode
IF EXISTS (SELECT 1 FROM SYSOBJECTS WHERE name = 'RemoveArtefacts'             AND type = 'FN') drop function dbo.RemoveArtefacts
IF EXISTS (SELECT 1 FROM SYSOBJECTS WHERE name = 'PluralToSingular'            AND type = 'FN') drop function dbo.PluralToSingular
IF EXISTS (SELECT 1 FROM SYSOBJECTS WHERE name = 'StringToFloat'               AND type = 'FN') drop function dbo.StringToFloat
IF EXISTS (SELECT 1 FROM SYSOBJECTS WHERE name = 'StringToInteger'             AND type = 'FN') drop function dbo.StringToInteger
IF EXISTS (SELECT 1 FROM SYSOBJECTS WHERE name = 'TextToBigInteger'            AND type = 'FN') drop function dbo.TextToBigInteger
IF EXISTS (SELECT 1 FROM SYSOBJECTS WHERE name = 'TextToFloat'                 AND type = 'FN') drop function dbo.TextToFloat
IF EXISTS (SELECT 1 FROM SYSOBJECTS WHERE name = 'TextToSimpleString'          AND type = 'FN') drop function dbo.TextToSimpleString
IF EXISTS (SELECT 1 FROM SYSOBJECTS WHERE name = 'TextToCleanString'           AND type = 'FN') drop function dbo.TextToCleanString
GO


-----------------------------------------------------------------------------------------------------------------------------------------------------
--Old Functions
-----------------------------------------------------------------------------------------------------------------------------------------------------
IF EXISTS (SELECT 1 FROM SYSOBJECTS WHERE name = 'TextToAlphebeticString'      AND type = 'FN') drop function dbo.TextToAlphebeticString
GO


-----------------------------------------------------------------------------------------------------------------------------------------------------
-- SELECT dbo.TextToCleanString('News from   France''s "capital" today: a town called autrey-lès-gray. +33')
-----------------------------------------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[TextToCleanString] 
( 
  @Input             nvarchar(max) 
) 
RETURNS varchar(max) AS BEGIN

  DECLARE @CHARACTER_MAP varchar(255) = ' ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!£$%^&*()_+-={}[]@~''#<>?,./'  COLLATE Latin1_General_CS_AI

  DECLARE @i      integer = 1
  DECLARE @length integer = DATALENGTH(@input)
  DECLARE @char   char
  DECLARE @result varchar(max) = ''

  SET @Input = RTRIM(LTRIM(@Input))


  WHILE @i <= @length BEGIN

     SET @Char = SUBSTRING(@input,@i,1)

     IF (CHARINDEX(@Char, @CHARACTER_MAP COLLATE Latin1_General_CS_AI) > 0) BEGIN

         SET @result = @result + @Char 

     END

    SET @i = @i + 1

  END

  SET @result = REPLACE(@result, '   ', ' ')
  SET @result = REPLACE(@result, '  ',  ' ')


  RETURN RTRIM(LTRIM(@result))

END

GO


-----------------------------------------------------------------------------------------------------------------------------------------------------
-- SELECT dbo.TextToSimpleString('News from   France''s "capital" today: a town called autrey-lès-gray. +33')
-----------------------------------------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[TextToSimpleString] 
( 
  @Input             nvarchar(max) 
) 
RETURNS varchar(max) AS BEGIN

  DECLARE @CHARACTER_MAP varchar(255) = ' abcdefghijklmnopqrstuvwxyz0123456789'

  DECLARE @i      integer = 1
  DECLARE @length integer = DATALENGTH(@input)
  DECLARE @char   char
  DECLARE @result varchar(max) = ''

  SET @Input = LOWER(RTRIM(LTRIM(@Input)))

  WHILE @i <= @length BEGIN

     SET @Char = SUBSTRING(@input,@i,1)

     IF      (@Char = 'á') SET @Char = 'a'
     ELSE IF (@Char = 'à') SET @Char = 'a'
     ELSE IF (@Char = 'â') SET @Char = 'a'
     ELSE IF (@Char = 'ã') SET @Char = 'a'
     ELSE IF (@Char = 'ä') SET @Char = 'a'
     ELSE IF (@Char = 'å') SET @Char = 'a'
     ELSE IF (@Char = 'ā') SET @Char = 'a'
     ELSE IF (@Char = 'ă') SET @Char = 'a'
     ELSE IF (@Char = 'ą') SET @Char = 'a'   
     ELSE IF (@Char = 'ć') SET @Char = 'c'
     ELSE IF (@Char = 'ĉ') SET @Char = 'c'
     ELSE IF (@Char = 'ċ') SET @Char = 'c'
     ELSE IF (@Char = 'č') SET @Char = 'c'        
     ELSE IF (@Char = 'ď') SET @Char = 'd'
     ELSE IF (@Char = 'đ') SET @Char = 'd'          
     ELSE IF (@Char = 'é') SET @Char = 'e'
     ELSE IF (@Char = 'ë') SET @Char = 'e'
     ELSE IF (@Char = 'ê') SET @Char = 'e'
     ELSE IF (@Char = 'è') SET @Char = 'e'
     ELSE IF (@Char = 'ē') SET @Char = 'e'
     ELSE IF (@Char = 'ĕ') SET @Char = 'e'
     ELSE IF (@Char = 'ė') SET @Char = 'e'
     ELSE IF (@Char = 'ę') SET @Char = 'e'    
     ELSE IF (@Char = 'ĝ') SET @Char = 'g'
     ELSE IF (@Char = 'ğ') SET @Char = 'g'
     ELSE IF (@Char = 'ġ') SET @Char = 'g'
     ELSE IF (@Char = 'ģ') SET @Char = 'g'        
     ELSE IF (@Char = 'ĥ') SET @Char = 'h'
     ELSE IF (@Char = 'ħ') SET @Char = 'h'          
     ELSE IF (@Char = 'ì') SET @Char = 'i'
     ELSE IF (@Char = 'í') SET @Char = 'i'
     ELSE IF (@Char = 'î') SET @Char = 'i'
     ELSE IF (@Char = 'ï') SET @Char = 'i'
     ELSE IF (@Char = 'ĩ') SET @Char = 'i'
     ELSE IF (@Char = 'ī') SET @Char = 'i'
     ELSE IF (@Char = 'ĭ') SET @Char = 'i'
     ELSE IF (@Char = 'į') SET @Char = 'i'
     ELSE IF (@Char = 'ı') SET @Char = 'i'   
     ELSE IF (@Char = 'ĵ') SET @Char = 'j'           
     ELSE IF (@Char = 'ķ') SET @Char = 'k'
     ELSE IF (@Char = 'ĸ') SET @Char = 'k'          
     ELSE IF (@Char = 'ĺ') SET @Char = 'l'
     ELSE IF (@Char = 'ļ') SET @Char = 'l'
     ELSE IF (@Char = 'ľ') SET @Char = 'l'
     ELSE IF (@Char = 'ŀ') SET @Char = 'l'
     ELSE IF (@Char = 'ł') SET @Char = 'l'       
     ELSE IF (@Char = 'ñ') SET @Char = 'n'
     ELSE IF (@Char = 'ń') SET @Char = 'n'
     ELSE IF (@Char = 'ņ') SET @Char = 'n'
     ELSE IF (@Char = 'ň') SET @Char = 'n'
     ELSE IF (@Char = 'ŉ') SET @Char = 'n'
     ELSE IF (@Char = 'ŋ') SET @Char = 'n'      
     ELSE IF (@Char = 'ò') SET @Char = 'o'
     ELSE IF (@Char = 'ó') SET @Char = 'o'
     ELSE IF (@Char = 'ô') SET @Char = 'o'
     ELSE IF (@Char = 'õ') SET @Char = 'o'
     ELSE IF (@Char = 'ö') SET @Char = 'o'
     ELSE IF (@Char = 'ō') SET @Char = 'o'
     ELSE IF (@Char = 'ŏ') SET @Char = 'o'
     ELSE IF (@Char = 'ő') SET @Char = 'o'
     ELSE IF (@Char = 'ơ') SET @Char = 'o'   
     ELSE IF (@Char = 'ŕ') SET @Char = 'r'
     ELSE IF (@Char = 'ŗ') SET @Char = 'r'
     ELSE IF (@Char = 'ř') SET @Char = 'r'         
     ELSE IF (@Char = 'ś') SET @Char = 's'
     ELSE IF (@Char = 'ŝ') SET @Char = 's'
     ELSE IF (@Char = 'ş') SET @Char = 's'
     ELSE IF (@Char = 'š') SET @Char = 's'
     ELSE IF (@Char = 'ș') SET @Char = 's'       
     ELSE IF (@Char = 'ţ') SET @Char = 't'
     ELSE IF (@Char = 'ť') SET @Char = 't'
     ELSE IF (@Char = 'ŧ') SET @Char = 't'
     ELSE IF (@Char = 'ț') SET @Char = 't'        
     ELSE IF (@Char = 'ù') SET @Char = 'u'
     ELSE IF (@Char = 'ú') SET @Char = 'u'
     ELSE IF (@Char = 'û') SET @Char = 'u'
     ELSE IF (@Char = 'ü') SET @Char = 'u'
     ELSE IF (@Char = 'ũ') SET @Char = 'u'
     ELSE IF (@Char = 'ū') SET @Char = 'u'
     ELSE IF (@Char = 'ŭ') SET @Char = 'u'
     ELSE IF (@Char = 'ů') SET @Char = 'u'
     ELSE IF (@Char = 'ű') SET @Char = 'u'
     ELSE IF (@Char = 'ų') SET @Char = 'u'
     ELSE IF (@Char = 'ư') SET @Char = 'u' 
     ELSE IF (@Char = 'ŵ') SET @Char = 'w'           
     ELSE IF (@Char = 'ŷ') SET @Char = 'y'           
     ELSE IF (@Char = 'ź') SET @Char = 'z'
     ELSE IF (@Char = 'ż') SET @Char = 'z'
     ELSE IF (@Char = 'ž') SET @Char = 'z'         

     IF (CHARINDEX(@Char, @CHARACTER_MAP) > 0) BEGIN

         SET @result = @result + @Char 

     END

    SET @i = @i + 1

  END

  SET @result = REPLACE(@result, '   ', ' ')
  SET @result = REPLACE(@result, '  ',  ' ')

  RETURN RTRIM(LTRIM(@result))  
 
END

GO

-----------------------------------------------------------------------------------------------------------------------------------------------------
--SELECT * FROM dbo.VM_TListToTable_fn('123,456,789,101112asfsdfsdfsdfsdf', ',')
-----------------------------------------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[ListToTable]
(
     @input      varchar(max),
     @delimeter  varchar(1) 
)
RETURNS @result table (item varchar(max))
AS
BEGIN
--
DECLARE 
  @counter        int,
  @input_length   int,
  @character      varchar(1),
  @item           varchar(max) 
--
SET @input = @input + @delimeter
--
SET @input_length = len(@input) 
SET @counter      = 1
SET @character    = ''
SET @item         = ''
-- loop
WHILE @counter <= @input_length+1 BEGIN
  --
  SET @character = substring(@input, @counter, 1)
  --
  IF (@character <> @delimeter) BEGIN
      --
      SET @item = @item + @character         
  END ELSE BEGIN 
      --
      INSERT INTO @result 
      VALUES(RTRIM(LTRIM(@item)))
      --
      SET @item = ''
  END
  --
  SET @counter = @counter + 1
end
--
RETURN  
END

GO

-----------------------------------------------------------------------------------------------------------------------------------------------------
--SELECT * FROM dbo.TextToLines('Hello World. How are you')
-----------------------------------------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[TextToLines]
(
     @input      nvarchar(max) 
)
RETURNS @result table (item varchar(max))
AS
BEGIN
INSERT INTO @result
 SELECT 
   item 
 FROM 
   [dbo].[ListToTable](replace(replace(@input, CHAR(13), '.'), CHAR(10), '.'), '.')
WHERE
  datalength(item) > 0 
 
RETURN  
END
GO


-----------------------------------------------------------------------------------------------------------------------------------------------------
--SELECT dbo.BASE64Decode('SGVsbG8gV29ybGQ=')
-----------------------------------------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[BASE64Decode]
(
  @encoded_text varchar(8000)
)
RETURNS 
          varchar(6000)
AS BEGIN
--local variables
DECLARE
  @output           varchar(8000),
  @block_start      int,
  @encoded_length   int,
  @decoded_length   int,
  @mapr             binary(122)
--IF @encoded_text COLLATE LATIN1_GENERAL_BIN
-- LIKE '%[^ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=]%'
--     COLLATE LATIN1_GENERAL_BIN
--  RETURN NULL
--IF LEN(@encoded_text) & 3 > 0
--  RETURN NULL
SET @output   = ''
-- The nth byte of @mapr contains the base64 value
-- of the character with an ASCII value of n.
-- EG, 65th byte = 0x00 = 0 = value of 'A'
SET @mapr =
  0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF -- 1-33
+ 0xFFFFFFFFFFFFFFFFFFFF3EFFFFFF3F3435363738393A3B3C3DFFFFFF00FFFFFF -- 33-64
+ 0x000102030405060708090A0B0C0D0E0F10111213141516171819FFFFFFFFFFFF -- 65-96
+ 0x1A1B1C1D1E1F202122232425262728292A2B2C2D2E2F30313233 -- 97-122
--get the number of blocks to be decoded
SET @encoded_length = LEN(@encoded_text)
SET @decoded_length = @encoded_length / 4 * 3
--for each block
SET @block_start = 1
WHILE @block_start < @encoded_length BEGIN
  --decode the block and add to output
  --BINARY values between 1 and 4 bytes can be implicitly cast to INT
  SET @output = @output +  CAST(CAST(CAST(
   substring( @mapr, ascii( substring( @encoded_text, @block_start    , 1) ), 1) * 262144
 + substring( @mapr, ascii( substring( @encoded_text, @block_start + 1, 1) ), 1) * 4096
 + substring( @mapr, ascii( substring( @encoded_text, @block_start + 2, 1) ), 1) * 64
 + substring( @mapr, ascii( substring( @encoded_text, @block_start + 3, 1) ), 1) 
   AS INTEGER) AS BINARY(3)) AS VARCHAR(3))
  SET @block_start = @block_start + 4
END
IF RIGHT(@encoded_text, 2) = '=='
 SET @decoded_length = @decoded_length - 2
ELSE IF RIGHT(@encoded_text, 1) = '='
 SET @decoded_length = @decoded_length - 1
--IF SUBSTRING(@output, @decoded_length, 1) = CHAR(0)
-- SET @decoded_length = @decoded_length - 1
--return the decoded string
RETURN LEFT(@output, @decoded_length)
END

GO
/****** Object:  UserDefinedFunction [dbo].[BASE64Encode]    Script Date: 29/04/2016 08:50:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO



-----------------------------------------------------------------------------------------------------------------------------------------------------
--SELECT dbo.BASE64Encode('Hello World')
-----------------------------------------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[BASE64Encode]
(
  @plain_text varchar(6000)
)
RETURNS 
          varchar(8000)
AS BEGIN
--local variables
DECLARE
  @output            varchar(8000),
  @input_length      integer,
  @block_start       integer,
  @partial_block_start  integer, -- position of last 0, 1 or 2 characters
  @partial_block_length integer,
  @block_val         integer,
  @map               char(64)
SET @map = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
--initialise variables
SET @output   = ''
--set length and count
SET @input_length      = LEN( @plain_text + '#' ) - 1
SET @partial_block_length = @input_length % 3
SET @partial_block_start = @input_length - @partial_block_length
SET @block_start       = 1
--for each block
WHILE @block_start < @partial_block_start  BEGIN
  SET @block_val = CAST(SUBSTRING(@plain_text, @block_start, 3) AS BINARY(3))
  --encode the 3 character block and add to the output
  SET @output = @output + SUBSTRING(@map, @block_val / 262144 + 1, 1)
                        + SUBSTRING(@map, (@block_val / 4096 & 63) + 1, 1)
                        + SUBSTRING(@map, (@block_val / 64 & 63  ) + 1, 1)
                        + SUBSTRING(@map, (@block_val & 63) + 1, 1)
  --increment the counter
  SET @block_start = @block_start + 3
END
IF @partial_block_length > 0
BEGIN
  SET @block_val = CAST(SUBSTRING(@plain_text, @block_start, @partial_block_length)
                      + REPLICATE(CHAR(0), 3 - @partial_block_length) AS BINARY(3))
  SET @output = @output
 + SUBSTRING(@map, @block_val / 262144 + 1, 1)
 + SUBSTRING(@map, (@block_val / 4096 & 63) + 1, 1)
 + CASE WHEN @partial_block_length < 2
    THEN REPLACE(SUBSTRING(@map, (@block_val / 64 & 63  ) + 1, 1), 'A', '=')
    ELSE SUBSTRING(@map, (@block_val / 64 & 63  ) + 1, 1) END
 + CASE WHEN @partial_block_length < 3
    THEN REPLACE(SUBSTRING(@map, (@block_val & 63) + 1, 1), 'A', '=')
    ELSE SUBSTRING(@map, (@block_val & 63) + 1, 1) END
END
--return the result
RETURN @output
END

GO
/****** Object:  UserDefinedFunction [dbo].[BigIntegerToBinaryString]    Script Date: 29/04/2016 08:50:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

-----------------------------------------------------------------------------------------------------------------------------------------------------
--SELECT dbo.BigIntegerToBinaryString(8)
-----------------------------------------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[BigIntegerToBinaryString]
(
  @Input   bigint
)
RETURNS 
  varchar(64)
AS BEGIN
--
DECLARE  
  @result varchar(64) 
--  
SET @result = '' 
--
WHILE 1 = 1 begin   
  --
  SELECT 
    @result = convert(char(1), @input % 2) + @result,          
    @input  = convert(int, @input / 2)   
  --
  IF @input = 0 
    break 
  end  
--
RETURN @Result 
END

GO
/****** Object:  UserDefinedFunction [dbo].[BinaryStringToBigInteger]    Script Date: 29/04/2016 08:50:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

-----------------------------------------------------------------------------------------------------------------------------------------------------
--SELECT dbo.BinaryStringToBigInteger('10000000')
-----------------------------------------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[BinaryStringToBigInteger]
(
  @Input varchar(64)
)
RETURNS 
  bigint
AS BEGIN
-- 
DECLARE 
  @Data    varchar(64),
  @Result  int,
  @i       integer 
--  
SET @Data   = REVERSE(@Input)
SET @Result = 0 
SET @i      = 1 
-- 
WHILE @i <= DATALENGTH(@Data) BEGIN
 --
 IF ( SUBSTRING(@Data, @i, 1) = '1')
   SET @Result = @Result + power(2, @i-1)
 --
 SET @i = @i+1
END 
--
RETURN @Result 
END

GO

-----------------------------------------------------------------------------------------------------------------------------------------------------
--SELECT dbo.CastAsGeoJSON()
-----------------------------------------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[CastAsGeoJSON] (@geo geography) /*this is your geography shape*/
RETURNS varchar(max)
WITH SCHEMABINDING /*this tells SQL SERVER that it is deterministic (helpful if you use it in a calculated column)*/
AS
BEGIN
/* Declare the return variable here*/
DECLARE @Result varchar(max)
DECLARE @imput  varchar(max) = CAST(@geo AS varchar(max))
DECLARE @type   varchar(255) = @geo.MakeValid().STGeometryType()
/*Build JSON "geometry" element for geoJSON*/

SELECT  @Result = '{' +
    CASE @type
        WHEN 'POINT' THEN
            '"type": "Point","coordinates":' +
            REPLACE(REPLACE(REPLACE(REPLACE(@imput,'POINT ',''),'(','['),')',']'),' ',',')
        WHEN 'POLYGON' THEN 
            '"type": "Polygon","coordinates":' +
            '[' + REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@imput,'POLYGON ',''),'(','['),')',']'),'], ',']],['),', ','],['),' ',',') + ']'
        WHEN 'MULTIPOLYGON' THEN 
            '"type": "MultiPolygon","coordinates":' +
            '[' + REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@imput,'MULTIPOLYGON ',''),'(','['),')',']'),'], ',']],['),', ','],['),' ',',') + ']'
    ELSE NULL
    END
    +'}'

    /* Return the result of the function*/
    RETURN @Result

END
GO


-----------------------------------------------------------------------------------------------------------------------------------------------------
--SELECT dbo.CastAsGoogleArray()
-----------------------------------------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[CastAsGoogleArray] (@geo geography)  
RETURNS varchar(max)
--WITH SCHEMABINDING  
AS
BEGIN
 
DECLARE @Result varchar(max) = ''
DECLARE @imput  varchar(max) = CAST(@geo AS varchar(max))
DECLARE @type   varchar(255) = @geo.MakeValid().STGeometryType()
 
SELECT 
  @Result = COALESCE(@Result + ', ', '') +  
  '[{"lng":' +
  REPLACE(
  REPLACE(
		REVERSE(SUBSTRING(REVERSE(item),0,CHARINDEX('(',REVERSE(item))))
	,', ', '},{"lng":')
	  
  ,' ', ',"lat":') 
 + '}]'
FROM 
  [dbo].[ListToTable](CAST(@geo AS varchar(max)), '),  (') 
WHERE 
  DATALENGTH(item) > 0 

SET @Result = rtrim(ltrim(substring(@Result,2,datalength(@Result)))) 

IF datalength(@Result) = 0 BEGIN
  
  SET @Result = NULL
 
END

IF  CHARINDEX('], [',@Result) > 0 BEGIN
  SET @Result = '[' + @Result + ']'
END 

IF @Result = '[{"lng":}]' BEGIN
  SET  @Result = NULL
END


RETURN @Result

END
GO

-----------------------------------------------------------------------------------------------------------------------------------------------------
--SELECT dbo.VM_CountOccurancesOfString_fn('france', 'in france today, there is a problem in a town called autreylesgray, france') 
-----------------------------------------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[CountOccurancesOfString]
(
    @pattern varchar(255),
    @expression varchar(max)
)
RETURNS INT
AS
BEGIN
DECLARE @Result int = 0;

    DECLARE @index BigInt = 0
    DECLARE @patLen int = len(@pattern)

    SET @index = CHARINDEX(@pattern, @expression, @index)
    While @index > 0
    BEGIN
        SET @Result = @Result + 1;
        SET @index = CHARINDEX(@pattern, @expression, @index + @patLen)
    END

    RETURN @Result
END
GO

-----------------------------------------------------------------------------------------------------------------------------------------------------
--SELECT dbo.ExtractLongestWordCode('a town called autrey-lès-gray')
-----------------------------------------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[ExtractLongestWordCode]
( 
  @Input nvarchar(max) 
) 
RETURNS bigint AS
BEGIN

  DECLARE @SimpleInput  varchar(255)
  DECLARE @LongestWord  varchar(255)

  IF charindex(' ', @Input) > 0 BEGIN

    SELECT TOP 1 
      @LongestWord = item 
    FROM 
      dbo.ListToTable(@Input, ' ') 
    WHERE
      item not in ('station', 'airport', 'hotel', 'border')
    ORDER BY 
      datalength(item) DESC

  END ELSE BEGIN

    SET @LongestWord = @Input

  END

  SET @LongestWord = LOWER(RTRIM(LTRIM(@LongestWord)))

  RETURN dbo.TextToBigInteger(@LongestWord) 
END
GO

-----------------------------------------------------------------------------------------------------------------------------------------------------
--SELECT dbo.[PluralToSingular]('rolls')
-----------------------------------------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[PluralToSingular] 
( 
  @Input varchar(255) 
) 
RETURNS varchar(255) AS BEGIN
--
DECLARE
  @plural varchar(255), 
  @result varchar(255) 
--
SET
  @plural = rtrim(ltrim(lower(@Input)))
--
IF EXISTS (SELECT 1 FROM search.SwopWord WHERE FromWord = @plural)
  SELECT @result = ToWord FROM search.SwopWord WHERE FromWord = @plural
--
ELSE IF datalength(@plural) > datalength('children') AND substring(@plural, datalength(@plural) - datalength('children') + 1, datalength('children')) = 'children'
  SET @result = substring(@plural, 1, datalength(@plural) - datalength('children') ) + 'child'
--
ELSE IF datalength(@plural) > datalength('people') AND substring(@plural, datalength(@plural) - datalength('people') + 1, datalength('people')) = 'people'
  SET @result = substring(@plural, 1, datalength(@plural) - datalength('people') ) + 'person'
--     
ELSE IF datalength(@plural) > datalength('shoes') AND substring(@plural, datalength(@plural) - datalength('shoes') + 1, datalength('shoes')) = 'shoes'
  SET @result = substring(@plural, 1, datalength(@plural) - datalength('shoes') ) + 'shoe'
--
ELSE IF datalength(@plural) > datalength('hives') AND substring(@plural, datalength(@plural) - datalength('hives') + 1, datalength('hives')) = 'hives'
  SET @result = substring(@plural, 1, datalength(@plural) - datalength('hives') ) + 'hive'
--
ELSE IF datalength(@plural) > datalength('ouses') AND substring(@plural, datalength(@plural) - datalength('ouses') + 1, datalength('ouses')) = 'ouses'
  SET @result = substring(@plural, 1, datalength(@plural) - datalength('ouses') ) + 'ouse'
--
ELSE IF datalength(@plural) > datalength('eroes') AND substring(@plural, datalength(@plural) - datalength('eroes') + 1, datalength('eroes')) = 'eroes'
  SET @result = substring(@plural, 1, datalength(@plural) - datalength('eroes') ) + 'ero'
--
ELSE IF datalength(@plural) > datalength('news') AND substring(@plural, datalength(@plural) - datalength('news') + 1, datalength('news')) = 'news'
  SET @result = substring(@plural, 1, datalength(@plural) - datalength('news') ) + 'news'
--
ELSE IF datalength(@plural) > datalength('rves') AND substring(@plural, datalength(@plural) - datalength('rves') + 1, datalength('rves')) = 'rves'
--
  SET @result = substring(@plural, 1, datalength(@plural) - datalength('rves') ) + 'rf'

ELSE IF datalength(@plural) > datalength('aves') AND substring(@plural, datalength(@plural) - datalength('aves') + 1, datalength('aves')) = 'aves'
  SET @result = substring(@plural, 1, datalength(@plural) - datalength('aves') ) + 'af'

ELSE IF datalength(@plural) > datalength('ches') AND substring(@plural, datalength(@plural) - datalength('ches') + 1, datalength('ches')) = 'ches'
  SET @result =  substring(@plural, 1, datalength(@plural) - datalength('ches') ) + 'ch'

ELSE IF datalength(@plural) > datalength('shes') AND substring(@plural, datalength(@plural) - datalength('shes') + 1, datalength('shes')) = 'shes'
  SET @result =  substring(@plural, 1, datalength(@plural) - datalength('shes') ) + 'sh'

ELSE IF datalength(@plural) > datalength('sses') AND substring(@plural, datalength(@plural) - datalength('sses') + 1, datalength('sses')) = 'sses'
  SET @result =  substring(@plural, 1, datalength(@plural) - datalength('sses') ) + 'ss'

ELSE IF datalength(@plural) > datalength('lves') AND substring(@plural, datalength(@plural) - datalength('lves') + 1, datalength('lves')) = 'lves'
  SET @result =  substring(@plural, 1, datalength(@plural) - datalength('lves') ) + 'lf'

ELSE IF datalength(@plural) > datalength('ffes') AND substring(@plural, datalength(@plural) - datalength('ffes') + 1, datalength('ffes')) = 'ffes'
  SET @result =  substring(@plural, 1, datalength(@plural) - datalength('ffes') ) + 'ffe'

ELSE IF datalength(@plural) > datalength('aves') AND substring(@plural, datalength(@plural) - datalength('aves') + 1, datalength('aves')) = 'aves'
  SET @result =  substring(@plural, 1, datalength(@plural) - datalength('aves') ) + 'afe'

ELSE IF datalength(@plural) > datalength('oses') AND substring(@plural, datalength(@plural) - datalength('oses') + 1, datalength('oses')) = 'oses'
  SET @result =  substring(@plural, 1, datalength(@plural) - datalength('oses') ) + 'osis'

ELSE IF datalength(@plural) > datalength('oxes') AND substring(@plural, datalength(@plural) - datalength('oxes') + 1, datalength('oxes')) = 'oxes'
  SET @result =  substring(@plural, 1, datalength(@plural) - datalength('oxes') ) + 'ox'

ELSE IF datalength(@plural) > datalength('uses') AND substring(@plural, datalength(@plural) - datalength('uses') + 1, datalength('uses')) = 'uses'
  SET @result =  substring(@plural, 1, datalength(@plural) - datalength('uses') ) + 'us'

ELSE IF datalength(@plural) > datalength('ives') AND substring(@plural, datalength(@plural) - datalength('ives') + 1, datalength('ives')) = 'ives'
  SET @result =  substring(@plural, 1, datalength(@plural) - datalength('ives') ) + 'ive'

ELSE IF datalength(@plural) > datalength('men') AND substring(@plural, datalength(@plural) - datalength('men') + 1, datalength('men')) = 'men'
  SET @result =  substring(@plural, 1, datalength(@plural) - datalength('men') ) + 'man'

ELSE IF datalength(@plural) > datalength('men') AND substring(@plural, datalength(@plural) - datalength('men') + 1, datalength('men')) = 'men'
  SET @result =  substring(@plural, 1, datalength(@plural) - datalength('men') ) + 'man'

ELSE IF datalength(@plural) > datalength('tum') AND substring(@plural, datalength(@plural) - datalength('tum') + 1, datalength('tum')) = 'tum'
  SET @result =  substring(@plural, 1, datalength(@plural) - datalength('tum') ) + 'ta'
 
ELSE IF datalength(@plural) > datalength('ium') AND substring(@plural, datalength(@plural) - datalength('ium') + 1, datalength('ium')) = 'ium'
  SET @result =  substring(@plural, 1, datalength(@plural) - datalength('ium') ) + 'ia'
 
ELSE IF datalength(@plural) > datalength('rum') AND substring(@plural, datalength(@plural) - datalength('rum') + 1, datalength('rum')) = 'rum'
  SET @result =  substring(@plural, 1, datalength(@plural) - datalength('rum') ) + 'ra'
 
ELSE IF datalength(@plural) > datalength('ays') AND substring(@plural, datalength(@plural) - datalength('ays') + 1, datalength('ays')) = 'ays'
  SET @result =  substring(@plural, 1, datalength(@plural) - datalength('ays') ) + 'ay'
 
ELSE IF datalength(@plural) > datalength('eys') AND substring(@plural, datalength(@plural) - datalength('eys') + 1, datalength('ays')) = 'eys'
  SET @result =  substring(@plural, 1, datalength(@plural) - datalength('eys') ) + 'ay'
 
ELSE IF datalength(@plural) > datalength('oys') AND substring(@plural, datalength(@plural) - datalength('oys') + 1, datalength('oys')) = 'oys'
  SET @result =  substring(@plural, 1, datalength(@plural) - datalength('oys') ) + 'oy'
 
ELSE IF datalength(@plural) > datalength('uys') AND substring(@plural, datalength(@plural) - datalength('uys') + 1, datalength('uys')) = 'uys'
  SET @result =  substring(@plural, 1, datalength(@plural) - datalength('uys') ) + 'uy'
 
ELSE IF datalength(@plural) > datalength('ies') AND substring(@plural, datalength(@plural) - datalength('ies') + 1, datalength('ies')) = 'ies'
  SET @result =  substring(@plural, 1, datalength(@plural) - datalength('ies') ) + 'y'
 
ELSE IF datalength(@plural) > datalength('xes') AND substring(@plural, datalength(@plural) - datalength('xes') + 1, datalength('xes')) = 'xes'
  SET @result =  substring(@plural, 1, datalength(@plural) - datalength('xes') ) + 'x'
 
ELSE IF datalength(@plural) > datalength('ofs') AND substring(@plural, datalength(@plural) - datalength('ofs') + 1, datalength('ofs')) = 'ofs'
  SET @result =  substring(@plural, 1, datalength(@plural) - datalength('ofs') ) + 'of'
 
ELSE IF datalength(@plural) > datalength('oes') AND substring(@plural, datalength(@plural) - datalength('oes') + 1, datalength('oes')) = 'oes'
  SET @result =  substring(@plural, 1, datalength(@plural) - datalength('oes') ) + 'oe'
 
ELSE IF datalength(@plural) > datalength('ves') AND substring(@plural, datalength(@plural) - datalength('ves') + 1, datalength('ves')) = 'ves'
  SET @result =  substring(@plural, 1, datalength(@plural) - datalength('ves') ) + 've'
 
ELSE IF datalength(@plural) > datalength('ses') AND substring(@plural, datalength(@plural) - datalength('ses') + 1, datalength('ses')) = 'ses'
  SET @result =  substring(@plural, 1, datalength(@plural) - datalength('ses') ) + 's'
 
ELSE IF datalength(@plural) > datalength('s') AND substring(@plural, datalength(@plural) - datalength('s') + 1, datalength('s')) = 's'
  SET @result =  substring(@plural, 1, datalength(@plural) - datalength('s') ) + ''


ELSE IF datalength(@plural) > datalength('ibly') AND substring(@plural, datalength(@plural) - datalength('ibly') + 1, datalength('ibly')) = 'ibly'
  SET @result =  substring(@plural, 1, datalength(@plural) - datalength('ibly') ) + 'ible'

ELSE IF datalength(@plural) > datalength('iest') AND substring(@plural, datalength(@plural) - datalength('iest') + 1, datalength('iest')) = 'iest'
  SET @result =  substring(@plural, 1, datalength(@plural) - datalength('iest') ) + 'y'

ELSE IF datalength(@plural) > datalength('ally') AND substring(@plural, datalength(@plural) - datalength('ally') + 1, datalength('ally')) = 'ally'
  SET @result =  substring(@plural, 1, datalength(@plural) - datalength('ally') ) + 'ic'

ELSE IF datalength(@plural) > datalength('ing') AND substring(@plural, datalength(@plural) - datalength('ing') + 1, datalength('ing')) = 'ing'
  SET @result =  substring(@plural, 1, datalength(@plural) - datalength('ing') ) + ''

ELSE IF datalength(@plural) > datalength('est') AND substring(@plural, datalength(@plural) - datalength('est') + 1, datalength('er')) = 'est'
  SET @result =  substring(@plural, 1, datalength(@plural) - datalength('est') ) + ''

ELSE IF datalength(@plural) > datalength('ied') AND substring(@plural, datalength(@plural) - datalength('ied') + 1, datalength('ied')) = 'ied'
  SET @result =  substring(@plural, 1, datalength(@plural) - datalength('ied') ) + 'y'

ELSE IF datalength(@plural) > datalength('ely') AND substring(@plural, datalength(@plural) - datalength('ely') + 1, datalength('ely')) = 'ely'
  SET @result =  substring(@plural, 1, datalength(@plural) - datalength('ely') ) + 'e'

ELSE IF datalength(@plural) > datalength('ier') AND substring(@plural, datalength(@plural) - datalength('ier') + 1, datalength('ier')) = 'ier'
  SET @result =  substring(@plural, 1, datalength(@plural) - datalength('ier') ) + 'y'

ELSE IF datalength(@plural) > datalength('ily') AND substring(@plural, datalength(@plural) - datalength('ily') + 1, datalength('ily')) = 'ily'
  SET @result =  substring(@plural, 1, datalength(@plural) - datalength('ily') ) + 'y'

ELSE IF datalength(@plural) > datalength('yed') AND substring(@plural, datalength(@plural) - datalength('yed') + 1, datalength('yed')) = 'yed'
  SET @result =  substring(@plural, 1, datalength(@plural) - datalength('yed') ) + 'y'

ELSE IF datalength(@plural) > datalength('ed') AND substring(@plural, datalength(@plural) - datalength('ed') + 1, datalength('ed')) = 'ed' AND datalength(@plural) > 5
  SET @result =  substring(@plural, 1, datalength(@plural) - datalength('ed') ) + ''

ELSE IF datalength(@plural) > datalength('ly') AND substring(@plural, datalength(@plural) - datalength('ly') + 1, datalength('ly')) = 'ly'
  SET @result =  substring(@plural, 1, datalength(@plural) - datalength('ly') ) + ''
--
ELSE
  SET @Result = @plural
----
--IF (datalength(@result) >= 2) AND ( substring(@result, datalength(@result)-1,1) = substring(@result, datalength(@result)-0,1) ) BEGIN
--  --
--  SET @result = substring(@result, 1, datalength(@result)-1) 
--END
--
RETURN @Result
END 
GO

-----------------------------------------------------------------------------------------------------------------------------------------------------
--VM_RemoveArtefacts_fn 
-----------------------------------------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[RemoveArtefacts]
(
  @g geography
) 
RETURNS geography AS 
BEGIN
  DECLARE @h geography = geography::STGeomFromText('POINT EMPTY', @g.STSrid);
  DECLARE @i int = 1;
  WHILE @i <= @g.STNumGeometries() BEGIN
    IF(@g.STGeometryN(@i).STDimension() = 2) BEGIN
      SELECT @h = @h.STUnion(@g.STGeometryN(@i));
    END
    SET @i = @i + 1;
  END
  RETURN @h;
END;

GO

-----------------------------------------------------------------------------------------------------------------------------------------------------
--SELECT dbo.StringToFloat('127.255.0.1')
-----------------------------------------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[StringToFloat] 
( 
  @Input varchar(max) 
) 
RETURNS float AS
--declare @Input varchar(max); SET @Input = '127.255.0.1'
--
BEGIN
  --
  DECLARE @NUMBER_PARTS  varchar(20); SET @NUMBER_PARTS  = '0123456789.'  
  --
  DECLARE
    @Length        integer,
    @i             integer,
    @c             char(1),
    @Number        varchar(100),
    @DecimalFound  bit,
    @result        float 
  --
  SET @i            = 1
  SET @number       = ''
  SET @DecimalFound = 0
  SET @Length       = datalength(@Input)
  --
  WHILE (@i <= @Length) BEGIN
   --
   SELECT @c = substring(@input, @i, 1)
   --
     IF charindex(@c, @NUMBER_PARTS, 1) > 0 BEGIN
       --
       IF @c = '.' BEGIN
         IF @DecimalFound = 1
           BREAK
         ELSE
           SET @DecimalFound = 1
       END
       --
       SET @Number = @Number + @c
     END
   --
   SET @i = @i + 1
  END
  --
  IF RTrim(LTrim(@Number)) = ''
  OR RTrim(LTrim(@Number)) = '.'
    SET @result = '0' 
  ELSE
    SELECT @result = CAST(@Number as float)  
--
--select @Number, @result
RETURN @result
END

GO
/****** Object:  UserDefinedFunction [dbo].[StringToInteger]    Script Date: 29/04/2016 08:50:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

-----------------------------------------------------------------------------------------------------------------------------------------------------
--SELECT dbo.StringToInteger('127.255.0.1')
-----------------------------------------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[StringToInteger] 
( 
  @Input varchar(max) 
) 
RETURNS float AS
--declare @Input varchar(max); SET @Input = '127.255.0.1'
--
BEGIN
  --
  DECLARE @NUMBER_PARTS  varchar(20); SET @NUMBER_PARTS  = '0123456789'  
  --
  DECLARE
    @Length        integer,
    @i             integer,
    @c             char(1),
    @Number        varchar(100),
    @result        float 
  --
  SET @i            = 1
  SET @number       = ''
  SET @Length       = datalength(@Input)
  --
  WHILE (@i <= @Length) BEGIN
   --
   SELECT @c = substring(@input, @i, 1)
   --
     IF charindex(@c, @NUMBER_PARTS, 1) > 0 BEGIN
       --
       SET @Number = @Number + @c
     END ELSE BEGIN
       --
       IF @Number <> ''
         BREAK
     END
   --
   SET @i = @i + 1
  END
  --
  IF @result = ''
    SET @result = '0' 
  --
  SELECT @result = CAST(@Number as integer)  
--
--select @Number, @result
RETURN @result
END

GO

-----------------------------------------------------------------------------------------------------------------------------------------------------
--SELECT dbo.TextToBigInteger('Hello World')
-----------------------------------------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[TextToBigInteger] 
( 
  @Text    varchar(256)
) 
RETURNS bigint AS
--
BEGIN
  --
  DECLARE
    @Word         varchar(256),
    @Result       bigint, 
    --
    @Character1   char,
    @Character2   char,
    @Character3   char,
    @Character4   char,
    @Character5   char,
    @Character6   char,
    @Character7   char,
    @Character8   char,
    @Character9   char,
    @Character10  char,
    @Character11  char,
    @Character12  char, 
    --
    @Number1      int,
    @Number2      int,
    @Number3      int,
    @Number4      int,
    @Number5      int,
    @Number6      int,
    @Number7      int,
    @Number8      int,
    @Number9      int,
    @Number10     int,
    @Number11     int,
    @Number12     int 
  --  
  SET @Word = lower(@Text)
   -- 
  SET @Character1  = rtrim(substring(@Word, 1,  1))
  SET @Character2  = rtrim(substring(@Word, 2,  1))
  SET @Character3  = rtrim(substring(@Word, 3,  1))
  SET @Character4  = rtrim(substring(@Word, 4,  1))
  SET @Character5  = rtrim(substring(@Word, 5,  1))
  SET @Character6  = rtrim(substring(@Word, 6,  1))
  SET @Character7  = rtrim(substring(@Word, 7,  1))
  SET @Character8  = rtrim(substring(@Word, 8,  1))
  SET @Character9  = rtrim(substring(@Word, 9,  1))
  SET @Character10 = rtrim(substring(@Word, 10, 1))
  SET @Character11 = rtrim(substring(@Word, 11, 1))
  SET @Character12 = rtrim(substring(@Word, 12, 1))
  --
  SET @Number1  = ASCII(@Character1) 
  SET @Number2  = ASCII(@Character2) 
  SET @Number3  = ASCII(@Character3) 
  SET @Number4  = ASCII(@Character4) 
  SET @Number5  = ASCII(@Character5) 
  SET @Number6  = ASCII(@Character6) 
  SET @Number7  = ASCII(@Character7) 
  SET @Number8  = ASCII(@Character8) 
  SET @Number9  = ASCII(@Character9) 
  SET @Number10 = ASCII(@Character10)
  SET @Number11 = ASCII(@Character11)
  SET @Number12 = ASCII(@Character12)
  --
  IF @Number1   >= 97 AND @Number1  <= 122  SELECT  @Number1  = (@Number1  - 97 + 1)                  ELSE SELECT @Number1  = 0
  IF @Number2   >= 97 AND @Number2  <= 122  SELECT  @Number2  = (@Number2  - 97 + 1) *  power(26,1)   ELSE SELECT @Number2  = 0
  IF @Number3   >= 97 AND @Number3  <= 122  SELECT  @Number3  = (@Number3  - 97 + 1) *  power(26,2)   ELSE SELECT @Number3  = 0
  IF @Number4   >= 97 AND @Number4  <= 122  SELECT  @Number4  = (@Number4  - 97 + 1) *  power(26,3)   ELSE SELECT @Number4  = 0
  IF @Number5   >= 97 AND @Number5  <= 122  SELECT  @Number5  = (@Number5  - 97 + 1) *  power(26,4)   ELSE SELECT @Number5  = 0
  IF @Number6   >= 97 AND @Number6  <= 122  SELECT  @Number6  = (@Number6  - 97 + 1) *  power(26,5)   ELSE SELECT @Number6  = 0
  --
  IF @Number7   >= 97 AND @Number7  <= 122  SELECT  @Number7  = (@Number7  - 97 + 1)                  ELSE SELECT @Number7  = 0
  IF @Number8   >= 97 AND @Number8  <= 122  SELECT  @Number8  = (@Number8  - 97 + 1) *  power(26,1)   ELSE SELECT @Number8  = 0
  IF @Number9   >= 97 AND @Number9  <= 122  SELECT  @Number9  = (@Number9  - 97 + 1) *  power(26,2)   ELSE SELECT @Number9  = 0
  IF @Number10  >= 97 AND @Number10 <= 122  SELECT  @Number10 = (@Number10 - 97 + 1) *  power(26,3)   ELSE SELECT @Number10 = 0
  IF @Number11  >= 97 AND @Number11 <= 122  SELECT  @Number11 = (@Number11 - 97 + 1) *  power(26,4)   ELSE SELECT @Number11 = 0
  IF @Number12  >= 97 AND @Number12 <= 122  SELECT  @Number12 = (@Number12 - 97 + 1) *  power(26,5)   ELSE SELECT @Number12 = 0
  --                                              
  SET @Result = @Number1  + 
                @Number2  + 
                @Number3  + 
                @Number4  + 
                @Number5  + 
                @Number6  + 
         CAST( (@Number7  + 
                @Number8  + 
                @Number9  + 
                @Number10 + 
                @Number11 + 
                @Number12 ) as bigint)  * 2147483647
--
RETURN @Result
END
GO

-----------------------------------------------------------------------------------------------------------------------------------------------------
--SELECT dbo.TextToFloat('1/4kg of Potatos')
-----------------------------------------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[TextToFloat] 
( 
  @Input varchar(max) 
) 
RETURNS float AS
--declare @input varchar(max); set @input = '23.6g of Potatos'
--declare @input varchar(max); set @input = '1/4kg of Potatos'
BEGIN
  --
  DECLARE @NUMBER_PARTS  varchar(20); SET @NUMBER_PARTS  = '0123456789,./'  
  DECLARE @FRACTION_PART varchar(20); SET @FRACTION_PART = '/'  
  --  
  DECLARE @UNIT_MATCHES TABLE (UnitMatch varchar(max) )  
  --
  INSERT INTO @UNIT_MATCHES
  SELECT DISTINCT rtrim(UnitName)  + ' ' FROM [UNIT]
  UNION SELECT    rtrim(ShortName) + ' ' FROM [UNIT]

  DELETE FROM @UNIT_MATCHES WHERE datalength(UnitMatch) < 2

  DECLARE
    @i             integer,
    @c             char(1),
    @Number        varchar(100),
    @NumberStart   integer,
    @NumberEnd     integer,
    @Length        integer,
    @FractionPos   integer,
    @Nominator     integer,
    @Denomiator    integer,
    @result        float

  SET @i           = 1
  SET @NumberStart = 0
  SET @NumberEnd   = 0
  SET @FractionPos = 0

  SET @result = 0

  DECLARE 
    @Text    varchar(max); 
  SET 
    @Text = lower(@input) + ' '
    
  SELECT
    @Length = datalength(@input)
    
  WHILE (@i < @Length) BEGIN
    --
    SELECT @c = substring(@input, @i, 1)
    --
    IF @NumberStart = 0 BEGIN
      --
      IF charindex(@c, @NUMBER_PARTS, 1) > 0 BEGIN
        --
        SET @NumberStart = @i
      END
    END ELSE BEGIN
      --
      IF charindex(@c, @NUMBER_PARTS, 1) = 0 BEGIN
        --
        SET @NumberEnd = @i-1
        --
        BREAK
      END
    END
    --
    SET @i = @i + 1
  END  

  IF @NumberStart <> 0 BEGIN
    --
    IF @NumberEnd = 0
      SET @NumberEnd = @Length
    --
    SELECT @Number = substring(@input, @NumberStart, @NumberEnd)
    --
    SELECT @FractionPos = charindex(@FRACTION_PART, @Number, 1)
    --
    IF @FractionPos <> 0 BEGIN
      --
      SET @Nominator  = dbo.StringToInteger(substring(@Number, 1,              @FractionPos-1                    ) )
      SET @Denomiator = dbo.StringToInteger(substring(@Number, @FractionPos+1, datalength(@Number)-@FractionPos+1) )
    
      IF @Denomiator > 0
        SELECT  @result = cast(@Nominator as float)/cast(@Denomiator as float)
       
    
    END ELSE BEGIN
      

      SELECT @result = dbo.StringToFloat(@Number)

    END
    
  END  
  --SELECT @result
  RETURN @result
END
GO


 

