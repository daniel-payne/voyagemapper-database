---------------------------------------------------------------------------------------------------
--Drops
---------------------------------------------------------------------------------------------------
IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'MatchLocationLatLong'    AND type = 'P') DROP PROCEDURE Geographic.MatchLocationLatLong   
IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'MatchCountriesText'      AND type = 'P') DROP PROCEDURE Geographic.MatchCountriesText
IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'MatchLocationsText'      AND type = 'P') DROP PROCEDURE Geographic.MatchLocationsText
IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'MatchAddressText'        AND type = 'P') DROP PROCEDURE Geographic.MatchAddressText

IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'ListCountries'           AND type = 'P') DROP PROCEDURE Geographic.ListCountries
IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'ListStates'              AND type = 'P') DROP PROCEDURE Geographic.ListStates
IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'ListCounties'            AND type = 'P') DROP PROCEDURE Geographic.ListCounties
go
                                                               
---------------------------------------------------------------------------------------------------
--Old Procs
---------------------------------------------------------------------------------------------------
IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'GetCoverage'            AND type = 'P') DROP PROCEDURE Geographic.GetCoverage
IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'MatchBorders'           AND type = 'P') DROP PROCEDURE Geographic.MatchBorders
IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'GetCountry'             AND type = 'P') DROP PROCEDURE Geographic.GetCountry
IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'GetCountries'           AND type = 'P') DROP PROCEDURE Geographic.GetCountries
IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'GetStates'              AND type = 'P') DROP PROCEDURE Geographic.GetStates
IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'GetCounties'            AND type = 'P') DROP PROCEDURE Geographic.GetCounties
IF EXISTS (SELECT * FROM sysobjects WHERE name = 'GetCurrentLocation'     AND type = 'P') DROP PROCEDURE Geographic.GetCurrentLocation
go
 
---------------------------------------------------------------------------------------------------
-- Geographic.MatchAddressText 'Winnipeg,MB,Canada'
---------------------------------------------------------------------------------------------------
CREATE PROCEDURE [Geographic].[MatchAddressText]
(
  @AddressHint      varchar(max) 
)       
AS

DECLARE @ADDRESS  TABLE (ID integer IDENTITY(1,1) NOT NULL, Hint varchar(255) )

DECLARE @COUNTRIES   TABLE (CountryID  integer  )
DECLARE @STATES      TABLE (CountryID  integer, StateID    integer  )
DECLARE @BOUNDRIES   TABLE (CountryID  integer, StateID    integer, CountyID  integer  )
DECLARE @COVERAGES   TABLE (MatchName  varchar(255), CountryID  integer, PlaceID    integer, Coverage   geography) 
DECLARE @RESULTS     TABLE (MatchName  varchar(255), CountryID  integer, StateID    integer, CountyID  integer, PlaceID    integer, MatchGeography   geography  )

INSERT INTO @ADDRESS
  SELECT
    lower(item)
  FROM
    dbo.ListToTable(@AddressHint, ',')

INSERT INTO @COUNTRIES
  SELECT 
    CountryID
  FROM
    Geographic.CountryName 
  WHERE 
    CountryLowerName IN (SELECT TOP 1 Hint FROM @ADDRESS ORDER BY ID DESC)

IF @@ROWCOUNT > 0 BEGIN 

  DELETE FROM @ADDRESS WHERE ID = (SELECT max(ID) FROM @ADDRESS)

END

IF EXISTS (SELECT 1 FROM @COUNTRIES) BEGIN    

  INSERT INTO @STATES
    SELECT 
      CountryID, StateID
    FROM
      Geographic.StateName 
    WHERE 
      StateLowerName IN (SELECT TOP 1 Hint FROM @ADDRESS ORDER BY ID DESC)
    AND
      Countryid IN (SELECT CountryID FROM @COUNTRIES)

  IF @@ROWCOUNT > 0 BEGIN 

    DELETE FROM @ADDRESS WHERE ID = (SELECT max(ID) FROM @ADDRESS)

  END

END ELSE BEGIN
                   
  INSERT INTO @STATES
    SELECT 
      CountryID, StateID 
    FROM
      Geographic.StateName 
    WHERE 
      StateLowerName IN (SELECT TOP 1 Hint FROM @ADDRESS ORDER BY ID DESC)
  
  IF @@ROWCOUNT > 0 BEGIN 

    DELETE FROM @ADDRESS WHERE ID = (SELECT max(ID) FROM @ADDRESS)

  END

END
 

UPDATE @ADDRESS SET
  hint = dbo.TextToSimpleString(hint)

