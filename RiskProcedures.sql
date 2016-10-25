---------------------------------------------------------------------------------------------------
--Drops
---------------------------------------------------------------------------------------------------
IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'GetDocumentsUncurated'   AND type = 'P') DROP PROCEDURE Risk.GetDocumentsUncurated
IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'GetFacts'                AND type = 'P') DROP PROCEDURE Risk.GetFacts

IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'PostDocument'            AND type = 'P') DROP PROCEDURE Risk.PostDocument
IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'ProcesDocument'          AND type = 'P') DROP PROCEDURE Risk.ProcesDocument

IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'PutFactCategory'         AND type = 'P') DROP PROCEDURE Risk.PutFactCategory
IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'PutFactMerge'            AND type = 'P') DROP PROCEDURE Risk.PutFactMerge
IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'PutFactText'             AND type = 'P') DROP PROCEDURE Risk.PutFactText
go

---------------------------------------------------------------------------------------------------
--Drops
---------------------------------------------------------------------------------------------------
IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'ProcesDocuments'         AND type = 'P') DROP PROCEDURE Risk.ProcesDocuments
IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'PostDocumentFactStatus'  AND type = 'P') DROP PROCEDURE Risk.PostDocumentFactStatus
IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'GetUncuratedDocuments'   AND type = 'P') DROP PROCEDURE Risk.GetUncuratedDocuments
IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'ProcesDocumentFact'      AND type = 'P') DROP PROCEDURE Risk.ProcesDocumentFact
IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'ProcesDocumentFacts'     AND type = 'P') DROP PROCEDURE Risk.ProcesDocumentFacts
IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'PostLocation'            AND type = 'P') DROP PROCEDURE Risk.PostLocation
IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'PostSignal'              AND type = 'P') DROP PROCEDURE Risk.PostSignal
go
          
        
---------------------------------------------------------------------------------------------------------------------------------------------------
-- EXECUTE Risk.GetDocumentsUncurated 'NOCOVERAGE'
---------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [Risk].[GetDocumentsUncurated] 
(
  @MaxDocumentCount   integer       = 10
)
AS 


SELECT TOP (@MaxDocumentCount)
  D.DocumentID                              'documentId', 
  D.DocumentSource                          'documentSource', 
  D.DocumentTitle                           'documentTitle' 
FROM
  Risk.Document  D
WHERE
  IsLatestDocument = 1 
AND
  CuratedAtUTC IS NULL


RETURN @@ROWCOUNT

GO

GRANT EXECUTE ON [Risk].[GetDocumentsUncurated] TO [risk.service]
GO

