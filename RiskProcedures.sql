---------------------------------------------------------------------------------------------------
--Drops
---------------------------------------------------------------------------------------------------
IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'ListDocuments'                    AND type = 'P') DROP PROCEDURE Risk.ListDocuments
IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'ListDocumentsForUncurated'        AND type = 'P') DROP PROCEDURE Risk.ListDocumentsForUncurated
IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'ListFacts'                        AND type = 'P') DROP PROCEDURE Risk.ListFacts
IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'ListFactsForDocument'             AND type = 'P') DROP PROCEDURE Risk.ListFactsForDocument
                                                                                    
IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'PostDocument'                     AND type = 'P') DROP PROCEDURE Risk.PostDocument
                                                                                    
IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'PutDocumentReset'                 AND type = 'P') DROP PROCEDURE Risk.PutDocumentReset
IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'PutFactCategory'                  AND type = 'P') DROP PROCEDURE Risk.PutFactCategory
IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'PutFactMerge'                     AND type = 'P') DROP PROCEDURE Risk.PutFactMerge
IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'PutFactText'                      AND type = 'P') DROP PROCEDURE Risk.PutFactText
IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'PutFactDiscard'                   AND type = 'P') DROP PROCEDURE Risk.PutFactDiscard

IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'ProcesDocument'                   AND type = 'P') DROP PROCEDURE Risk.ProcesDocument
IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'ProcesFact'                       AND type = 'P') DROP PROCEDURE Risk.ProcesFact
IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'ProcesDocumentsWithMissingFacts'  AND type = 'P') DROP PROCEDURE Risk.ProcesDocumentsWithMissingFacts
IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'ProcesFactsForDocument'           AND type = 'P') DROP PROCEDURE Risk.ProcesFactsForDocument
IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'ProcesDocumentReset'              AND type = 'P') DROP PROCEDURE Risk.ProcesDocumentReset


---------------------------------------------------------------------------------------------------
--Drops
---------------------------------------------------------------------------------------------------
IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'GetFacts'                     AND type = 'P') DROP PROCEDURE Risk.GetFacts
IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'ProcesDocuments'         AND type = 'P') DROP PROCEDURE Risk.ProcesDocuments
IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'PostDocumentFactStatus'  AND type = 'P') DROP PROCEDURE Risk.PostDocumentFactStatus
IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'GetUncuratedDocuments'   AND type = 'P') DROP PROCEDURE Risk.GetUncuratedDocuments
IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'ProcesDocumentFact'      AND type = 'P') DROP PROCEDURE Risk.ProcesDocumentFact
IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'ProcesDocumentFacts'     AND type = 'P') DROP PROCEDURE Risk.ProcesDocumentFacts
IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'PostLocation'            AND type = 'P') DROP PROCEDURE Risk.PostLocation
IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'PostSignal'              AND type = 'P') DROP PROCEDURE Risk.PostSignal
go
          



 ---------------------------------------------------------------------------------------------------
-- Risk.ListDocuments '287,288,289'  
---------------------------------------------------------------------------------------------------
CREATE PROCEDURE [Risk].[ListDocuments]
(
  @DocumentList varchar(max) 
)
AS

SELECT
  D.DocumentID                              'documentId', 
  D.DocumentSource                          'documentSource', 
  D.DocumentTitle                           'documentTitle' 
FROM
  Risk.Document  D
WHERE
  DocumentID IN
  (
      SELECT DISTINCT dbo.StringToInteger(item) FROM dbo.ListToTable(@DocumentList, ',')
  )
--      
RETURN @@rowcount
GO

GRANT EXECUTE ON [Risk].[ListDocuments] TO [risk.service]
GO
        
---------------------------------------------------------------------------------------------------------------------------------------------------
-- EXECUTE Risk.ListDocumentsForUncurated  
---------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [Risk].[ListDocumentsForUncurated] 
(
  @MaxDocumentCount   integer       = 10
)
AS 

DECLARE @List varchar(max)

SELECT TOP (@MaxDocumentCount)
  @List = COALESCE(@List + ', ', '') + CAST(DocumentID as varchar(10))              
FROM
  Risk.Document  D
WHERE
  IsLatestDocument = 1 
AND
  CuratedAtUTC IS NULL

EXECUTE Risk.ListDocuments @List

RETURN @@ROWCOUNT

GO

GRANT EXECUTE ON [Risk].[ListDocumentsForUncurated] TO [risk.service]
GO