IF EXISTS (SELECT 1 FROM @STATES) BEGIN

  INSERT INTO @BOUNDRIES
    SELECT 
      B.CountryID, B.StateID, B.CountyID
    FROM
      Geographic.BoundaryName B
    INNER JOIN
      @STATES S ON S.CountryID = B.CountryID AND S.StateID = B.StateID
    WHERE
      B.BoundarySimpleName IN (SELECT Hint FROM @ADDRESS)

  IF EXISTS (SELECT 1 FROM @ADDRESS) BEGIN

    INSERT INTO @BOUNDRIES
      SELECT 
          B.CountryID, B.StateID, B.CountyID
        FROM
          Geographic.Boundary B
        INNER JOIN
          @STATES S ON S.CountryID = B.CountryID AND S.StateID = B.StateID
        INNER JOIN
          Geographic.Place P ON P.BoundaryID = B.BoundaryID                                                 
        INNER JOIN
          Geographic.PlaceName N ON N.PlaceID = P.PlaceID
        WHERE
          N.PlaceSimpleName IN (SELECT Hint FROM @ADDRESS ) 

    INSERT INTO @COVERAGES
      SELECT 
          P.PlaceName + ', ' + C.CountryName,
          P.CountryID,
          P.PlaceID,
          P.PlaceGeography
        FROM
          Geographic.Place P                                              
        INNER JOIN
          Geographic.PlaceName N ON N.PlaceID = P.PlaceID 
        INNER JOIN
          @STATES S ON S.CountryID = P.CountryID 
        INNER JOIN
          Geographic.Country C ON C.CountryID = S.CountryID
        WHERE
          N.PlaceSimpleName IN (SELECT Hint FROM @ADDRESS ) 
        AND
          P.PlaceGeography IS NOT NULL
      
  END

END ELSE IF EXISTS (SELECT 1 FROM @COUNTRIES) BEGIN
 
  INSERT INTO @BOUNDRIES
    SELECT 
      B.CountryID, B.StateID, B.CountyID
    FROM
      Geographic.BoundaryName B
    INNER JOIN
      @COUNTRIES S ON S.CountryID = B.CountryID  
    WHERE
      B.BoundarySimpleName IN (SELECT Hint FROM @ADDRESS)

  IF EXISTS (SELECT 1 FROM @ADDRESS) BEGIN

    INSERT INTO @BOUNDRIES
      SELECT 
          B.CountryID, B.StateID, B.CountyID
        FROM
          Geographic.Boundary B
        INNER JOIN
          @COUNTRIES C ON C.CountryID = B.CountryID  
        INNER JOIN
          Geographic.Place P ON P.BoundaryID = B.BoundaryID                                                 
        INNER JOIN
          Geographic.PlaceName N ON N.PlaceID = P.PlaceID
        WHERE
          N.PlaceSimpleName IN (SELECT Hint FROM @ADDRESS )
    
    INSERT INTO @COVERAGES
      SELECT 
          P.PlaceName + ', ' + Y.CountryName,
          P.CountryID,
          P.PlaceID,
          P.PlaceGeography
        FROM
          Geographic.Place P                                              
        INNER JOIN
          Geographic.PlaceName N ON N.PlaceID = P.PlaceID 
        INNER JOIN
          @COUNTRIES C ON C.CountryID = P.CountryID  
        INNER JOIN
          Geographic.Country Y ON Y.CountryID = C.CountryID
        WHERE
          N.PlaceSimpleName IN (SELECT Hint FROM @ADDRESS ) 
        AND
          P.PlaceGeography IS NOT NULL

  END

END ELSE BEGIN

  INSERT INTO @BOUNDRIES
    SELECT 
      B.CountryID, B.StateID, B.CountyID
    FROM
      Geographic.BoundaryName B
    WHERE
      B.BoundarySimpleName IN (SELECT Hint FROM @ADDRESS)

  IF EXISTS (SELECT 1 FROM @ADDRESS) BEGIN

    INSERT INTO @BOUNDRIES
      SELECT 
          B.CountryID, B.StateID, B.CountyID
        FROM
          Geographic.Boundary B
        INNER JOIN
          Geographic.Place P ON P.BoundaryID = B.BoundaryID                                                 
        INNER JOIN
          Geographic.PlaceName N ON N.PlaceID = P.PlaceID
        WHERE
          N.PlaceSimpleName IN (SELECT Hint FROM @ADDRESS )

    INSERT INTO @COVERAGES
      SELECT 
          P.PlaceName + ', ' + C.CountryName,
          P.CountryID,
          P.PlaceID,
          P.PlaceGeography
        FROM
          Geographic.Place P                                              
        INNER JOIN
          Geographic.PlaceName N ON N.PlaceID = P.PlaceID 
       INNER JOIN
          Geographic.Country   C ON C.CountryID = P.CountryID
        WHERE
          N.PlaceSimpleName IN (SELECT Hint FROM @ADDRESS ) 
        AND
          P.PlaceGeography IS NOT NULL

  END
END

