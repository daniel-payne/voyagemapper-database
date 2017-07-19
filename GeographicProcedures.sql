---------------------------------------------------------------------------------------------------
--Drops
---------------------------------------------------------------------------------------------------

IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'GetContextsForReferences'                 AND type = 'P') DROP PROCEDURE Geographic.GetContextsForReferences

IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'FindLocationForLatLong'                   AND type = 'P') DROP PROCEDURE Geographic.FindLocationForLatLong
IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'FindContextForLatLong'                    AND type = 'P') DROP PROCEDURE Geographic.FindContextForLatLong

IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'MatchAddress'                             AND type = 'P') DROP PROCEDURE Geographic.MatchAddress
IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'MatchCountriesInText'                     AND type = 'P') DROP PROCEDURE Geographic.MatchCountriesInText

go

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- EXEC Geographic.GetContextsForReferences '170:7:25, 239:1:13:45306, 239:1:58:45952'
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE Geographic.GetContextsForReferences
(
  @References varchar(max)
)
AS

  SELECT
    ContextReference, 
    ContextFullName, 
    TZID
  FROM
    Geographic.Context
  WHERE
    ContextReference IN (SELECT item FROM dbo.ListToTable(@References, ','))

RETURN @@ROWCOUNT
go

GRANT EXECUTE ON Geographic.GetContextsForReferences TO restclient
go



-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- EXEC Geographic.FindContextForLatLong 33.40, 73.10  
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE Geographic.FindContextForLatLong
(
  @Latitude  float, 
  @Longitude float
)
AS
DECLARE @Point geography

DECLARE @ContextReference varchar(20)

SET @Point = geography::STPointFromText('POINT(' + CAST(@Longitude AS VARCHAR(20)) + ' ' + CAST(@Latitude AS VARCHAR(20)) + ')', 4326)

SELECT
  @ContextReference = ContextReference 
FROM
  Geographic.Conurbation
WHERE
  ConurbationGeography.STContains(@Point) = 1

IF @ContextReference IS NULL BEGIN

  SELECT
    @ContextReference = ContextReference 
  FROM
    Geographic.Boundary
  WHERE
    BoundaryGeography.STContains(@Point) = 1

END

SELECT @ContextReference 'contextReference'   

RETURN @@ROWCOUNT
go

GRANT EXECUTE ON Geographic.FindContextForLatLong TO restclient
GO


-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- EXEC Geographic.FindLocationForLatLong 33.40, 73.10  
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE Geographic.FindLocationForLatLong
(
  @Latitude  float, 
  @Longitude float
)
AS
DECLARE @Point geography

DECLARE @BoundaryCountryNo         int
DECLARE @BoundaryStateNo           int
DECLARE @BoundaryCountyNo          int
DECLARE @BoundaryFullName          varchar(255)

DECLARE @ConurbationID             int
DECLARE @ConurbationCountryNo      int
DECLARE @ConurbationStateNo        int
DECLARE @ConurbationCountyNo       int
DECLARE @ConurbationFullName       varchar(255)

SET @Point = geography::STPointFromText('POINT(' + CAST(@Longitude AS VARCHAR(20)) + ' ' + CAST(@Latitude AS VARCHAR(20)) + ')', 4326)

SELECT
  @BoundaryCountryNo = CountryNo,
  @BoundaryStateNo   = StateNo,  
  @BoundaryCountyNo  = CountyNo,
  @BoundaryFullName  = BoundaryFullName 
FROM
  Geographic.Boundary
WHERE
  BoundaryGeography.STContains(@Point) = 1

SELECT
  @ConurbationID        = ConurbationID,
  @ConurbationCountryNo = CountryNo,
  @ConurbationStateNo   = StateNo,  
  @ConurbationCountyNo  = CountyNo, 
  @ConurbationFullName  = ConurbationFullName
FROM
  Geographic.Conurbation
WHERE
  ConurbationGeography.STContains(@Point) = 1

SELECT 

 ISNULL(@ConurbationFullName,@BoundaryFullName)    'locationFullName',
 ISNULL(@ConurbationCountryNo,@BoundaryCountryNo)  'countryNo',       
 ISNULL(@ConurbationStateNo,@BoundaryStateNo)      'stateNo',        
 ISNULL(@ConurbationCountyNo,@BoundaryCountyNo)    'countyNo',      
 @ConurbationID                                    'conurbationID'          

