---------------------------------------------------------------------------------------------------
--Drops
---------------------------------------------------------------------------------------------------
IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'PostDocument'            AND type = 'P') DROP PROCEDURE Risk.PostDocument
IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'ProcesDocument'          AND type = 'P') DROP PROCEDURE Risk.ProcesDocument
IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'ProcesDocuments'         AND type = 'P') DROP PROCEDURE Risk.ProcesDocuments
IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'GetDocumentFacts'        AND type = 'P') DROP PROCEDURE Risk.GetDocumentFacts
IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'GetUncuratedDocuments'   AND type = 'P') DROP PROCEDURE Risk.GetUncuratedDocuments
IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'PostDocumentFactStatus'  AND type = 'P') DROP PROCEDURE Risk.PostDocumentFactStatus

go

---------------------------------------------------------------------------------------------------
--Drops
---------------------------------------------------------------------------------------------------
IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'ProcesDocumentFact'    AND type = 'P') DROP PROCEDURE Risk.ProcesDocumentFact
IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'ProcesDocumentFacts'   AND type = 'P') DROP PROCEDURE Risk.ProcesDocumentFacts
IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'PostLocation'          AND type = 'P') DROP PROCEDURE Risk.PostLocation
IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'PostSignal'            AND type = 'P') DROP PROCEDURE Risk.PostSignal
go
          

---------------------------------------------------------------------------------------------------------------------------------------------------
-- EXECUTE Risk.GetUncuratedDocuments 'NOCOVERAGE'
---------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [Risk].[GetUncuratedDocuments] 
(
  @CoverageFormat     varchar(20)   = 'NOCOVERAGE',
  @MaxDocumentCount   integer       = 10
)
AS 

IF UPPER(@coverageFormat) = 'NOCOVERAGE' BEGIN

  SELECT TOP (@MaxDocumentCount)
    D.DocumentID                              'documentId', 
    C.CountryID                               'countryId',
    C.CountryName                             'countryName',
    D.DocumentSource                          'documentSource', 
    D.DocumentTitle                           'documentTitle', 
    NULL                                      'documentCoverage'
  FROM
    Risk.Document  D
  LEFT OUTER JOIN
    Geographic.Country C ON C.CountryID = D.CountryID
  WHERE
    IsLatestDocument = 1 
  AND
    CuratedAtUTC IS NULL

END ELSE IF UPPER(@coverageFormat) = 'GEOJSON' BEGIN

  SELECT TOP (@MaxDocumentCount)
    D.DocumentID                              'documentId', 
    C.CountryID                               'countryId', 
    C.CountryName                             'countryName',
    D.DocumentSource                          'documentSource', 
    D.DocumentTitle                           'documentTitle', 
    dbo.CastAsGeoJSON(D.DocumentCoverage)     'documentCoverage'
  FROM
    Risk.Document  D
  LEFT OUTER JOIN
    Geographic.Country C ON C.CountryID = D.CountryID
  WHERE
    IsLatestDocument = 1 
  AND
    CuratedAtUTC IS NULL

END ELSE IF UPPER(@coverageFormat) = 'GOOGLEARRAY' BEGIN

  SELECT TOP (@MaxDocumentCount)
    D.DocumentID                              'documentId', 
    C.CountryID                               'countryId', 
    C.CountryName                             'countryName',
    D.DocumentSource                          'documentSource', 
    D.DocumentTitle                           'documentTitle', 
    dbo.CastAsGoogleArray(D.DocumentCoverage) 'documentCoverage'
  FROM
    Risk.Document  D
  LEFT OUTER JOIN
    Geographic.Country C ON C.CountryID = D.CountryID
  WHERE
    IsLatestDocument = 1 
  AND
    CuratedAtUTC IS NULL

END ELSE IF UPPER(@coverageFormat) = 'SVG' BEGIN

  SELECT TOP (@MaxDocumentCount)
    D.DocumentID                             'documentId', 
    C.CountryID                              'countryId', 
    C.CountryName                            'countryName',
    D.DocumentSource                         'documentSource', 
    D.DocumentTitle                          'documentTitle', 
    CAST(D.DocumentCoverage as varchar(max)) 'documentCoverage'
  FROM
    Risk.Document  D
  LEFT OUTER JOIN
    Geographic.Country C ON C.CountryID = D.CountryID
  WHERE
    IsLatestDocument = 1 
  AND
    CuratedAtUTC IS NULL