IF EXISTS (SELECT 1 FROM @BOUNDRIES) BEGIN

  INSERT INTO @RESULTS (MatchName, CountryID, StateID, CountyID, MatchGeography)
    SELECT
    O.CountyName + ', ' + S.StateName + ', ' + C.CountryName, C.CountryID, S.StateID, O.CountyID, O.CountyGeography
    FROM
      ( SELECT DISTINCT CountryID, StateID, CountyID FROM @BOUNDRIES ) M
    INNER JOIN
      Geographic.Country C ON C.CountryID = M.CountryID  
    LEFT OUTER  JOIN
      Geographic.State   S ON S.CountryID = M.CountryID AND S.StateID = M.StateID
    LEFT OUTER JOIN
      Geographic.County  O ON O.CountryID = M.CountryID AND O.StateID = M.StateID AND O.CountyID = M.CountyID

END ELSE IF EXISTS (SELECT 1 FROM @STATES) BEGIN

  INSERT INTO @RESULTS (MatchName, CountryID, StateID, CountyID, MatchGeography)
    SELECT 
         S.StateName + ', ' + C.CountryName, S.CountryID, S.StateID,  null, S.StateOutline1K
      FROM
        Geographic.State S
      INNER JOIN
        @STATES M ON M.CountryID = S.CountryID AND M.StateID = S.StateID
       INNER JOIN
          Geographic.Country   C ON C.CountryID = S.CountryID

END ELSE IF EXISTS (SELECT 1 FROM @COUNTRIES) BEGIN

  INSERT INTO @RESULTS (MatchName, CountryID, StateID, CountyID, MatchGeography)
    SELECT 
         C.CountryName, C.CountryID, null 'StateID', null 'CountyID',  C.CountryOutline5K
      FROM
        Geographic.Country C
      INNER JOIN
        @COUNTRIES M ON M.CountryID = C.CountryID  

END

INSERT INTO @RESULTS (MatchName, CountryID, PlaceID, MatchGeography)
  SELECT
    MatchName, 
    CountryID,
    PlaceID,
    Coverage
  FROM
    @COVERAGES

SELECT 
  LOWER(MatchName)  'matchName',
  CountryID         'countryID', 
  StateID           'stateID',
  CountyID          'countyID', 
  PlaceID           'placeId',
  MatchGeography    'matchGeography'
FROM 
  @RESULTS         R

RETURN @@ROWCOUNT
go

GRANT EXECUTE ON [Geographic].[MatchAddressText] TO [rest.client]
GO

---------------------------------------------------------------------------------------------------
-- Geographic.MatchLocationLatLong 51.093471, 0.00362 
---------------------------------------------------------------------------------------------------
CREATE PROCEDURE [Geographic].[MatchLocationLatLong]
(
  @Latitude       float,          
  @Longitude      float 
)       
AS
     
DECLARE @Location Geography = geography::Point( @latitude, @longitude , 4326)

SELECT 
  cast (@latitude  as varchar(10)) + ' ' +
  cast (@longitude as varchar(10)) 'matchName',

	C.CountryID               'countryId', 
	C.ISO3Code                'iso3Code', 
	C.CountryName             'countryName', 
	S.StateID                 'stateId',
	S.StateName               'stateName',
  S.StateReference          'stateReference',
	O.CountyID                'countyId',
	O.CountyName              'countyName',
  O.CountyReference         'countyReference',
	B.TZID                    'tzid' 
FROM
	Geographic.Boundary  B
LEFT OUTER JOIN
	Geographic.Country   C ON C.CountryID = B.CountryID
LEFT OUTER JOIN
	Geographic.State     S ON S.CountryID = B.CountryID AND S.StateID   = B.StateID 
LEFT OUTER JOIN
	Geographic.County    O ON O.CountryID = B.CountryID AND O.StateID   = B.StateID AND O.CountyID  = B.CountyID 
WHERE
	BoundaryGeography.STContains(@Location) = 1

--      
RETURN @@rowcount
GO

GRANT EXECUTE ON [Geographic].[MatchLocationLatLong] TO [rest.client]
GO
 
---------------------------------------------------------------------------------------------------
-- Geographic.MatchLocationsText 'the fco advise against all travel to the surobi, paghman, musayhi, khake jabbar and chahar asyab districts of kabul province and the pakistani border', 'AF' 
-- Geographic.MatchLocationsText 'Antalya explosion Huge car bomb rocks British tourist hotspot in Turkey', 'Turkey'
---------------------------------------------------------------------------------------------------
CREATE PROCEDURE [Geographic].[MatchLocationsText]
(
  @Text             varchar(max),          
  @CountryHint      varchar(255) 
)       
AS

DECLARE @CountryID       integer
DECLARE @SimpleText      varchar(max)

DECLARE @Words           TABLE (Word varchar(255), WordCode bigint)
DECLARE @PlaceMatches    TABLE (PlaceID integer,     PlaceMatchName varchar(255))

DECLARE @RESULTS TABLE
(
  MatchName         varchar(255),
  CountryID         integer,
  StateID           integer,
  CountyID          integer,
  DistrictID        integer,
  CommunityID       integer,
  WardID            integer,
  PlaceID           integer,
  BorderID          integer,
  MatchGeography    geography
)