RETURN @@ROWCOUNT
go

GRANT EXECUTE ON Geographic.FindLocationForLatLong TO restclient
GO

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- EXEC Geographic.MatchCountriesInText 'Kenya travel advice - GOV.UK'
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE Geographic.MatchCountriesInText
(
  @Text varchar(max)
)
AS

DECLARE @CountyNo   integer 
DECLARE @MatchText varchar(max) = ' ' + dbo.TextToSimpleString(@Text) + ' '  

SELECT TOP 1
  @CountyNo = C.CountryNo 
FROM
  Geographic.Country C
WHERE
  charindex(C.CountryMatchName, @MatchText) > 0
ORDER BY
  datalength(C.CountryName) DESC 

IF @CountyNo IS NULL
    SELECT TOP 1
      @CountyNo = C.CountryNo 
    FROM
      Geographic.Country C  
    WHERE
      charindex(C.CountryMatchName, @MatchText) > 0
    ORDER BY
      datalength(C.CountryName) DESC 

SELECT
  @CountyNo 'CountryNo'

RETURN @@ROWCOUNT
go

GRANT EXECUTE ON Geographic.MatchCountriesInText TO restclient
go

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- EXEC Geographic.MatchAddress 'Winnipeg, MB, Canada'
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE Geographic.MatchAddress
(
  @ADDRESS varchar(max) 
)
AS

DECLARE @RowNumber     integer
DECLARE @Name          varchar(255)
DECLARE @LocationName  varchar(255)

DECLARE @CountryFound bit = 0
DECLARE @StateFound   bit = 0
DECLARE @CountyFound  bit = 0

DECLARE @RegionFound  bit = 0

DECLARE @ITEMS   TABLE (RowNumber integer, Item varchar(max))

DECLARE @REGIONS TABLE (RowNumber integer, MatchName varchar(max), CountryNo integer, StateNo integer, CountyNo integer, LocationID integer, FullName varchar(500))

DECLARE @PLACES  TABLE (RowNumber integer, MatchName varchar(max), CountryNo integer, StateNo integer, CountyNo integer, LocationID integer, IsConurbation bit, FullName varchar(500), CoverageGeography geography )

INSERT INTO @ITEMS
  SELECT
    RowNumber, 
    Item 
  FROM
    dbo.ListToTableWithRowNumber(@ADDRESS, ',')


INSERT INTO @REGIONS (RowNumber, MatchName, CountryNo, FullName) 
  SELECT
    I.RowNumber,
    C.CountryName,
    C.CountryNo,
    C.CountryName
  FROM
    Geographic.Country C
  INNER JOIN
    @ITEMS I ON I.Item = C.CountryName

IF NOT EXISTS (SELECT 1 FROM @REGIONS WHERE CountryNo IS NOT NULL) 
  INSERT INTO @REGIONS (RowNumber, MatchName, CountryNo, FullName) 
    SELECT
      I.RowNumber,
      C.CountryName,
      C.CountryNo,
      PC.CountryName
    FROM
      Geographic.CountryName C
    INNER JOIN
      Geographic.Country PC ON PC.CountryID = C.CountryID
    INNER JOIN
      @ITEMS I ON I.Item = C.CountryName

IF EXISTS (SELECT 1 FROM @REGIONS WHERE CountryNo IS NOT NULL) 
  SET @CountryFound = 1

INSERT INTO @REGIONS (RowNumber, MatchName, CountryNo, StateNo, FullName) 
  SELECT
    I.RowNumber,
    S.StateName,
    S.CountryNo,
    S.StateNo,
    S.StateFullName
  FROM
    Geographic.State S
  INNER JOIN
    @ITEMS I ON I.Item = S.StateName
  WHERE
    (@CountryFound = 0)
    OR
    (S.CountryNo IN (SELECT CountryNo FROM @REGIONS))

IF NOT EXISTS (SELECT 1 FROM @REGIONS WHERE StateNo IS NOT NULL) 
  INSERT INTO @REGIONS (RowNumber, MatchName, CountryNo, StateNo, FullName) 
    SELECT
      I.RowNumber,
      S.StateName,
      S.CountryNo,
      S.StateNo,
      PS.StateFullName
    FROM
      Geographic.StateName S
    INNER JOIN
      Geographic.State PS ON PS.StateID = S.StateID
    INNER JOIN
      @ITEMS I ON I.Item = S.StateName
    WHERE
      (@CountryFound = 0)
      OR
      (S.CountryNo IN (SELECT CountryNo FROM @REGIONS))