---------------------------------------------------------------------------------------------------------------------------------------------------
-- EXECUTE Risk.ListFacts '31013,31014,31016', 'GOOGLEARRAY'
---------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [Risk].[ListFacts] 
(
  @FactList           varchar(max),
  @CoverageFormat     varchar(20)   = 'NOCOVERAGE'
)
AS 

IF UPPER(@coverageFormat) = 'NOCOVERAGE' BEGIN

  SELECT
    FactID                              'factId',
    DocumentID                          'documentId',
    FactCategory                        'factCategory',
    FactText                            'factText',
    DisplayText                         'displayText',
    F.CountryID                         'countryID',
    CountryName                         'countryName',
    borderReferences                    'borderReferences',
    placeReferences                     'placeReferences',
    boundaryReferences                  'boundaryReferences',
    countyReferences                    'countyReferences',
    null                                'factGeography',
    AnalysisCategories                  'analysisCategories',
    IsEdited                            'isEdited', 
    IsMerged                            'isMerged',
    IsDiscarded                         'isDiscarded'
  FROM
    Risk.Fact  F
  LEFT OUTER JOIN
    Geographic.Country C ON C.CountryID = F.CountryID
  WHERE
    F.FactID IN
    (
      SELECT DISTINCT dbo.StringToInteger(item) FROM dbo.ListToTable(@FactList, ',')
    )
  ORDER BY
    FactID

END ELSE IF UPPER(@coverageFormat) = 'GEOJSON' BEGIN

  SELECT
    FactID                              'factId',
    DocumentID                          'documentId',
    FactCategory                        'factCategory',
    FactText                            'factText',
    DisplayText                         'displayText',
    F.CountryID                         'countryID',
    CountryName                         'countryName',
    borderReferences                    'borderReferences',
    placeReferences                     'placeReferences',
    boundaryReferences                  'boundaryReferences',
    countyReferences                    'countyReferences',
    dbo.CastAsGeoJSON(FactGeography)    'factGeography',
    AnalysisCategories                  'analysisCategories',
    IsEdited                            'isEdited', 
    IsMerged                            'isMerged',
    IsDiscarded                         'isDiscarded'  
  FROM
    Risk.Fact  F
  LEFT OUTER JOIN
    Geographic.Country C ON C.CountryID = F.CountryID
  WHERE
    F.FactID IN
    (
      SELECT DISTINCT dbo.StringToInteger(item) FROM dbo.ListToTable(@FactList, ',')
    )
  ORDER BY
    FactID

END ELSE IF UPPER(@coverageFormat) = 'GOOGLEARRAY' BEGIN

  SELECT
    FactID                              'factId',
    DocumentID                          'documentId',
    FactCategory                        'factCategory',
    FactText                            'factText',
    DisplayText                         'displayText',
    F.CountryID                         'countryID',
    CountryName                         'countryName',
    borderReferences                    'borderReferences',
    placeReferences                     'placeReferences',
    boundaryReferences                  'boundaryReferences',
    countyReferences                    'countyReferences',
    dbo.CastAsGoogleArray(FactGeography)'factGeography',
    AnalysisCategories                  'analysisCategories',
    IsEdited                            'isEdited', 
    IsMerged                            'isMerged',
    IsDiscarded                         'isDiscarded'  
  FROM
    Risk.Fact  F
  LEFT OUTER JOIN
    Geographic.Country C ON C.CountryID = F.CountryID
  WHERE
    F.FactID IN
    (
      SELECT DISTINCT dbo.StringToInteger(item) FROM dbo.ListToTable(@FactList, ',')
    )
  ORDER BY
    FactID

END ELSE IF UPPER(@coverageFormat) = 'SVG' BEGIN

  SELECT
    FactID                              'factId',
    DocumentID                          'documentId',
    FactCategory                        'factCategory',
    FactText                            'factText',
    DisplayText                         'displayText',
    F.CountryID                         'countryID',
    CountryName                         'countryName',
    borderReferences                    'borderReferences',
    placeReferences                     'placeReferences',
    boundaryReferences                  'boundaryReferences',
    countyReferences                    'countyReferences',
    CAST(FactGeography as varchar(max)) 'factGeography',
    AnalysisCategories                  'analysisCategories',
    IsEdited                            'isEdited', 
    IsMerged                            'isMerged',
    IsDiscarded                         'isDiscarded'  
  FROM
    Risk.Fact  F
  LEFT OUTER JOIN
    Geographic.Country C ON C.CountryID = F.CountryID
  WHERE
    F.FactID IN
    (
      SELECT DISTINCT dbo.StringToInteger(item) FROM dbo.ListToTable(@FactList, ',')
    )
  ORDER BY
    FactID