SET @CountryID = dbo.StringToInteger(@countryHint)

IF @CountryID = 0 BEGIN 

  SELECT 
    @CountryID = CountryID 
  FROM 
    Geographic.Country 
  WHERE 
    CountryName = @countryHint OR 
    ISO3Code    = @countryHint OR 
    ISO2Code    = @countryHint  

END 

SET @SimpleText = ' ' + dbo.TextToSimpleString(@Text) + ' '

INSERT INTO @Words(Word)
  SELECT DISTINCT item
  FROM   dbo.ListToTable(@SimpleText, ' ')
  WHERE  item NOT IN ( 'border','coast','town','city','state','county','eastern','northen','southen','western' )

DELETE FROM @Words WHERE Word IN (Select StopWord FROM Geographic.StopWord)

UPDATE @Words SET WordCode = dbo.TextToBigInteger(Word)

INSERT INTO @PlaceMatches
  SELECT DISTINCT PlaceID, PlaceMatchName
  FROM   Geographic.PlaceName
  WHERE  PlaceWordCode IN (SELECT WordCode FROM @Words)
  AND    CountryID = @CountryID

INSERT INTO @RESULTS (MatchName, CountryID, StateID, CountyID, DistrictID, CommunityID, WardID, PlaceID, BorderID)
SELECT DISTINCT ltrim(rtrim(BoundaryMatchName)), CountryID, StateID, CountyID, DistrictID, CommunityID, WardID, null , null 
FROM   Geographic.BoundaryName
WHERE  BoundaryWordCode IN (SELECT WordCode FROM @Words)
AND    CountryID = @CountryID
UNION 
SELECT ltrim(rtrim(PlaceMatchName)), B.CountryID, B.StateID, B.CountyID, B.DistrictID, B.CommunityID, B.WardID, P.PlaceID, null 'BorderID'
FROM @PlaceMatches M
INNER JOIN Geographic.Place    P ON P.PlaceID    = M.PlaceID
INNER JOIN Geographic.Boundary B ON B.BoundaryID = P.BoundaryID  
WHERE charindex(PlaceMatchName, @SimpleText) > 0
UNION 
SELECT
    ltrim(rtrim(BorderMatchName)), @CountryID 'CountryID', null 'StateID', null 'CountyID', null 'DistrictID', null 'CommunityID', null 'WardID', null 'PlaceID', BorderID
  FROM
    Geographic.BorderName
  WHERE                                                                                     
    CountryID = @CountryID
  AND
    CHARINDEX(BorderMatchName, @SimpleText) > 0   

DELETE DEL 
FROM 
  @RESULTS DAT
INNER JOIN 
  @RESULTS DEL ON DEL.MatchName = DAT.MatchName AND DEL.PlaceID IS NOT NULL AND DAT.PlaceID IS NULL   
WHERE
  DAT.BorderID IS NULL

DELETE DEL
FROM 
  @RESULTS DAT
INNER JOIN 
  @RESULTS DEL ON DEL.StateID = DAT.StateID AND DEL.CountyID IS NOT NULL AND DAT.CountyID IS NULL   
WHERE
  DAT.BorderID IS NULL

DELETE FROM @RESULTS WHERE StateID IS NULL AND BorderID IS NULL

UPDATE R SET
  MatchGeography = Border50K
FROM
  @RESULTS  R
INNER JOIN
  Geographic.Border B ON B.BorderID = R.BorderID

UPDATE R SET
  MatchGeography = S.StateGeography
FROM
  @RESULTS  R
INNER JOIN
  Geographic.State S ON S.CountryID = R.CountryID AND S.StateID = R.StateID AND R.CountyID IS NULL

UPDATE R SET
  MatchGeography = C .CountyGeography
FROM
  @RESULTS  R
INNER JOIN
  Geographic.County C ON C.CountryID = R.CountryID AND C.StateID = R.StateID AND C.CountyID = R.CountyID

SELECT * FROM @RESULTS

RETURN @@ROWCOUNT
go

GRANT EXECUTE ON [Geographic].[MatchLocationsText] TO [rest.client]
GO

---------------------------------------------------------------------------------------------------
-- Geographic.MatchCountriesText 'the fco advise against all travel to the surobi, paghman, musayhi, khake jabbar and chahar asyab districts of kabul province and the pakistani border'  
-- Geographic.MatchCountriesText 'Antalya explosion Huge car bomb rocks British tourist hotspot in Turkey' 
-- Geographic.MatchCountriesText 'Afghanistan travel advice - GOV.UK'
---------------------------------------------------------------------------------------------------
CREATE PROCEDURE [Geographic].[MatchCountriesText]
(
  @Text             varchar(max)  
)       
AS

DECLARE @CountryID       integer
DECLARE @SimpleText      varchar(max)
DECLARE @LocationMarker  integer

SET @SimpleText = ' ' + dbo.TextToSimpleString(@Text) + ' '