IF EXISTS (SELECT 1 FROM @REGIONS WHERE StateNo IS NOT NULL)  
  SET @StateFound = 1

INSERT INTO @REGIONS (RowNumber, MatchName, CountryNo, StateNo, CountyNo, FullName) 
  SELECT
    I.RowNumber,
    C.CountyName,
    C.CountryNo,
    C.StateNo,
    C.CountyNo,
    C.CountyFullName
  FROM
    Geographic.County C
  INNER JOIN
    @ITEMS I ON I.Item = C.CountyName
  WHERE
    (@StateFound = 0)
    OR
    (C.StateNo IN (SELECT StateNo FROM @REGIONS WHERE CountryNo = C.CountryNo))

IF NOT EXISTS (SELECT 1 FROM @REGIONS WHERE CountyNo IS NOT NULL)  
  INSERT INTO @REGIONS (RowNumber, MatchName, CountryNo, StateNo, CountyNo, FullName) 
    SELECT
      I.RowNumber,
      C.CountyName,
      C.CountryNo,
      C.StateNo,
      C.CountyNo,
      PC.CountyFullName
    FROM
      Geographic.CountyName C
    INNER JOIN
      Geographic.County PC ON PC.CountyID = C.CountyID
    INNER JOIN
      @ITEMS I ON I.Item = C.CountyName
    WHERE
      (@StateFound = 0)
      OR
      (C.StateNo IN (SELECT StateNo FROM @REGIONS WHERE CountryNo = C.CountryNo))

IF EXISTS (SELECT 1 FROM @REGIONS)
  SET @RegionFound = 1

INSERT INTO @PLACES (RowNumber, MatchName, CountryNo, StateNo, CountyNo, LocationID, IsConurbation, FullName) 
  SELECT
    I.RowNumber,
    P.ConurbationName,
    P.CountryNo,
    P.StateNo,
    P.CountyNo,
    P.ConurbationID,
    1 'IsConurbation',
    P.ConurbationFullName
  FROM
    Geographic.Conurbation P
  INNER JOIN
    @ITEMS I ON I.Item = P.ConurbationName
  WHERE
    (@RegionFound = 0)
    OR
    (P.CountryNo IN (SELECT CountryNo FROM @REGIONS WHERE RowNumber > I.RowNumber))

IF NOT EXISTS (SELECT 1 FROM @PLACES WHERE IsConurbation IS NOT NULL)  
  INSERT INTO @PLACES (RowNumber, MatchName, CountryNo, StateNo, CountyNo, LocationID, IsConurbation, FullName) 
    SELECT
      I.RowNumber,
      P.ConurbationName,
      P.CountryNo,
      P.StateNo,
      P.CountyNo,
      P.ConurbationID,
      1 'IsConurbation',
      PP.ConurbationFullName
    FROM
      Geographic.ConurbationName P
    INNER JOIN
      Geographic.Conurbation PP ON PP.ConurbationID = P.ConurbationID
    INNER JOIN
      @ITEMS I ON I.Item = P.ConurbationName
    WHERE
      (@RegionFound = 0)
      OR
      (P.CountryNo IN (SELECT CountryNo FROM @REGIONS WHERE RowNumber > I.RowNumber))

IF NOT EXISTS (SELECT 1 FROM @PLACES WHERE IsConurbation IS NOT NULL) 
  INSERT INTO @PLACES (RowNumber, MatchName, CountryNo, StateNo, CountyNo, LocationID, IsConurbation, FullName) 
    SELECT D.* FROM
    (
      SELECT
        I.RowNumber,
        P.SettlementName,
        P.CountryNo,
        P.StateNo,
        P.CountyNo,
        P.SettlementID,
        0 'IsConurbation',
        P.SettlementFullName
      FROM
        Geographic.Settlement P
      INNER JOIN
        @ITEMS I ON I.Item = P.SettlementName
    ) D
    WHERE
      (@RegionFound = 0)
      OR
      (
        (CountryNo IN (SELECT CountryNo                     FROM @REGIONS WHERE RowNumber > D.RowNumber )) AND
        (StateNo   IN (SELECT ISNULL(StateNo,  D.StateNo)   FROM @REGIONS WHERE RowNumber > D.RowNumber )) AND
        (CountyNo  IN (SELECT ISNULL(CountyNo, D.CountyNo)  FROM @REGIONS WHERE RowNumber > D.RowNumber ))
      )