END ELSE BEGIN
 
  SELECT
    FactID                              'factId',
    DocumentID                          'documentId',
    FactCategory                        'factCategory',
    FactText                            'factText',
    DisplayText                         'displayText',
    F.CountryID                         'countryID',
    CountryName                         'countryName',
    borderReferences                    'borderReferences',
    placeReferences                     'placeReferences',
    boundaryReferences                  'boundaryReferences',
    countyReferences                    'countyReferences',
    FactGeography                       'factGeography',
    AnalysisCategories                  'analysisCategories',
    IsEdited                            'isEdited', 
    IsMerged                            'isMerged',
    IsDiscarded                         'isDiscarded' 
  FROM
    Risk.Fact  F
  LEFT OUTER JOIN
    Geographic.Country C ON C.CountryID = F.CountryID
  WHERE
    F.FactID IN
    (
      SELECT DISTINCT dbo.StringToInteger(item) FROM dbo.ListToTable(@FactList, ',')
    )
  ORDER BY
    FactID
END

RETURN @@ROWCOUNT
GO

GRANT EXECUTE ON [Risk].[ListFacts] TO [risk.service]
GO

---------------------------------------------------------------------------------------------------------------------------------------------------
-- EXECUTE Risk.ProcesFact 287 
---------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [Risk].[ProcesFact] 
(
  @FactID           integer 
)
AS 

DECLARE @CountryID  integer
DECLARE @Text       varchar(max)
DECLARE @Coverage   geography

DECLARE @LOCATION_RESULTS TABLE
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

SELECT
  @CountryID  = CountryID 
FROM
  Risk.Document
WHERE
  DocumentID = (SELECT DocumentID FROM Risk.Fact WHERE FactID = @FactID)

SELECT
  @Text = ISNULL(DisplayText, FactText)
FROM
  Risk.Fact
WHERE
  FactID = @FactID

INSERT INTO @LOCATION_RESULTS
  EXECUTE Geographic.MatchLocationsText @Text, @CountryID

INSERT INTO Risk.Location
  SELECT
    @FactID,
    CountryID,   
    StateID,     
    CountyID,    
    DistrictID,  
    CommunityID, 
    WardID,      
    PlaceID,     
    BorderID
  FROM
    @LOCATION_RESULTS    

SELECT 
  @Coverage= Geography::UnionAggregate(MatchGeography) 
FROM 
  @LOCATION_RESULTS

IF @Coverage IS NOT NULL BEGIN

  SET @Coverage = @Coverage.Reduce(1000) 
  SET @Coverage = dbo.RemoveArtefacts(@Coverage) 

END

UPDATE Risk.Fact SET
  FactGeography = @Coverage
WHERE
  FactID = @FactID

RETURN
go

GRANT EXECUTE ON [Risk].[ProcesFact] TO [risk.service]
GO

---------------------------------------------------------------------------------------------------------------------------------------------------
-- EXECUTE Risk.ProcesFactsForDocument  -- DELETE FROM Risk.Fact  
---------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE Risk.ProcesFactsForDocument
(
  @DocumentID           integer 
) 
AS 

DECLARE @ID as int 
 
DECLARE @CURSOR as CURSOR;
 
SET @CURSOR = CURSOR FOR
 SELECT
   FactID
 FROM 
   Risk.Fact
 WHERE
   DocumentID = @DocumentID
 
OPEN @CURSOR;

FETCH NEXT FROM @CURSOR INTO @ID
 
WHILE @@FETCH_STATUS = 0 BEGIN
 
 EXECUTE Risk.ProcesFact @ID

 FETCH NEXT FROM @CURSOR INTO @ID
END
 
CLOSE      @CURSOR;
DEALLOCATE @CURSOR;

RETURN
go

GRANT EXECUTE ON [Risk].[ProcesFactsForDocument] TO [risk.service]
GO

---------------------------------------------------------------------------------------------------------------------------------------------------
-- EXECUTE Risk.ListFactsForDocument 287, 'GOOGLEARRAY'
---------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [Risk].[ListFactsForDocument] 
(
  @DocumentID         integer,
  @CoverageFormat     varchar(20)   = 'NOCOVERAGE'
)
AS 