SELECT 
  @LocationMarker = max(marker)
FROM(
  SELECT charindex(' at ', @SimpleText) 'marker'
  UNION
  SELECT charindex(' in ', @SimpleText) 'marker'
  UNION
  SELECT charindex(' to ', @SimpleText) 'marker'
) D
 

SELECT  
  CountrySimpleName                        'MatchName',
  CountryID,
  charindex(CountryMatchName, @SimpleText) 'StartPosition'
FROM
  CountryName
WHERE
  charindex(CountryMatchName, @SimpleText, @LocationMarker) > 0
AND
  CountryMatchName != ' and '
ORDER BY
  charindex(CountryMatchName, @SimpleText)

RETURN @@ROWCOUNT
go

GRANT EXECUTE ON [Geographic].[MatchLocationsText] TO [rest.client]
GO

---------------------------------------------------------------------------------------------------
-- Geographic.ListCountries 'ALL', 'GOOGLEARRAY'  
---------------------------------------------------------------------------------------------------
CREATE PROCEDURE [Geographic].[ListCountries]
(
  @CountryList            varchar(max)  = null,
  @CoverageFormat         varchar(20)   = 'NOCOVERAGE'
)
AS

DECLARE @COUNTRIES TABLE (CountryID integer)

IF @CountryList IS NULL OR @CountryList = 'ALL' OR datalength(@CountryList) = 0 BEGIN
  INSERT INTO @COUNTRIES
    SELECT CountryID FROM Geographic.Country
END ELSE BEGIN
  INSERT INTO @COUNTRIES
    SELECT cast(item as integer) FROM dbo.ListToTable(@CountryList, ',')
END

DELETE FROM @COUNTRIES WHERE CountryID = 9

IF UPPER(@coverageFormat) = 'NOCOVERAGE' BEGIN

  SELECT
    CountryID                                 'countryId',  
    editNo                                    'editNo',  
    CountryName                               'countyName', 
    ISO2Code                                  'iso2Code', 
    CountryCenterLatitude                     'centerLatitude', 
    CountryCenterLongitude                    'centerLongitude', 
    NULL                                      'outline'  
  FROM                                                                      
    Geographic.Country 
  WHERE
    CountryID IN ( SELECT CountryID FROM @COUNTRIES  ) 

END ELSE IF UPPER(@coverageFormat) = 'GEOJSON' BEGIN

  SELECT
    CountryID                                 'countryId',  
    editNo                                    'editNo',  
    CountryName                               'countyName', 
    ISO2Code                                  'iso2Code', 
    CountryCenterLatitude                     'centerLatitude', 
    CountryCenterLongitude                    'centerLongitude', 
    CountryGeoJSON                            'outline'  
  FROM                                                                      
    Geographic.Country 
  WHERE
    CountryID IN ( SELECT CountryID FROM @COUNTRIES  )  

END ELSE IF UPPER(@coverageFormat) = 'GOOGLEARRAY' BEGIN

  SELECT
    CountryID                                 'countryId',  
    editNo                                    'editNo',  
    CountryName                               'countyName', 
    ISO2Code                                  'iso2Code', 
    CountryCenterLatitude                     'centerLatitude', 
    CountryCenterLongitude                    'centerLongitude', 
    CountryGoogleArray                        'outline'   
  FROM                                                                      
    Geographic.Country 
  WHERE
    CountryID IN ( SELECT CountryID FROM @COUNTRIES  )   

END ELSE IF UPPER(@coverageFormat) = 'SVG' BEGIN

  SELECT
    CountryID                                 'countryId',  
    editNo                                    'editNo',  
    CountryName                               'countyName', 
    ISO2Code                                  'iso2Code', 
    CountryCenterLatitude                     'centerLatitude', 
    CountryCenterLongitude                    'centerLongitude', 
    CAST(CountryShape as varchar(max))        'outline'  
  FROM                                                                      
    Geographic.Country 
  WHERE
    CountryID IN ( SELECT CountryID FROM @COUNTRIES  )  

END ELSE BEGIN
 
  SELECT
    CountryID                                 'countryId',  
    editNo                                    'editNo',  
    CountryName                               'countyName', 
    ISO2Code                                  'iso2Code', 
    CountryCenterLatitude                     'centerLatitude', 
    CountryCenterLongitude                    'centerLongitude', 
    CountryShape                              'outline'  
  FROM                                                                      
    Geographic.Country 
  WHERE
    CountryID IN ( SELECT CountryID FROM @COUNTRIES  ) 

END



--      
RETURN @@rowcount
GO
  
GRANT EXECUTE ON [Geographic].[ListCountries] TO [rest.client]
GO


---------------------------------------------------------------------------------------------------
-- Geographic.ListStates '239:1,239:2,239:3,239:4,239:5'  
---------------------------------------------------------------------------------------------------
CREATE PROCEDURE [Geographic].[ListStates]
(
  @CountryList            varchar(max)  = null
)
AS