---------------------------------------------------------------------------------------------------------------------------------------------------
-- EXECUTE Risk.GetFacts 104, 'GOOGLEARRAY'
---------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [Risk].[GetFacts] 
(
  @DocumentID         integer,
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
    IsMerged                            'isMerged'  
  FROM
    Risk.Fact  F
  LEFT OUTER JOIN
    Geographic.Country C ON C.CountryID = F.CountryID
  WHERE
    F.DocumentID = @DocumentID


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
    IsMerged                            'isMerged'  
  FROM
    Risk.Fact  F
  LEFT OUTER JOIN
    Geographic.Country C ON C.CountryID = F.CountryID
  WHERE
    F.DocumentID = @DocumentID

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
    IsMerged                            'isMerged'  
  FROM
    Risk.Fact  F
  LEFT OUTER JOIN
    Geographic.Country C ON C.CountryID = F.CountryID
  WHERE
    F.DocumentID = @DocumentID

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
    IsMerged                            'isMerged'  
  FROM
    Risk.Fact  F
  LEFT OUTER JOIN
    Geographic.Country C ON C.CountryID = F.CountryID
  WHERE
    F.DocumentID = @DocumentID

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
    IsMerged                            'isMerged' 
  FROM
    Risk.Fact  F
  LEFT OUTER JOIN
    Geographic.Country C ON C.CountryID = F.CountryID
  WHERE
    F.DocumentID = @DocumentID

END

RETURN @@ROWCOUNT
GO

GRANT EXECUTE ON [Risk].[GetFacts] TO [risk.service]
GO


USE [VoyageMapper]
GO

/****** Object:  StoredProcedure [Risk].[ProcesDocument]    Script Date: 25/10/2016 19:49:49 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


---------------------------------------------------------------------------------------------------------------------------------------------------
-- EXECUTE Risk.ProcesDocument 104 
---------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [Risk].[ProcesDocument] 
(
  @DocumentID           integer,
  @Title                varchar(max),
  @Text                 varchar(max) 
)
AS 
--declare @DocumentID int = 104 

DECLARE @toleranceInMeters integer = 1000;       

DECLARE @CountryID            int
DECLARE @Input                varchar(max)
DECLARE @DocumentCoverage     geography
DECLARE @PhraseCode           varchar(255)
DECLARE @WordCodes            varchar(max)
DECLARE @LastCategoryCode     varchar(255)
DECLARE @FactText             varchar(max)
DECLARE @FactHash             varbinary(8000)

DECLARE @FACTS    TABLE (FactText varchar(max))
DECLARE @COVERAGE TABLE (BorderReferences varchar(max), PlaceReferences varchar(max), BoundaryReferences varchar(max), countyReferences varchar(max), textCoverage geography)
DECLARE @RESULTS  TABLE (RowID int IDENTITY (1,1), PhraseCode varchar(50), FactText varchar(max), FactHash varbinary(max), BorderReferences varchar(max), PlaceReferences varchar(max), BoundaryReferences varchar(max), countyReferences varchar(max), textCoverage geography, WordCodes   varchar(max) )

------------------------------------------------------------------------------------------------------------------------------------------------

SET @Title  = ' ' + @Title + ' ' 
SET @Text   = ' ' + @Text  + ' '

DELETE FROM 
  Risk.Fact
WHERE
  DocumentID = @DocumentID

INSERT INTO @FACTS(FactText)
  SELECT
    dbo.TextToSimpleString(item, 0)
  FROM
    dbo.ListToTable( @Text, '.' ) 
  WHERE
    datalength(item) > 0

------------------------------------------------------------------------------------------------------------------------------------------------

SELECT TOP 1
  @CountryID = CountryID
FROM
  Geographic.CountryName
WHERE
  CHARINDEX(CountryMatchName, @Title) > 0
ORDER BY
  datalength(CountryMatchName) DESC

IF @CountryID IS NULL BEGIN

  --UPDATE Risk.Document SET
  --  CuratedAtUTC     = getutcdate() 
  --WHERE
  --  DocumentID = @DocumentID

  RETURN 0

END

------------------------------------------------------------------------------------------------------------------------------------------------

DECLARE FACT_CURSOR CURSOR FOR  
  SELECT FactText 
  FROM   @FACTS 
  

OPEN FACT_CURSOR   
FETCH NEXT FROM FACT_CURSOR INTO @FactText   

WHILE @@FETCH_STATUS = 0 BEGIN   
   
  SET @FactHash = HASHBYTES('SHA1', @FactText); 

  INSERT INTO @COVERAGE (borderReferences, PlaceReferences , boundaryReferences , countyReferences , textCoverage)
    EXECUTE Geographic.GetCoverage @FactText, @CountryID

  SELECT  
     @WordCodes = COALESCE(@WordCodes + ', ', '') + CategoryCode 
  FROM
    Risk.TriggerPhrases
  WHERE
    PATINDEX(TriggerPhrase, @FactText) > 0

  IF @WordCodes IS NULL BEGIN

    SELECT  
      @WordCodes = COALESCE(@WordCodes + ', ', '') + CategoryCode   
    FROM
      Risk.TriggerWords
    WHERE
      CHARINDEX(TriggerWord, @FactText) > 0
    GROUP BY
      CategoryCode
    ORDER BY
      sum(1.0/CategoryCount)                DESC,
      min(CHARINDEX(TriggerWord, @FactText)) ASC 

  END
   
  INSERT INTO @RESULTS 
    SELECT
      @PhraseCode,
      @FactText, 
      @FactHash,
      borderReferences, 
      PlaceReferences, 
      boundaryReferences, 
      countyReferences,
      textCoverage,
      @WordCodes 
    FROM   
      @COVERAGE

  DELETE FROM @COVERAGE

  SET @PhraseCode       = null
  SET @WordCodes        = null

  FETCH NEXT FROM FACT_CURSOR INTO @FactText   

END   

CLOSE      FACT_CURSOR   
DEALLOCATE FACT_CURSOR

------------------------------------------------------------------------------------------------------------------------------------

INSERT INTO Risk.Fact(DocumentID, FactText, FactHash, CountryID, BorderReferences, PlaceReferences, BoundaryReferences, CountyReferences, FactGeography, AnalysisCategories)
  SELECT 
    @DocumentID, 
    FactText,
    FactHash, 
    @CountryID, 
    BorderReferences, 
    PlaceReferences, 
    BoundaryReferences,
    CountyReferences, 
    TextCoverage,
    WordCodes
  FROM
    @RESULTS 
 
RETURN
GO

--GRANT EXECUTE ON [Risk].[ProcesDocument] TO [risk.service]
--GO


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

SET @Source = LOWER(@Source)
 
SET @Title = dbo.TextToAlphebeticString(@Title)
SET @Text  = LOWER(@Text)

SET @DocumentHash = HASHBYTES('SHA1', @Text); 

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
    IsLatestDocument,
    RetrievedAtUTC
  )
  VALUES
  (
    @Source,
    @Title,
    @DocumentHash,
    1,
    getutcdate()
  )

  EXECUTE Risk.ProcesDocument @@IDENTITY, @Title, @Text 

END

RETURN @@ROWCOUNT
GO


GRANT EXECUTE ON [Risk].[PostDocument] TO [risk.service]
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

RETURN @@ROWCOUNT
GO

GRANT EXECUTE ON [Risk].[PutFactCategory] TO [risk.service]
GO

---------------------------------------------------------------------------------------------------------------------------------------------------
-- EXECUTE Risk.PutFactMerge 4863, 'Some Text goes here'
---------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [Risk].[PutFactMerge] 
(
  @FactID             integer    
)
AS 

DECLARE 
  @PriorFactID      integer,
  @PriorFactText    varchar(max),
  @FactText         varchar(max)

SELECT
  @PriorFactID   = FactID,
  @PriorFactText = FactText
FROM
  Risk.Fact
WHERE
  FactID = @FactID
AND
  DocumentID = (SELECT DocumentID FROM Risk.Fact WHERE FactID = @FactID)

IF @PriorFactID IS NOT NULL BEGIN

  UPDATE Risk.Fact SET
    DisplayText    = @PriorFactText + '; ' + @FactText,
    IsMerged       = 1     
  WHERE
    FactID         = @PriorFactID

END

RETURN @@ROWCOUNT
GO

GRANT EXECUTE ON [Risk].[PutFactMerge] TO [risk.service]
GO

---------------------------------------------------------------------------------------------------------------------------------------------------
-- EXECUTE Risk.PutFactText 4863, 'Some Text goes here'
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

RETURN @@ROWCOUNT
GO

GRANT EXECUTE ON [Risk].[PutFactText] TO [risk.service]
GO