DECLARE @List varchar(max)

SELECT  
  @List = COALESCE(@List + ', ', '') + CAST(FactID as varchar(10))              
FROM
  Risk.Fact   
WHERE
  DocumentID = @DocumentID
ORDER BY
  FactID

EXECUTE Risk.ListFacts @List

RETURN @@ROWCOUNT
GO

GRANT EXECUTE ON [Risk].[ListFactsForDocument] TO [risk.service]
GO

---------------------------------------------------------------------------------------------------------------------------------------------------
-- EXECUTE Risk.ProcesDocumentReset 287   
---------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE Risk.ProcesDocumentReset
(
  @DocumentID           integer 
) 
AS 

UPDATE Risk.Document SET
  CuratedAtUTC = NULL
WHERE
  DocumentID = @DocumentID 
 
UPDATE Risk.Fact SET
  FactCategory = NULL,
  DisplayText  = NULL,
  IsEdited     = NULL,
  IsMerged     = NULL,
  isDiscarded  = NULL
WHERE
  DocumentID = @DocumentID  

DELETE FROM Risk.Location
WHERE
  FactID IN (SELECT FactID FROM Risk.Fact WHERE DocumentID = @DocumentID)

EXECUTE Risk.ListFactsForDocument @DocumentID

RETURN
go

GRANT EXECUTE ON [Risk].[ProcesDocumentReset] TO [risk.service]
GO

---------------------------------------------------------------------------------------------------------------------------------------------------
-- EXECUTE Risk.ProcesDocument 287 
---------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [Risk].[ProcesDocument] 
(
  @DocumentID           integer 
)
AS 

DECLARE @CountryID     integer
DECLARE @DocumentText  varchar(max)
DECLARE @DocumentTitle varchar(max)

DECLARE @COUNTRY_RESULTS TABLE
(
  MatchName         varchar(255),
  CountryID         integer,
  StartPosition     integer
)

SELECT
  @DocumentTitle = DocumentTitle,
  @DocumentText  = DocumentText
FROM
  Risk.Document D
WHERE
  D.DocumentID = @DocumentID

SET @DocumentText = replace(@DocumentText, char(11),  ' ')
SET @DocumentText = replace(@DocumentText, char(160), ' ')
SET @DocumentText = replace(@DocumentText, '   ',     ' ')          
SET @DocumentText = replace(@DocumentText, '  ',      ' ')

INSERT INTO @COUNTRY_RESULTS
  EXEC Geographic.MatchCountriesText @DocumentTitle

SELECT
  @CountryID = CountryID
FROM
  @COUNTRY_RESULTS

UPDATE Risk.Document SET
  CountryID = @CountryID
WHERE
  DocumentID = @DocumentID

SELECT
  @DocumentText = REPLACE(@DocumentText, LookFor, ReplaceWith)
FROM
  Risk.ReplacePhrase
WHERE
  charindex(LookFor, @DocumentText) > 0

SELECT
  @DocumentText = REPLACE(@DocumentText, LookFor, ReplaceWith)
FROM
  Risk.ReplacePhraseExact
WHERE
  charindex(LookFor, @DocumentText COLLATE Latin1_General_CS_AS) > 0

SET @DocumentText = REPLACE(@DocumentText, 'in the area to which. The FCO advise against', 'in the area to which, the FCO advise against')
SET @DocumentText = REPLACE(@DocumentText, ' throughout. The ',                            ' throughout the '                            )

DELETE FROM 
  Risk.Fact
WHERE
  DocumentID = @DocumentID

INSERT INTO Risk.Fact(DocumentID, FactText, FactHash, CountryID)
  SELECT 
    @DocumentID, 
    dbo.TextToCleanString(item),
    HASHBYTES('SHA1', lower(item)), 
    @CountryID 
  FROM
   dbo.TextToLines(@DocumentText)

EXEC Risk.ProcesFactsForDocument @DocumentID
 
RETURN
GO

--GRANT EXECUTE ON [Risk].[ProcesDocument] TO [risk.service]
--GO

---------------------------------------------------------------------------------------------------------------------------------------------------
-- EXECUTE Risk.ProcesDocumentsWithMissingFacts  -- DELETE FROM Risk.Fact  
---------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE Risk.ProcesDocumentsWithMissingFacts 
AS 