IF @CountryList IS NULL OR @CountryList = 'ALL' OR datalength(@CountryList) = 0 BEGIN
  SELECT
    CountryID                                 'countryID',  
    StateID                                   'stateID',  
    0                                         'editNo',  
    stateName                                 'stateName', 
    ISO2Code                                  'iso2Code', 
    StateCenterLatitude                       'centerLatitude', 
    StateCenterLongitude                      'centerLongitude', 
    StateOutline5K                            'outline' 
  FROM                                                                      
    Geographic.State
END ELSE BEGIN
  SELECT
    CountryID                                 'countryID',  
    StateID                                   'stateID',  
    0                                         'editNo',  
    stateName                                 'stateName', 
    ISO2Code                                  'iso2Code', 
    StateCenterLatitude                       'centerLatitude', 
    StateCenterLongitude                      'centerLongitude', 
    StateOutline5K                            'outline' 
  FROM                                                                      
    Geographic.State
  WHERE
    StateReference IN
    (
       SELECT item FROM dbo.ListToTable(@CountryList, ',')
    )
END
--      
RETURN @@rowcount
GO
  
GRANT EXECUTE ON [Geographic].[ListStates] TO [rest.client]
GO


---------------------------------------------------------------------------------------------------
-- Geographic.ListCounties '239:1:1,239:1:2,239:1:3,239:1:4,239:1:56'  
---------------------------------------------------------------------------------------------------
CREATE PROCEDURE [Geographic].[ListCounties]
(
  @CountryList            varchar(max)  = null
)
AS

IF @CountryList IS NULL OR @CountryList = 'ALL' OR datalength(@CountryList) = 0 BEGIN
  SELECT
    CountryID                                 'countryID',  
    StateID                                   'stateID',  
    CountyID                                  'countyID',  
    0                                         'editNo',  
    CountyName                                'countyName', 
    ISO2Code                                  'iso2Code', 
    CountyCenterLatitude                      'centerLatitude', 
    CountyCenterLongitude                     'centerLongitude', 
    CountyOutline1K                           'outline'  
  FROM                                                                      
    Geographic.County 
END ELSE BEGIN
  SELECT
    CountryID                                 'countryID',  
    StateID                                   'stateID',  
    CountyID                                  'countyID',  
    0                                         'editNo',  
    CountyName                                'countyName', 
    ISO2Code                                  'iso2Code', 
    CountyCenterLatitude                      'centerLatitude', 
    CountyCenterLongitude                     'centerLongitude', 
    CountyOutline1K                           'outline'  
  FROM                                                                      
    Geographic.County 
  WHERE
    CountyReference IN
    (
       SELECT item FROM dbo.ListToTable(@CountryList, ',')
    )
END
--      
RETURN @@rowcount
GO

  
GRANT EXECUTE ON [Geographic].[ListCounties] TO [rest.client]
GO








-----------------------------------------------------------------------------------------------------------------------------------------------------
----EXECUTE Geographic.GetCoverage 'there is a problem in a town called autreylesgray', 'FR' 
-----------------------------------------------------------------------------------------------------------------------------------------------------
--CREATE PROCEDURE [Geographic].[GetCoverage]
--(
--   @SimpleText         varchar(max),
--   @countryHint        varchar(255),
--   @ToleranceInMeters  integer       = 1000,
--   @CoverageFormat     varchar(20)   = 'GEOGRAPHY', 
--   @AbstractToCounty   bit           = 1
--)
--AS
----DECLARE @Text varchar(max) = 'The area to which the FCO advise against all but essential travel does not include Kenya’s safari destinations in the national parks, reserves and wildlife conservancies; including the Aberdare National Park, Amboseli, Laikipia, Lake Nakuru, Masai Mara, Meru, Mount Kenya, Samburu, Shimba Hills, Tsavo, nor does it include the beach resorts of Mombasa, Malindi, Kilifi, Watamu and Diani' 
----DECLARE @Text varchar(max) = 'There have been a number of attacks in Kenya in recent years, particularly in Mandera County and other areas close to the Somali border'
----DECLARE @Text varchar(max) = 'Mombasa airport (Moi International Airport) and Malindi airport are not included in the area to which the FCO advise against all but essential travel' 
----DECLARE @CountryID          int      = 118
----DECLARE @toleranceInMeters  integer  = 1000

--DECLARE @CountryID           integer

--SET @CountryID = dbo.StringToInteger(@countryHint)

--IF @CountryID = 0 BEGIN 

--  SELECT 
--    @CountryID = CountryID 
--  FROM 
--    Geographic.Country 
--  WHERE 
--    CountryName = @countryHint OR 
--    ISO3Code    = @countryHint OR 
--    ISO2Code    = @countryHint  

--END  

--IF @CountryID IS NULL OR datalength(@SimpleText) = 0  BEGIN
--   SELECT 
--      NULL     'borderReferences', 
--      NULL     'placeReferences', 
--      NULL     'boundaryReferences', 
--      NULL     'textGeography',
--      NULL     'countyReferences'
--   RETURN 0
--END