END ELSE BEGIN
 
  SELECT TOP (@MaxDocumentCount)
    D.DocumentID        'documentId', 
    C.CountryID         'countryId', 
    C.CountryName       'countryName',
    D.DocumentSource    'documentSource', 
    D.DocumentTitle     'documentTitle', 
    D.DocumentCoverage  'documentCoverage'
  FROM
    Risk.Document  D
  LEFT OUTER JOIN
    Geographic.Country C ON C.CountryID = D.CountryID
  WHERE
    IsLatestDocument = 1 
  AND
    CuratedAtUTC IS NULL

END

RETURN @@ROWCOUNT
go

GRANT EXECUTE ON [Risk].[GetUncuratedDocuments] TO [risk.service]
GO

---------------------------------------------------------------------------------------------------------------------------------------------------
-- EXECUTE Risk.GetDocumentFacts 104, 'GOOGLEARRAY'
---------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [Risk].[GetDocumentFacts] 
(
  @DocumentID         integer,
  @CoverageFormat     varchar(20)   = 'NOCOVERAGE'
)
AS 

IF UPPER(@coverageFormat) = 'NOCOVERAGE' BEGIN

  SELECT
    DocumentFactID                      'documentFactId',
    DocumentID                          'documentId',
    FactCategory                        'factCategory',
    FactText                            'factText',
    IsRelevant                          'isRelevant',
    borderReferences                    'borderReferences',
    placeReferences                     'placeReferences',
    boundaryReferences                  'boundaryReferences',
    null                                'factGeography',
    AnalysisCategories                  'analysisCategories',
    FactStatus                          'factStatus' 
  FROM
    Risk.DocumentFact  F
  WHERE
    F.DocumentID = @DocumentID


END ELSE IF UPPER(@coverageFormat) = 'GEOJSON' BEGIN

  SELECT
    DocumentFactID                      'documentFactId',
    DocumentID                          'documentId',
    FactCategory                        'factCategory',
    FactText                            'factText',
    IsRelevant                          'isRelevant',
    borderReferences                    'borderReferences',
    placeReferences                     'placeReferences',
    boundaryReferences                  'boundaryReferences',
    dbo.CastAsGeoJSON(FactGeography)    'factGeography',
    AnalysisCategories                  'analysisCategories',
    FactStatus                          'factStatus' 
  FROM
    Risk.DocumentFact  F
  WHERE
    F.DocumentID = @DocumentID

END ELSE IF UPPER(@coverageFormat) = 'GOOGLEARRAY' BEGIN

  SELECT
    DocumentFactID                      'documentFactId',
    DocumentID                          'documentId',
    FactCategory                        'factCategory',
    FactText                            'factText',
    IsRelevant                          'isRelevant',
    borderReferences                    'borderReferences',
    placeReferences                     'placeReferences',
    boundaryReferences                  'boundaryReferences',
    dbo.CastAsGoogleArray(FactGeography)'factGeography',
    AnalysisCategories                  'analysisCategories',
    FactStatus                          'factStatus' 
  FROM
    Risk.DocumentFact  F
  WHERE
    F.DocumentID = @DocumentID

END ELSE IF UPPER(@coverageFormat) = 'SVG' BEGIN

  SELECT
    DocumentFactID                      'documentFactId',
    DocumentID                          'documentId',
    FactCategory                        'factCategory',
    FactText                            'factText',
    IsRelevant                          'isRelevant',
    borderReferences                    'borderReferences',
    placeReferences                     'placeReferences',
    boundaryReferences                  'boundaryReferences',
    CAST(FactGeography as varchar(max)) 'factGeography',
    AnalysisCategories                  'analysisCategories',
    FactStatus                          'factStatus' 
  FROM
    Risk.DocumentFact  F
  WHERE
    F.DocumentID = @DocumentID

END ELSE BEGIN
 
  SELECT
    DocumentFactID                      'documentFactId',
    DocumentID                          'documentId',
    FactCategory                        'factCategory',
    FactText                            'factText',
    IsRelevant                          'isRelevant',
    borderReferences                    'borderReferences',
    placeReferences                     'placeReferences',
    boundaryReferences                  'boundaryReferences',
    FactGeography                       'factGeography',
    AnalysisCategories                  'analysisCategories',
    FactStatus                          'factStatus' 
  FROM
    Risk.DocumentFact  F
  WHERE
    F.DocumentID = @DocumentID

END

RETURN @@ROWCOUNT
go 


GRANT EXECUTE ON [Risk].[GetDocumentFacts] TO [risk.service]
GO

---------------------------------------------------------------------------------------------------------------------------------------------------
-- EXECUTE Risk.PostDocumentFactStatus 4863, 'PROFILE'
---------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [Risk].[PostDocumentFactStatus] 
(
  @DocumentFactID     integer,
  @FactStatus         varchar(255)    
)
AS 

DECLARE @FactText varchar(max)