DECLARE @ID as int 
 
DECLARE @CURSOR as CURSOR;
 
SET @CURSOR = CURSOR FOR
 SELECT
   DocumentID
 FROM 
   Risk.Document
 WHERE
   DocumentID NOT IN (SELECT DocumentID FROM Risk.Fact)
 
OPEN @CURSOR;

FETCH NEXT FROM @CURSOR INTO @ID
 
WHILE @@FETCH_STATUS = 0 BEGIN
 
 EXECUTE Risk.ProcesDocument @ID

 FETCH NEXT FROM @CURSOR INTO @ID
END
 
CLOSE      @CURSOR;
DEALLOCATE @CURSOR;

RETURN
go

GRANT EXECUTE ON [Risk].[ProcesDocumentsWithMissingFacts] TO [risk.service]
GO


---------------------------------------------------------------------------------------------------------------------------------------------------
--EXECUTE Risk.PostDocument 'https://keldan.co.uk/test-in-france.html', 'latest news', 'there is a problem in a town called autrey-les-gray.'   
--EXECUTE Risk.ProcesstDocuments 
---------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [Risk].[PostDocument]
  @Source      varchar(500), 
  @Title       varchar(500),
  @Text        varchar(max),
  @ProcessNow  bit = 0
AS

DECLARE @DocumentHash       varbinary(max) 
DECLARE @CurrentID          integer
DECLARE @CurrentHash        varbinary(max) 

SET @Source       = LOWER(@Source)
SET @DocumentHash = HASHBYTES('SHA1', lower(@Text)); 

SELECT 
  @CurrentID       = DocumentID,
  @CurrentHash     = DocumentHash
FROM
  Risk.Document
WHERE
  DocumentSource    = @Source 
AND
  IsLatestDocument  = 1
 
IF @CurrentID IS NOT NULL AND @CurrentHash = @DocumentHash BEGIN

  UPDATE Risk.Document SET
    RetrievedAtUTC = getutcdate()
  WHERE
    DocumentID = @CurrentID 

END ELSE BEGIN

  UPDATE Risk.Document SET
    IsLatestDocument = 0
  WHERE
    DocumentID = @CurrentID 

  INSERT INTO Risk.Document
  ( 
    DocumentSource,
    DocumentTitle,
    DocumentHash, 
    DocumentText,
    IsLatestDocument,
    RetrievedAtUTC
  )
  VALUES
  (
    @Source,
    @Title,
    @DocumentHash,
    @Text,
    1,
    getutcdate()
  )

  IF (@ProcessNow = 1 ) BEGIN
    
    EXECUTE Risk.ProcesDocument @@IDENTITY 

  END

END

RETURN @@ROWCOUNT
GO


GRANT EXECUTE ON [Risk].[PostDocument] TO [risk.service]
GO

---------------------------------------------------------------------------------------------------------------------------------------------------
-- EXECUTE Risk.PutFactDiscard 4863                        
---------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [Risk].[PutFactDiscard] 
(
  @FactID             integer,
  @IsDiscarded        bit    
)
AS 

DECLARE @FactHash            varbinary(max)

SELECT 
  @FactHash = FactHash
FROM
  Risk.Fact
WHERE
  FactID = @FactID

UPDATE Risk.Fact SET
  isDiscarded    = @IsDiscarded -- flip a bit = ISNULL(isDiscarded ^ 1, 1)
WHERE
  FactHash       = @FactHash

EXECUTE Risk.ListFacts @FactID 

RETURN @@ROWCOUNT
GO

GRANT EXECUTE ON [Risk].[PutFactDiscard] TO [risk.service]
GO

---------------------------------------------------------------------------------------------------------------------------------------------------
-- EXECUTE Risk.PutDocumentReset 287                        
---------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [Risk].[PutDocumentReset] 
(
  @DocumentID             integer 
)
AS 

EXECUTE Risk.ProcesDocumentReset @DocumentID 

RETURN @@ROWCOUNT
GO

GRANT EXECUTE ON [Risk].[PutDocumentReset] TO [risk.service]
GO

---------------------------------------------------------------------------------------------------------------------------------------------------
-- EXECUTE Risk.PutFactCategory 4863, 'PROFILE'
---------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [Risk].[PutFactCategory] 
(
  @FactID             integer,
  @Category           varchar(255)    
)
AS 