IF NOT EXISTS (SELECT 1 FROM @PLACES WHERE IsConurbation IS NOT NULL) 
  INSERT INTO @PLACES (RowNumber, MatchName, CountryNo, StateNo, CountyNo, LocationID, IsConurbation, FullName) 
    SELECT D.* FROM
    (
      SELECT
        I.RowNumber,
        P.SettlementName,
        P.CountryNo,
        P.StateNo,
        P.CountyNo,
        P.SettlementID,
        0 'IsConurbation',
        PP.SettlementFullName 
      FROM
        Geographic.SettlementName P
      INNER JOIN
        Geographic.Settlement PP ON PP.SettlementID = P.SettlementID
      INNER JOIN
        @ITEMS I ON I.Item = P.SettlementName
    ) D
    WHERE
      (@RegionFound = 0)
      OR
      (
        (CountryNo IN (SELECT CountryNo                     FROM @REGIONS WHERE RowNumber > D.RowNumber )) AND
        (StateNo   IN (SELECT ISNULL(StateNo,  D.StateNo)   FROM @REGIONS WHERE RowNumber > D.RowNumber )) AND
        (CountyNo  IN (SELECT ISNULL(CountyNo, D.CountyNo)  FROM @REGIONS WHERE RowNumber > D.RowNumber ))
      )

IF NOT EXISTS (SELECT 1 FROM @PLACES) 
  INSERT INTO @PLACES (RowNumber, MatchName, CountryNo, StateNo, CountyNo, LocationID, IsConurbation, FullName) 
    SELECT
      RowNumber, 
      MatchName, 
      CountryNo, 
      StateNo, 
      CountyNo, 
      NULL 'LocationID', 
      NULL 'IsConurbation', 
      FullName
    FROM
      @REGIONS
    WHERE
      RowNumber = (SELECT min(RowNumber) FROM @REGIONS)

IF EXISTS (SELECT 1 FROM @PLACES WHERE IsConurbation = 1) 
  UPDATE P SET
    CoverageGeography = C.ConurbationGeography
  FROM
    @PLACES P
  INNER JOIN
    Geographic.Conurbation C ON C.ConurbationID = P.LocationID
  WHERE
    IsConurbation = 1

IF EXISTS (SELECT 1 FROM @PLACES WHERE IsConurbation = 0) 
  UPDATE P SET
    CoverageGeography = B.BoundaryGeography
  FROM
    @PLACES P
  INNER JOIN
    Geographic.Settlement S ON S.SettlementID = P.LocationID
  INNER JOIN
    Geographic.Boundary B ON B.BoundaryID = S.BoundaryID
  WHERE
    IsConurbation = 0

IF EXISTS (SELECT 1 FROM @PLACES WHERE IsConurbation IS NULL AND CountyNo IS NOT NULL) 
  UPDATE P SET
    CoverageGeography = C.CountyGeography
  FROM
    @PLACES P
  INNER JOIN
    Geographic.County C ON C.CountryNo = P.CountryNo AND C.StateNo = P.StateNo AND C.CountyNo = P.CountyNo
  WHERE
    P.IsConurbation IS NULL AND P.CountyNo IS NOT NULL

IF EXISTS (SELECT 1 FROM @PLACES WHERE IsConurbation IS NULL AND StateNo IS NOT NULL AND CountyNo IS NULL) 
  UPDATE P SET
    CoverageGeography = S.StateGeography
  FROM
    @PLACES P
  INNER JOIN
    Geographic.State S ON S.CountryNo = P.CountryNo AND S.StateNo = P.StateNo  
  WHERE
    P.IsConurbation IS NULL AND P.StateNo IS NOT NULL AND P.CountyNo IS NULL