--DECLARE @WORDS          TABLE (Word varchar(255),                WordCode  bigint)

--DECLARE @BORDERS        TABLE (BorderSimpleName    varchar(255), BorderID  int   )
--DECLARE @PLACES         TABLE (PlaceSimpleName     varchar(255), PlaceID   int   )
--DECLARE @BOUNDARIES     TABLE (BoundarySimpleName  varchar(255), CountryID int, StateID int, CountyID int, DistrictID int, CommunityID int, WardID   int   )

--DECLARE @COUNTIES       TABLE (CountryID int, StateID int, CountyID int)
--DECLARE @AREAS          TABLE (AreaGeography       geography )

--DECLARE @BorderReferences    varchar(max)
--DECLARE @PlaceReferences     varchar(max)
--DECLARE @BoundaryReferences  varchar(max)
--DECLARE @CountyReferences    varchar(max)
--DECLARE @Coverage            geography

--INSERT INTO @WORDS
--  SELECT
--    item, dbo.TextToBigInteger(item)
--  FROM
--    dbo.ListToTable(@SimpleText, ' ')
--  WHERE
--    item NOT IN (SELECT StopWord FROM Geographic.StopWord)

--INSERT INTO @BORDERS
--  SELECT
--    BorderSimpleName, BorderID
--  FROM
--    Geographic.BorderName
--  WHERE
--    CountryID = @CountryID
--  AND
--    BorderWordCode IN (SELECT WordCode FROM @WORDS )
--  AND
--    CHARINDEX(BorderSimpleName, @SimpleText) > 0     

--INSERT INTO @PLACES
--  SELECT
--    PlaceSimpleName, PlaceID 
--  FROM
--    Geographic.PlaceName
--  WHERE
--    CountryID = @CountryID
--  AND
--    PlaceWordCode IN (SELECT WordCode FROM @WORDS)
--  AND
--    CHARINDEX(PlaceSimpleName, @SimpleText) > 0
--  AND
--    NOT EXISTS (SELECT 1 FROM @BORDERS WHERE charindex(PlaceSimpleName, BorderSimpleName) > 0 )
--  AND
--    PlaceSimpleName NOT IN ( 'border','coast','town','city','state','county','eastern','northen','southen','western' )

--INSERT INTO @BOUNDARIES
--  SELECT
--    BoundarySimpleName, CountryID, StateID, CountyID, DistrictID, CommunityID, WardID
--  FROM
--    Geographic.BoundaryName
--  WHERE
--    CountryID = @CountryID
--  AND
--    StateID IS NOT NULL
--  AND
--    BoundaryWordCode IN (SELECT WordCode FROM @WORDS)
--  AND
--    CHARINDEX(BoundarySimpleName, @SimpleText) > 0
--  AND
--    NOT EXISTS (SELECT 1 FROM @BORDERS WHERE charindex(BoundarySimpleName, BorderSimpleName) > 0 )
--  AND
--    NOT EXISTS (SELECT 1 FROM @PLACES  WHERE charindex(BoundarySimpleName, PlaceSimpleName ) > 0 )
--  AND
--    BoundarySimpleName NOT IN ( 'border','coast','town','city','state','county','eastern','northen','southen','western' )


-- INSERT INTO @AREAS
--  SELECT 
--    Border100K 
--  FROM 
--    Geographic.Border 
--  WHERE 
--    BorderID IN (SELECT BorderID FROM @BORDERS)

--IF @AbstractToCounty = 1 BEGIN

--  INSERT INTO @COUNTIES
--    SELECT DISTINCT
--      B.CountryID, B.StateID, B.CountyID
--    FROM
--      Geographic.Place P
--    LEFT OUTER JOIN
--      Geographic.Boundary B ON B.BoundaryID = P.BoundaryID
--    WHERE
--      P.PlaceID IN (SELECT PlaceID FROM @PLACES)
--    UNION SELECT
--      B.CountryID, B.StateID, B.CountyID
--    FROM
--      Geographic.Boundary B
--    INNER JOIN
--      @BOUNDARIES M                                     
--    ON          M.CountryID                   =   B.CountryID     
--    AND  ISNULL(M.StateID,B.StateID)          =   B.StateID       
--    AND  ISNULL(M.CountyID,B.CountyID)        =   B.CountyID      
--    AND  ISNULL(M.DistrictID,B.DistrictID)    =   B.DistrictID    
--    AND  ISNULL(M.CommunityID,B.CommunityID)  =   B.CommunityID   
--    AND  ISNULL(M.WardID,B.WardID)            =   B.WardID     

--  INSERT INTO @AREAS
--    SELECT
--      C.CountyOutline1K
--    FROM
--      Geographic.County C
--    INNER JOIN
--      @COUNTIES  M
--      ON          M.CountryID                   =   C.CountryID     
--      AND  ISNULL(M.StateID, C.StateID)         =   C.StateID       
--      AND  ISNULL(M.CountyID,C.CountyID)        =   C.CountyID  