DECLARE @FactHash            varbinary(max)

SELECT 
  @FactHash = FactHash
FROM
  Risk.Fact
WHERE
  FactID = @FactID

IF @Category = 'DISCARD' BEGIN

  UPDATE Risk.Fact SET
    FactCategory   = @Category 
  WHERE
    FactHash       = @FactHash

END ELSE BEGIN

  UPDATE Risk.Fact SET
    FactCategory   = @Category     
  WHERE
    FactID         = @FactID

END

EXECUTE Risk.ListFacts @FactID 

RETURN @@ROWCOUNT
GO

GRANT EXECUTE ON [Risk].[PutFactCategory] TO [risk.service]
GO

---------------------------------------------------------------------------------------------------------------------------------------------------
-- EXECUTE Risk.PutFactMerge 40928 
---------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [Risk].[PutFactMerge] 
(
  @FactID             integer    
)
AS 

DECLARE 
  @DocumentID       integer,
  @PriorFactID      integer,
  @PriorFactText    varchar(max),
  @FactText         varchar(max),
  @FactList         varchar(max)

SELECT
  @DocumentID    = DocumentID,
  @FactText      = ISNULL(DisplayText, FactText)
FROM
  Risk.Fact
WHERE
  FactID = @FactID  

SELECT
  @PriorFactID   = FactID,
  @PriorFactText = ISNULL(DisplayText, FactText)
FROM
  Risk.Fact
WHERE
  FactID  = ( SELECT MAX(FactID) FROM Risk.Fact WHERE DocumentID = @DocumentID AND FactID < @FactID AND IsMerged IS NULL)

IF @PriorFactID IS NOT NULL BEGIN

  UPDATE Risk.Fact SET
    DisplayText    = '',
    FactGeography  = NULL,
    IsMerged       = 1     
  WHERE
    FactID         = @FactID

  DELETE FROM Risk.Location
  WHERE
    FactID         = @FactID

  UPDATE Risk.Fact SET
    DisplayText    = @PriorFactText + '; ' + @FactText 
  WHERE
    FactID         = @PriorFactID

  SET @FactList = cast(@FactID as varchar(10)) + ',' + cast(@PriorFactID as varchar(10))
  
  EXECUTE Risk.ProcesFact @PriorFactID

  EXECUTE Risk.ListFacts @FactList 

END

RETURN @@ROWCOUNT
GO

GRANT EXECUTE ON [Risk].[PutFactMerge] TO [risk.service]
GO

---------------------------------------------------------------------------------------------------------------------------------------------------
-- EXECUTE Risk.PutFactText 31013, 'Some Text goes here'
---------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [Risk].[PutFactText] 
(
  @FactID             integer,
  @Text               varchar(max)    
)
AS 

UPDATE Risk.Fact SET
  DisplayText       = @Text,
  isEdited          = 1     
WHERE
  FactID            = @FactID

EXECUTE Risk.ListFacts @FactID 

RETURN @@ROWCOUNT
GO

GRANT EXECUTE ON [Risk].[PutFactText] TO [risk.service]
GO

---------------------------------------------------------------------------------------------------------------------------------------------------
-- Data for processing
---------------------------------------------------------------------------------------------------------------------------------------------------

--DECLARE @Text  varchar(max) = 'this and That'   
--DECLARE @Match varchar(max) = 't'              

--SELECT charindex(@Match, @Text COLLATE Latin1_General_CS_AS) 