IF EXISTS (SELECT 1 FROM @PLACES WHERE IsConurbation IS NULL AND CountryNo IS NOT NULL AND StateNo IS NULL) 
  UPDATE P SET
    CoverageGeography = CASE 
                           WHEN GeographyDataSize > 2000000 THEN C.CountryOutline10K
                           WHEN GeographyDataSize >  100000 THEN C.CountryOutline5K
                                                            ELSE C.CountryOutline1K
                        END
  FROM
    @PLACES P
  INNER JOIN
    Geographic.Country C ON C.CountryNo = P.CountryNo  
  WHERE
    P.IsConurbation IS NULL AND P.CountryNo IS NOT NULL AND P.StateNo IS NULL

--SELECT * FROM @REGIONS ORDER BY RowNumber ASC
SELECT 
  FullName, 
  CountryNo, 
  StateNo, 
  CountyNo, 
  IsConurbation,   
  LocationID,
  CoverageGeography 
FROM 
  @PLACES   

RETURN @@ROWCOUNT
go

GRANT EXECUTE ON Geographic.MatchAddress TO restclient
go

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---- EXEC Geographic.MatchAccommodation 'Sheraton Gateway Los Angeles'
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--CREATE PROCEDURE Geographic.MatchAccommodation
--(
--  @Text varchar(255),
--  @Take int    = 10
--)
--AS

--SET @Text = REPLACE(@Text, ' ', '%') + '%'

--SELECT DISTINCT TOP (@Take) * 
--FROM
--(

--SELECT
--  T.AccommodationID,
--  TN.AccommodationName      'matchName',
--  T.AccommodationName,
--  T.AccommodationShortCode,
--  T.AccommodationLongCode,
--  T.CountryNo,
--  T.StateNo,
--  T.CountyNo,
--  T.ConurbationID,
--  T.AccommodationCenterLatitude,
--  T.AccommodationCenterLongitude,
--  datalength(TN.AccommodationName) 'length'
--FROM 
--  Geographic.AccommodationName TN
--INNER JOIN
--  Geographic.Accommodation     T ON T.AccommodationID = TN.AccommodationID
--WHERE 
--  TN.AccommodationName LIKE @Text
 

--UNION

--SELECT  
--  T.AccommodationID,
--  T.AccommodationName      'matchName',
--  T.AccommodationName,
--  T.AccommodationShortCode,
--  T.AccommodationLongCode,
--  T.CountryNo,
--  T.StateNo,
--  T.CountyNo,
--  T.ConurbationID,
--  T.AccommodationCenterLatitude,
--  T.AccommodationCenterLongitude,
--  datalength(T.AccommodationName)
--FROM 
--  Geographic.Accommodation T
--WHERE
--  T.AccommodationName  LIKE @Text
 

--) D
--ORDER BY 
--  length ASC

--RETURN @@ROWCOUNT
--GO

--GRANT EXECUTE ON Geographic.MatchAccommodation TO restclient
--go

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---- EXEC Geographic.MatchTransitPointAirport 'lax'
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--CREATE PROCEDURE Geographic.MatchTransitPointAirport
--(
--  @Text varchar(255),
--  @Take int    = 10
--)
--AS

--SET @Text = REPLACE(@Text, ' ', '%') + '%'

--SELECT DISTINCT TOP (@Take) * 
--FROM
--(

--SELECT
--  T.TransitpointID,
--  TN.TransitpointName      'matchName',
--  T.TransitpointName,
--  T.TransitpointShortCode,
--  T.TransitpointLongCode,
--  T.CountryNo,
--  T.StateNo,
--  T.CountyNo,
--  T.ConurbationID,
--  datalength(TN.TransitpointName) 'length'
--FROM 
--  Geographic.TransitpointName TN
--INNER JOIN
--  Geographic.Transitpoint     T ON T.TransitpointID = TN.TransitpointID
--WHERE 
--  TN.TransitpointName LIKE @Text
--AND
--  T.TransitpointType = 'S-AIRP'

--UNION

--SELECT  
--  T.TransitpointID,
--  T.TransitpointName      'matchName',
--  T.TransitpointName,
--  T.TransitpointShortCode,
--  T.TransitpointLongCode,
--  T.CountryNo,
--  T.StateNo,
--  T.CountyNo,
--  T.ConurbationID,
--  datalength(T.TransitpointName)
--FROM 
--  Geographic.Transitpoint T
--WHERE
--  T.TransitpointName  LIKE @Text
--AND
--  T.TransitpointType = 'S-AIRP'

--) D
--ORDER BY 
--  length ASC

--RETURN @@ROWCOUNT
--go