--END ELSE BEGIN

--  INSERT INTO @AREAS
--    SELECT
--      ISNULL(PlaceGeography, BoundaryGeography)
--    FROM
--      Geographic.Place P
--    LEFT OUTER JOIN
--      Geographic.Boundary B ON B.BoundaryID = P.BoundaryID
--    WHERE
--      P.PlaceID IN (SELECT PlaceID FROM @PLACES)

--  INSERT INTO @AREAS
--    SELECT
--      BoundaryGeography
--    FROM
--      Geographic.Boundary B
--    INNER JOIN
--      @BOUNDARIES M                                     
--    ON          M.CountryID                   =   B.CountryID     
--    AND  ISNULL(M.StateID,B.StateID)          =   B.StateID       
--    AND  ISNULL(M.CountyID,B.CountyID)        =   B.CountyID      
--    AND  ISNULL(M.DistrictID,B.DistrictID)    =   B.DistrictID    
--    AND  ISNULL(M.CommunityID,B.CommunityID)  =   B.CommunityID   
--    AND  ISNULL(M.WardID,B.WardID)            =   B.WardID     

--END

--SELECT 
--  @Coverage= Geography::UnionAggregate(AreaGeography) 
--FROM 
--  @AREAS

--IF @Coverage IS NOT NULL BEGIN

--  SET @Coverage = @Coverage.Reduce(@toleranceInMeters) 
--  SET @Coverage = dbo.RemoveArtefacts(@Coverage) 

--END

--SELECT @BorderReferences   =  COALESCE(@BorderReferences   + ', ', '') + BorderSimpleName   + ':' + CAST(BorderID AS varchar(20)) FROM @BORDERS
--SELECT @PlaceReferences    =  COALESCE(@PlaceReferences    + ', ', '') + PlaceSimpleName    + ':' + CAST(PlaceID  AS varchar(20)) FROM @PLACES
--SELECT @BoundaryReferences =  COALESCE(@BoundaryReferences + ', ', '') + BoundarySimpleName + ':' + ISNULL(CAST(CountryID AS varchar(20)),'NULL') + ':' + ISNULL(CAST(StateID AS varchar(20)),'NULL') + ':' + ISNULL(CAST(CountyID AS varchar(20)),'NULL') + ':' + ISNULL(CAST(DistrictID AS varchar(20)),'NULL') + ':' + ISNULL(CAST(CommunityID AS varchar(20)),'NULL') + ':' + ISNULL(CAST(WardID AS varchar(20)),'NULL')   FROM @BOUNDARIES

--SELECT @CountyReferences   =  COALESCE(@CountyReferences   + ', ', '') + CAST(CountryID as varchar(10)) + '.' + CAST(StateID as varchar(10)) + '.' + CAST(CountyID as varchar(10))  FROM @Counties

--IF UPPER(@coverageFormat) = 'NOCOVERAGE' BEGIN

--  SELECT 
--    @BorderReferences            'borderReferences', 
--    @PlaceReferences             'placeReferences', 
--    @BoundaryReferences          'boundaryReferences',
--    NULL                         'textGeography',
--    @CountyReferences            'countyReferences' 

--END ELSE IF UPPER(@coverageFormat) = 'GEOJSON' BEGIN

--  SELECT 
--    @BorderReferences            'borderReferences', 
--    @PlaceReferences             'placeReferences', 
--    @BoundaryReferences          'boundaryReferences', 
--    dbo.CastAsGeoJSON(@Coverage) 'textGeography',
--    @CountyReferences            'countyReferences'

--END ELSE IF UPPER(@coverageFormat) = 'GOOGLEARRAY' BEGIN

--  SELECT 
--    @BorderReferences                  'borderReferences', 
--    @PlaceReferences                   'placeReferences', 
--    @BoundaryReferences                'boundaryReferences', 
--    dbo.CastAsGoogleArray(@Coverage)   'textGeography',
--    @CountyReferences                  'countyReferences'

--END ELSE IF UPPER(@coverageFormat) = 'SVG' BEGIN

--  SELECT 
--    @BorderReferences                  'borderReferences', 
--    @PlaceReferences                   'placeReferences', 
--    @BoundaryReferences                'boundaryReferences', 
--    CAST(@Coverage as varchar(max))    'textGeography',
--    @CountyReferences                  'countyReferences'

--END ELSE BEGIN
                 
--  SELECT 
--    @BorderReferences    'borderReferences', 
--    @PlaceReferences     'placeReferences', 
--    @BoundaryReferences  'boundaryReferences', 
--    @Coverage            'textGeography' ,
--    @CountyReferences    'countyReferences'

--END

--RETURN @@rowcount
--GO
  
--GRANT EXECUTE ON [Geographic].[GetCoverage] TO [rest.client]
--GO