DECLARE @ADDITIONAL_FULL_STOP_FIRST_PART TABLE (A varchar(255))
INSERT INTO @ADDITIONAL_FULL_STOP_FIRST_PART VALUES ( 'a' )
INSERT INTO @ADDITIONAL_FULL_STOP_FIRST_PART VALUES ( 'b' )
INSERT INTO @ADDITIONAL_FULL_STOP_FIRST_PART VALUES ( 'c' )
INSERT INTO @ADDITIONAL_FULL_STOP_FIRST_PART VALUES ( 'd' )
INSERT INTO @ADDITIONAL_FULL_STOP_FIRST_PART VALUES ( 'e' )
INSERT INTO @ADDITIONAL_FULL_STOP_FIRST_PART VALUES ( 'f' )
INSERT INTO @ADDITIONAL_FULL_STOP_FIRST_PART VALUES ( 'g' )
INSERT INTO @ADDITIONAL_FULL_STOP_FIRST_PART VALUES ( 'h' )
INSERT INTO @ADDITIONAL_FULL_STOP_FIRST_PART VALUES ( 'i' )
INSERT INTO @ADDITIONAL_FULL_STOP_FIRST_PART VALUES ( 'j' )
INSERT INTO @ADDITIONAL_FULL_STOP_FIRST_PART VALUES ( 'k' )
INSERT INTO @ADDITIONAL_FULL_STOP_FIRST_PART VALUES ( 'l' )
INSERT INTO @ADDITIONAL_FULL_STOP_FIRST_PART VALUES ( 'm' )
INSERT INTO @ADDITIONAL_FULL_STOP_FIRST_PART VALUES ( 'n' )
INSERT INTO @ADDITIONAL_FULL_STOP_FIRST_PART VALUES ( 'o' )
INSERT INTO @ADDITIONAL_FULL_STOP_FIRST_PART VALUES ( 'p' )
INSERT INTO @ADDITIONAL_FULL_STOP_FIRST_PART VALUES ( 'q' )
INSERT INTO @ADDITIONAL_FULL_STOP_FIRST_PART VALUES ( 'r' )
INSERT INTO @ADDITIONAL_FULL_STOP_FIRST_PART VALUES ( 's' )
INSERT INTO @ADDITIONAL_FULL_STOP_FIRST_PART VALUES ( 't' )
INSERT INTO @ADDITIONAL_FULL_STOP_FIRST_PART VALUES ( 'u' )
INSERT INTO @ADDITIONAL_FULL_STOP_FIRST_PART VALUES ( 'v' )
INSERT INTO @ADDITIONAL_FULL_STOP_FIRST_PART VALUES ( 'w' )
INSERT INTO @ADDITIONAL_FULL_STOP_FIRST_PART VALUES ( 'x' )
INSERT INTO @ADDITIONAL_FULL_STOP_FIRST_PART VALUES ( 'y' )
INSERT INTO @ADDITIONAL_FULL_STOP_FIRST_PART VALUES ( 'z' )
INSERT INTO @ADDITIONAL_FULL_STOP_FIRST_PART VALUES ( ')' )
INSERT INTO @ADDITIONAL_FULL_STOP_FIRST_PART VALUES ( ':' )
INSERT INTO @ADDITIONAL_FULL_STOP_FIRST_PART VALUES ( ';' )
INSERT INTO @ADDITIONAL_FULL_STOP_FIRST_PART VALUES ( ',' )

DECLARE @ADDITIONAL_FULL_STOP_SECOND_PART TABLE (B varchar(255))
INSERT INTO @ADDITIONAL_FULL_STOP_SECOND_PART VALUES ( 'The ' )
INSERT INTO @ADDITIONAL_FULL_STOP_SECOND_PART VALUES ( 'You' )
INSERT INTO @ADDITIONAL_FULL_STOP_SECOND_PART VALUES ( 'There' )
INSERT INTO @ADDITIONAL_FULL_STOP_SECOND_PART VALUES ( 'the FCO advise against ' )
INSERT INTO @ADDITIONAL_FULL_STOP_SECOND_PART VALUES ( 'In a' )
INSERT INTO @ADDITIONAL_FULL_STOP_SECOND_PART VALUES ( 'In b' )
INSERT INTO @ADDITIONAL_FULL_STOP_SECOND_PART VALUES ( 'In c' )
INSERT INTO @ADDITIONAL_FULL_STOP_SECOND_PART VALUES ( 'In d' )
INSERT INTO @ADDITIONAL_FULL_STOP_SECOND_PART VALUES ( 'In e' )
INSERT INTO @ADDITIONAL_FULL_STOP_SECOND_PART VALUES ( 'In f' )
INSERT INTO @ADDITIONAL_FULL_STOP_SECOND_PART VALUES ( 'In g' )
INSERT INTO @ADDITIONAL_FULL_STOP_SECOND_PART VALUES ( 'In h' )
INSERT INTO @ADDITIONAL_FULL_STOP_SECOND_PART VALUES ( 'In i' )
INSERT INTO @ADDITIONAL_FULL_STOP_SECOND_PART VALUES ( 'In j' )
INSERT INTO @ADDITIONAL_FULL_STOP_SECOND_PART VALUES ( 'In k' )
INSERT INTO @ADDITIONAL_FULL_STOP_SECOND_PART VALUES ( 'In l' )
INSERT INTO @ADDITIONAL_FULL_STOP_SECOND_PART VALUES ( 'In m' )
INSERT INTO @ADDITIONAL_FULL_STOP_SECOND_PART VALUES ( 'In n' )
INSERT INTO @ADDITIONAL_FULL_STOP_SECOND_PART VALUES ( 'In o' )
INSERT INTO @ADDITIONAL_FULL_STOP_SECOND_PART VALUES ( 'In p' )
INSERT INTO @ADDITIONAL_FULL_STOP_SECOND_PART VALUES ( 'In q' )
INSERT INTO @ADDITIONAL_FULL_STOP_SECOND_PART VALUES ( 'In r' )
INSERT INTO @ADDITIONAL_FULL_STOP_SECOND_PART VALUES ( 'In s' )
INSERT INTO @ADDITIONAL_FULL_STOP_SECOND_PART VALUES ( 'In t' )
INSERT INTO @ADDITIONAL_FULL_STOP_SECOND_PART VALUES ( 'In u' )
INSERT INTO @ADDITIONAL_FULL_STOP_SECOND_PART VALUES ( 'In v' )
INSERT INTO @ADDITIONAL_FULL_STOP_SECOND_PART VALUES ( 'In w' )
INSERT INTO @ADDITIONAL_FULL_STOP_SECOND_PART VALUES ( 'In x' )
INSERT INTO @ADDITIONAL_FULL_STOP_SECOND_PART VALUES ( 'In y' )
INSERT INTO @ADDITIONAL_FULL_STOP_SECOND_PART VALUES ( 'In z' )