SELECT 
  @FactText = FactText
FROM
  Risk.DocumentFact
WHERE
  DocumentFactID = @DocumentFactID

IF @FactStatus = 'DISCARDED' BEGIN

  UPDATE Risk.DocumentFact SET
    FactStatus = @FactStatus 
  WHERE
    FactText = @FactText

END ELSE BEGIN

   UPDATE Risk.DocumentFact SET
    FactStatus = @FactStatus 
  WHERE
    DocumentFactID = @DocumentFactID

END



RETURN @@ROWCOUNT
go 


GRANT EXECUTE ON [Risk].[PostDocumentFactStatus] TO [risk.service]
GO


---------------------------------------------------------------------------------------------------------------------------------------------------
-- EXECUTE Risk.ProcesDocument 104 
---------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [Risk].[ProcesDocument] 
(
  @DocumentID int 
)
AS 
--declare @DocumentID int = 104 

DECLARE @toleranceInMeters integer = 1000;       

DECLARE @Title                varchar(max)
DECLARE @Text                 varchar(max)
DECLARE @CountryID            int
DECLARE @Input                varchar(max)
DECLARE @DocumentCoverage     geography
DECLARE @PhraseCode           varchar(255)
DECLARE @WordCodes            varchar(max)
DECLARE @LastCategoryCode     varchar(255)
DECLARE @FactText             varchar(max)

DECLARE @FACTS    TABLE (FactText varchar(max))
DECLARE @COVERAGE TABLE (BorderReferences varchar(max), PlaceReferences varchar(max), BoundaryReferences varchar(max), textCoverage geography)
DECLARE @RESULTS  TABLE (RowID int IDENTITY (1,1), PhraseCode varchar(50), FactText varchar(max), IsRelevant bit, BorderReferences varchar(max), PlaceReferences varchar(max), BoundaryReferences varchar(max), textCoverage geography, WordCodes   varchar(max) )
DECLARE @MISSING  TABLE (RowID int               , PhraseCode varchar(50), FactText varchar(max), IsRelevant bit, BorderReferences varchar(max), PlaceReferences varchar(max), BoundaryReferences varchar(max), textCoverage geography, WordCodes   varchar(max) )

------------------------------------------------------------------------------------------------------------------------------------------------

SELECT 
  @Title  = ' ' + DocumentTitle + ' ',
  @Text   = ' ' + DocumentText  + ' '
FROM 
  Risk.Document 
WHERE 
  DocumentID = @DocumentID 

DELETE FROM 
  Risk.DocumentFact
WHERE
  DocumentID = @DocumentID

INSERT INTO @FACTS(FactText)
SELECT
  dbo.TextToSimpleString(item, 0)
FROM
  dbo.ListToTable( replace( @Text, CHAR(13), CHAR(10) ), CHAR(10) ) 

------------------------------------------------------------------------------------------------------------------------------------------------

SELECT
  @CountryID = CountryID
FROM
  Geographic.CountryName
WHERE
  CHARINDEX(CountryMatchName, @Title) > 0

IF @CountryID IS NULL BEGIN

  UPDATE Risk.Document SET
    AnalisedAtUTC     = getutcdate(),
    DocumentCoverage  = NULL,
    CountryID         = @CountryID 
  WHERE
    DocumentID = @DocumentID

  RETURN 0

END

------------------------------------------------------------------------------------------------------------------------------------------------

DECLARE FACT_CURSOR CURSOR FOR  
  SELECT FactText 
  FROM   @FACTS 
  

OPEN FACT_CURSOR   
FETCH NEXT FROM FACT_CURSOR INTO @FactText   

WHILE @@FETCH_STATUS = 0 BEGIN   

  INSERT INTO @COVERAGE (borderReferences, PlaceReferences , boundaryReferences , textCoverage)
    EXECUTE Geographic.GetCoverage @FactText, @CountryID

  SELECT TOP 1
    @PhraseCode = CategoryCode 
  FROM
    Risk.TriggerPhrases
  WHERE
    PATINDEX(TriggerPhrase, @FactText) > 0
  ORDER BY
    PATINDEX(TriggerPhrase, @FactText) ASC 

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
   
  INSERT INTO @RESULTS 
    SELECT
      @PhraseCode,
      @FactText, 
      CASE WHEN textCoverage IS NULL THEN 0 ELSE 1 END,
      borderReferences, 
      PlaceReferences, 
      boundaryReferences, 
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


INSERT INTO @MISSING
  SELECT 
    *
  FROM  
    @RESULTS
  WHERE
    PhraseCode IS NULL AND TextCoverage IS NOT NULL