--GRANT EXECUTE ON Geographic.MatchTransitPointAirport TO restclient
--go

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---- EXEC Geographic.MatchTransitPoint 'heathrow'
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--CREATE PROCEDURE Geographic.MatchTransitPoint
--(
--  @Text varchar(255),
--  @Take int    = 10
--)
--AS

--SET @Text = REPLACE(@Text, ' ', '%') + '%'

--SELECT DISTINCT TOP (@Take) * 
--FROM
--(
--SELECT
--  T.TransitpointID,
--  TN.TransitpointName      'matchName',
--  T.TransitpointName,
--  T.TransitpointShortCode,
--  T.TransitpointLongCode,
--  T.TransitpointType,
--  T.CountryNo,
--  T.StateNo,
--  T.CountyNo,
--  T.ConurbationID,
--  datalength(TN.TransitpointName) 'length'
--FROM 
--  Geographic.TransitpointName TN
--INNER JOIN
--  Geographic.Transitpoint     T ON T.TransitpointID = TN.TransitpointID
--WHERE 
--  TN.TransitpointName LIKE @Text

--UNION

--SELECT  
--  T.TransitpointID,
--  T.TransitpointName      'matchName',
--  T.TransitpointName,
--  T.TransitpointShortCode,
--  T.TransitpointLongCode,
--  T.TransitpointType,
--  T.CountryNo,
--  T.StateNo,
--  T.CountyNo,
--  T.ConurbationID,
--  datalength(T.TransitpointName)
--FROM 
--  Geographic.Transitpoint T
--WHERE
--  T.TransitpointName  LIKE @Text
--) D
--ORDER BY 
--  length ASC

--RETURN @@ROWCOUNT
--go

--GRANT EXECUTE ON Geographic.MatchTransitPoint TO restclient
--GO 

-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
---- EXEC Geographic.MatchConurbationOrSettlementPoint 'ch' 
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--CREATE PROCEDURE Geographic.MatchConurbationOrSettlementPoint
--(
--  @Text varchar(255),
--  @Take int    = 10
--)
--AS

--DECLARE @TotalCount  int          = 0
--DECLARE @LikeText    varchar(255) = REPLACE(@Text, ' ', '%') + '%'
--DECLARE @MarchLength int          = datalength(@Text)

--DECLARE @FILTER TABLE
--(
--  countryNo        integer
--)

--DECLARE @RESULTS TABLE (
--  OrderSequence    int IDENTITY(1,1),
--  sourceType       char(5),
--  sourceID         integer,
--  sourceName       varchar(255),
--  countryNo        integer,
--  stateNo          integer,
--  countyNo         integer,
--  conurbationID    integer,
--  latitude         float,
--  longitude        float
--)

--INSERT INTO @FILTER (CountryNo) 
--  SELECT CountryNo FROM Geographic.CountryName WHERE CountryName = @Text 
--INSERT INTO @FILTER (CountryNo) 
--  SELECT CountryNo FROM Geographic.Country     WHERE CountryName = @Text

--IF EXISTS (SELECT 1 FROM @FILTER) BEGIN

--    INSERT INTO @RESULTS
--      SELECT  
--        'CONCO'                        'sourceType',
--        T.ConurbationID                'sourceID',
--        T.ConurbationName              'sourceName',
--        T.CountryNo                    'countryNo',
--        T.StateNo                      'stateNo',
--        T.CountyNo                     'countyNo',
--        T.ConurbationID                'conurbationID',
--        T.ConurbationCenterLatitude    'latitude',
--        T.ConurbationCenterLongitude   'longitude'
--      FROM 
--        Geographic.Conurbation T
--      INNER JOIN
--        @FILTER F ON F.CountryNo = T.CountryNo
 
--END

--IF EXISTS (SELECT 1 FROM @RESULTS) BEGIN

--  SELECT TOP (@Take) 
--    sourceType,    
--    sourceID,     
--    sourceName,   
--    CAST(countryNo             AS varchar(20))            + ':' + 
--    ISNULL(CAST(stateNo        AS varchar(20))      , '') + ':' + 
--    ISNULL(CAST(countyNo       AS varchar(20))      , '') +  
--    ISNULL(':' + CAST(conurbationID  AS varchar(20)), '') 'contextReference',
--    latitude,     
--    longitude   
--  FROM 
--    @RESULTS 
--  ORDER BY 
--    OrderSequence