DELETE FROM Risk.ReplacePhraseExact

INSERT INTO Risk.ReplacePhraseExact
  SELECT
    A + ' ' + B, A + '. ' + upper(substring(B,1,1)) + substring(B,2,255)
  FROM
    @ADDITIONAL_FULL_STOP_FIRST_PART
  CROSS JOIN
   @ADDITIONAL_FULL_STOP_SECOND_PART

 UPDATE Risk.ReplacePhraseExact SET
   ReplaceWith = REPLACE(ReplaceWith, ':.', '.')

UPDATE Risk.ReplacePhraseExact SET
   ReplaceWith = REPLACE(ReplaceWith, ';.', '.')

UPDATE Risk.ReplacePhraseExact SET
   ReplaceWith = REPLACE(ReplaceWith, ',.', '.')

DELETE FROM Risk.ReplacePhrase

INSERT INTO Risk.ReplacePhrase VALUES( 'gov.uk',                              ' '                           )
INSERT INTO Risk.ReplacePhrase VALUES( '0, except where otherwise stated', '. Except where otherwise stated')

INSERT INTO Risk.ReplacePhrase VALUES( '. see terrorism ',                 '. See terrorism. '             )
INSERT INTO Risk.ReplacePhrase VALUES( '. see landmines ',                 '. See landmines. '             )
INSERT INTO Risk.ReplacePhrase VALUES( '. see natural disasters ',         '. See natural disasters. '     )
INSERT INTO Risk.ReplacePhrase VALUES( '. see winter sports ',             '. See winter sports. '         )
INSERT INTO Risk.ReplacePhrase VALUES( '. see consular assistance ',       '. See consular assistance. '   )
INSERT INTO Risk.ReplacePhrase VALUES( '. see political situation ',       '. See political situation. '   )
INSERT INTO Risk.ReplacePhrase VALUES( '. see crime and local travel ',    '. See crime and local travel. ')
INSERT INTO Risk.ReplacePhrase VALUES( '. see crime ',                     '. See crime. '                 )
INSERT INTO Risk.ReplacePhrase VALUES( '. see Road Travel ',               '. See Road Travel. '           )
INSERT INTO Risk.ReplacePhrase VALUES( '. see Sea Travel ',                '. See Sea Travel. '            )
INSERT INTO Risk.ReplacePhrase VALUES( '. see Air Travel ',                '. See Air Travel. '            )
INSERT INTO Risk.ReplacePhrase VALUES( '. see Local laws and customs ',    '. See Local laws and customs. ')
 
INSERT INTO Risk.ReplacePhrase VALUES( '. See crime. and Local travel). ',  '. See crime and Local travel. ')
INSERT INTO Risk.ReplacePhrase VALUES( '. See crime. and Local travel. ',   '. See crime and Local travel. ')