UPDATE M SET
  PhraseCode = R.PhraseCode
FROM
(
  SELECT 
    *
  FROM  
    @RESULTS
  WHERE
    PhraseCode IS NULL AND TextCoverage IS NOT NULL
) M
INNER JOIN
  @RESULTS  R ON R.RowID = 
(
  SELECT TOP 1 
    RowID 
  FROM 
    @RESULTS 
  WHERE 
    PhraseCode IS NOT NULL 
  AND 
    RowID < M.RowID 
  ORDER BY 
    RowID DESC
)

------------------------------------------------------------------------------------------------------------------------------------

INSERT INTO Risk.DocumentFact(DocumentID, FactText, IsRelevant, BorderReferences, PlaceReferences, BoundaryReferences, FactGeography, FactCategory, AnalysisCategories)
  SELECT 
    @DocumentID, 
    FactText, 
    IsRelevant,
    BorderReferences, 
    PlaceReferences, 
    BoundaryReferences, 
    TextCoverage,
    PhraseCode,
    WordCodes
  FROM
    @RESULTS 

SELECT 
  @DocumentCoverage= Geography::UnionAggregate(TextCoverage) 
FROM 
  @RESULTS
WHERE
  TextCoverage IS NOT NULL

IF @DocumentCoverage IS NOT NULL BEGIN

  SET @DocumentCoverage = @DocumentCoverage.Reduce(@toleranceInMeters) 
  SET @DocumentCoverage = dbo.RemoveArtefacts(@DocumentCoverage) 

END

UPDATE Risk.Document SET
  AnalisedAtUTC     = getutcdate(),
  DocumentCoverage  = @DocumentCoverage,
  CountryID         = @CountryID 
WHERE
  DocumentID = @DocumentID

 
RETURN
GO
 
---------------------------------------------------------------------------------------------------------------------------------------------------
-- EXECUTE Risk.ProcesDocuments  -- UPDATE Risk.Document SET AnalisedAtUTC = NULL WHERE DocumentID = 104 
---------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE Risk.ProcesDocuments 
AS 

DECLARE @ID as int 
 
DECLARE @CURSOR as CURSOR;
 
SET @CURSOR = CURSOR FOR
 SELECT
   DocumentID
 FROM 
   Risk.Document
 WHERE
   AnalisedAtUTC IS NULL
 
OPEN @CURSOR;

FETCH NEXT FROM @CURSOR INTO @ID
 
WHILE @@FETCH_STATUS = 0 BEGIN
 
 PRINT 'Processing ID ' + cast(@ID as varchar(20))

 EXECUTE Risk.ProcesDocument @ID

 FETCH NEXT FROM @CURSOR INTO @ID
END
 
CLOSE      @CURSOR;
DEALLOCATE @CURSOR;

RETURN
go


---------------------------------------------------------------------------------------------------------------------------------------------------
--EXECUTE Risk.PostDocument 'https://keldan.co.uk/test-in-france.html', 'latest news', 'there is a problem in a town called autrey-les-gray.'   
--EXECUTE Risk.ProcesstDocuments 
---------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE Risk.PostDocument
  @Source      varchar(500), 
  @Title       varchar(500),
  @Text        varchar(max)
AS

DECLARE @CurrentID          integer
DECLARE @CurrentText        varchar(max) 

SET @Source = LOWER(@Source)
SET @Source = REPLACE(@Source, 'https://', '')
SET @Source = REPLACE(@Source, 'http://',  '')

SET @Title = dbo.TextToAlphebeticString(@Title)
SET @Text  = LOWER(@Text)

SELECT 
  @CurrentID       = DocumentID,
  @CurrentText     = DocumentText
FROM
  Risk.Document
WHERE
  DocumentSource    = @Source 
AND
  IsLatestDocument  = 1
 
IF @CurrentID IS NOT NULL AND @CurrentText = @Text BEGIN

  UPDATE Risk.Document SET
    AnalisedAtUTC = getutcdate()
  WHERE
    DocumentID = @CurrentID 
  AND
    AnalisedAtUTC IS NOT NULL 

END ELSE BEGIN

  UPDATE Risk.Document SET
    IsLatestDocument = 0
  WHERE
    DocumentID = @CurrentID 

  INSERT INTO Risk.Document
  ( 
    DocumentSource,
    DocumentTitle,
    DocumentText, 
    IsLatestDocument
  )
  VALUES
  (
    @Source,
    @Title,
    @Text,
    1
  )

  --EXECUTE Risk.ProcesDocument @@IDENTITY

END

RETURN @@ROWCOUNT
GO 

GRANT EXECUTE ON [Risk].[PostDocument] TO [riskservice]
GO