--  RETURN 

--END

--------------------------------------------------------------------------------------------------
 
--IF @TotalCount < @Take BEGIN

--  INSERT INTO @RESULTS
--    SELECT  
--      'CONUR'                        'sourceType',
--      T.ConurbationID                'sourceID',
--      T.ConurbationName              'sourceName',
--      T.CountryNo                    'countryNo',
--      T.StateNo                      'stateNo',
--      T.CountyNo                     'countyNo',
--      T.ConurbationID                'conurbationID',
--      T.ConurbationCenterLatitude    'latitude',
--      T.ConurbationCenterLongitude   'longitude'
--    FROM 
--      Geographic.Conurbation T
--    WHERE
--      T.ConurbationName = @Text
--    AND
--      T.ConurbationID NOT IN (SELECT sourceID FROM @RESULTS)

--  SELECT @TotalCount = @TotalCount + @@ROWCOUNT

--END

--IF @TotalCount < @Take BEGIN

--  INSERT INTO @RESULTS
--    SELECT  
--      'CONUR'                        'sourceType',
--      T.ConurbationID                'sourceID',
--      T.ConurbationName              'sourceName',
--      T.CountryNo                    'countryNo',
--      T.StateNo                      'stateNo',
--      T.CountyNo                     'countyNo',
--      T.ConurbationID                'conurbationID',
--      T.ConurbationCenterLatitude    'latitude',
--      T.ConurbationCenterLongitude   'longitude'
--    FROM 
--      Geographic.Conurbation T
--    INNER JOIN 
--      Geographic.ConurbationName N ON N.ConurbationID = T.ConurbationID
--    WHERE
--      N.ConurbationName = @Text
--    AND
--      T.ConurbationID NOT IN (SELECT sourceID FROM @RESULTS)

--  SELECT @TotalCount = @TotalCount + @@ROWCOUNT

--END

--IF @TotalCount < @Take BEGIN

--  INSERT INTO @RESULTS
--    SELECT  
--      'CONUR'                        'sourceType',
--      T.ConurbationID                'sourceID',
--      T.ConurbationName              'sourceName',
--      T.CountryNo                    'countryNo',
--      T.StateNo                      'stateNo',
--      T.CountyNo                     'countyNo',
--      T.ConurbationID                'conurbationID',
--      T.ConurbationCenterLatitude    'latitude',
--      T.ConurbationCenterLongitude   'longitude'
--    FROM 
--      Geographic.Conurbation T
--    WHERE
--      T.ConurbationName LIKE @LikeText
--    AND
--      T.ConurbationID NOT IN (SELECT sourceID FROM @RESULTS)

--  SELECT @TotalCount = @TotalCount + @@ROWCOUNT

--END

--IF @TotalCount < @Take BEGIN

--  INSERT INTO @RESULTS
--    SELECT  
--      'CONUR'                        'sourceType',
--      T.ConurbationID                'sourceID',
--      T.ConurbationName              'sourceName',
--      T.CountryNo                    'countryNo',
--      T.StateNo                      'stateNo',
--      T.CountyNo                     'countyNo',
--      T.ConurbationID                'conurbationID',
--      T.ConurbationCenterLatitude    'latitude',
--      T.ConurbationCenterLongitude   'longitude'
--    FROM 
--      Geographic.Conurbation T
--    INNER JOIN 
--      Geographic.ConurbationName N ON N.ConurbationID = T.ConurbationID
--    WHERE
--      N.ConurbationName LIKE @LikeText
--    AND
--      T.ConurbationID NOT IN (SELECT sourceID FROM @RESULTS)

--  SELECT @TotalCount = @TotalCount + @@ROWCOUNT

--END

--IF EXISTS (SELECT 1 FROM @RESULTS) BEGIN

--  SELECT TOP (@Take) 
--    sourceType,    
--    sourceID,     
--    sourceName,   
--    CAST(countryNo             AS varchar(20))            + ':' + 
--    ISNULL(CAST(stateNo        AS varchar(20))      , '') + ':' + 
--    ISNULL(CAST(countyNo       AS varchar(20))      , '') +  
--    ISNULL(':' + CAST(conurbationID  AS varchar(20)), '') 'contextReference',
--    latitude,     
--    longitude   
--  FROM 
--    @RESULTS 
--  ORDER BY 
--    OrderSequence

--  RETURN 

--END

--------------------------------------------------------------------------------------------------

--IF @TotalCount < @Take BEGIN

--  INSERT INTO @RESULTS
--    SELECT  
--      'SETTL'                       'sourceType',
--      T.SettlementID                'sourceID',
--      T.SettlementName              'sourceName',
--      T.CountryNo                   'countryNo',
--      T.StateNo                     'stateNo',
--      T.CountyNo                    'countyNo',
--      NULL                          'conurbationID',
--      T.SettlementCenterLatitude    'latitude',
--      T.SettlementCenterLongitude   'longitude'
--    FROM 
--      Geographic.Settlement T
--    WHERE
--      T.SettlementName = @Text
--    AND
--      T.SettlementID NOT IN (SELECT sourceID FROM @RESULTS)
--    SELECT @TotalCount = @@ROWCOUNT

--END

--IF @TotalCount < @Take BEGIN

--  INSERT INTO @RESULTS
--    SELECT  
--      'SETTL'                       'sourceType',
--      T.SettlementID                'sourceID',
--      N.SettlementName              'sourceName',
--      T.CountryNo                   'countryNo',
--      T.StateNo                     'stateNo',
--      T.CountyNo                    'countyNo',
--      NULL                          'conurbationID',
--      T.SettlementCenterLatitude    'latitude',
--      T.SettlementCenterLongitude   'longitude'
--    FROM 
--      Geographic.Settlement T
--    INNER JOIN
--      Geographic.SettlementName N ON N.SettlementID = T.SettlementID
--    WHERE
--      N.SettlementName = @Text
--    AND
--      T.SettlementID NOT IN (SELECT sourceID FROM @RESULTS)
--    ORDER BY
--      abs(datalength(T.SettlementName) - @MarchLength) ASC
--  SELECT @TotalCount = @@ROWCOUNT

--END

--IF @TotalCount < @Take BEGIN

--  INSERT INTO @RESULTS
--    SELECT  
--      'SETTL'                       'sourceType',
--      T.SettlementID                'sourceID',
--      T.SettlementName              'sourceName',
--      T.CountryNo                   'countryNo',
--      T.StateNo                     'stateNo',
--      T.CountyNo                    'countyNo',
--      NULL                          'conurbationID',
--      T.SettlementCenterLatitude    'latitude',
--      T.SettlementCenterLongitude   'longitude'
--    FROM 
--      Geographic.Settlement T
--    WHERE
--      T.SettlementName LIKE @LikeText
--    AND
--      T.SettlementID NOT IN (SELECT sourceID FROM @RESULTS)
--    SELECT @TotalCount = @@ROWCOUNT

--END

--IF @TotalCount < @Take BEGIN

--  INSERT INTO @RESULTS
--    SELECT  
--      'SETTL'                       'sourceType',
--      T.SettlementID                'sourceID',
--      N.SettlementName              'sourceName',
--      T.CountryNo                   'countryNo',
--      T.StateNo                     'stateNo',
--      T.CountyNo                    'countyNo',
--      NULL                          'conurbationID',
--      T.SettlementCenterLatitude    'latitude',
--      T.SettlementCenterLongitude   'longitude'
--    FROM 
--      Geographic.Settlement T
--    INNER JOIN
--      Geographic.SettlementName N ON N.SettlementID = T.SettlementID
--    WHERE
--      N.SettlementName LIKE @LikeText
--    AND
--      T.SettlementID NOT IN (SELECT sourceID FROM @RESULTS)
--    ORDER BY
--      abs(datalength(T.SettlementName) - @MarchLength) ASC
--  SELECT @TotalCount = @@ROWCOUNT

--END

--SELECT TOP (@Take) 
--  sourceType,    
--  sourceID,     
--  sourceName,   
--  CAST(countryNo             AS varchar(20))            + ':' + 
--  ISNULL(CAST(stateNo        AS varchar(20))      , '') + ':' + 
--  ISNULL(CAST(countyNo       AS varchar(20))      , '') +  
--  ISNULL(':' + CAST(conurbationID  AS varchar(20)), '') 'contextReference',
--  latitude,     
--  longitude   
--FROM 
--  @RESULTS 
--ORDER BY 
--  OrderSequence

--RETURN @@rowcount
--go