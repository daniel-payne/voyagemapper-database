----------------------------------------------------------------------------------------------------------------------------------------------------------------
--Drops
----------------------------------------------------------------------------------------------------------------------------------------------------------------
IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'GetSessionForNewUser'            AND type = 'P') DROP PROCEDURE Security.GetSessionForNewUser
IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'GetSessionForExistingUser'       AND type = 'P') DROP PROCEDURE Security.GetSessionForExistingUser
IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'GetRevocationForSession'         AND type = 'P') DROP PROCEDURE Security.GetRevocationForSession
IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'GetPasswordResetForExistingUser' AND type = 'P') DROP PROCEDURE Security.GetPasswordResetForExistingUser
IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'GetRefreshForSession'            AND type = 'P') DROP PROCEDURE Security.GetRefreshForSession
IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'GetValidationForSession'         AND type = 'P') DROP PROCEDURE Security.GetValidationForSession
go

----------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Security.GetValidationForSession '603CACD7-CCE9-4ED8-AF16-DCBB526D18A2', '127.0.0.1'
----------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE Security.GetValidationForSession
(
   @SessionGUID     uniqueidentifier,
   @IPAddress       Varchar(15)
)
AS

DECLARE @EXPIRY_HOURS             integer;     SET @EXPIRY_HOURS             = 48;

IF EXISTS (SELECT 1 FROM Security.Person WHERE SessionGUID = @SessionGUID AND IPAddress = @IPAddress AND SessionExpiresUTC <= dateadd(hour, @EXPIRY_HOURS, getutcdate()) ) BEGIN

  SELECT 1 'isValid' 

END ELSE BEGIN

  SELECT 'Session does not exist' 'errorMessage' 

END
      
RETURN @@rowcount
GO

GRANT EXECUTE ON Security.GetValidationForSession TO riskservice
GO

----------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Security.GetRefreshForSession '603CACD7-CCE9-4ED8-AF16-DCBB526D18A2', '127.0.0.1'
----------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE Security.GetRefreshForSession
(
   @SessionGUID     uniqueidentifier,
   @IPAddress       Varchar(15)
)
AS

DECLARE @EXPIRY_HOURS             integer;     SET @EXPIRY_HOURS             = 48;

DECLARE
  @NewSessionGUID      uniqueidentifier,
  @SessionExpiresDate  DateTime   

SET @NewSessionGUID = newid()
SET @SessionExpiresDate = dateadd(hour, @EXPIRY_HOURS, getutcdate())

UPDATE Security.Person SET
  SessionGUID       = @NewSessionGUID,
  SessionExpiresUTC = @SessionExpiresDate 
WHERE
  SessionGUID = @SessionGUID AND
  IPAddress   = @IPAddress

IF @@rowcount = 1 BEGIN

  SELECT
    cast(@NewSessionGUID as varchar(50)  )                                   'sessionCode',
    convert(varchar(19), @SessionExpiresDate, 126)                           'sessionExpires' 

END ELSE BEGIN

  SELECT 'Session does not exist' 'errorMessage' 

END
      
RETURN @@rowcount
GO

GRANT EXECUTE ON Security.GetRefreshForSession TO riskservice
GO

----------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Security.GetPasswordResetForExistingUser 'daniel.payne@keldan.co.uk', '123', '127.0.0.1'
----------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE Security.GetPasswordResetForExistingUser
(
   @EMail           Varchar(255),
   @Password        Varchar(255),
   @IPAddress       Varchar(15)
)
AS

DECLARE
  @PasswordHash        varbinary(20)

SELECT
  @PasswordHash = hashbytes('SHA1', @Password)

UPDATE Security.Person SET
  PasswordHash      = @PasswordHash 
WHERE 
  EMailAddress      = @EMail    

IF @@ROWCOUNT = 1 BEGIN

 SELECT 'Password updated' 'successMessage' 

END ELSE BEGIN

 SELECT 'User credentials are invalid' 'errorMessage' 

END

RETURN @@rowcount
GO

GRANT EXECUTE ON Security.GetPasswordResetForExistingUser TO riskservice
GO

----------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Security.GetSessionForExistingUser 'daniel.payne@keldan.co.uk', '123', '127.0.0.1'
----------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE Security.GetSessionForExistingUser
(
   @EMail           Varchar(255),
   @Password        Varchar(255),
   @IPAddress       Varchar(15)
)
AS

DECLARE @EXPIRY_HOURS             integer;     SET @EXPIRY_HOURS             = 48;
DECLARE @MAX_BAD_TRY_COUNT        integer;     SET @MAX_BAD_TRY_COUNT        = 4;

DECLARE
  @PasswordHash        varbinary(20),
  @PersonID            integer,
  @NewSessionGUID      uniqueidentifier,
  @SessionExpiresDate  DateTime                               

SET @SessionExpiresDate = dateadd(hour, @EXPIRY_HOURS, getutcdate())

SELECT
  @PasswordHash = hashbytes('SHA1', @Password)

SELECT                                                                   
  @PersonID      = PersonID
FROM
  Security.Person
WHERE                                                                   
  EMailAddress  = @EMail               AND
  PasswordHash  = @PasswordHash        AND
  IsLockedOut   = 0                    AND
  BadTryCount   < @MAX_BAD_TRY_COUNT

IF @PersonID IS NOT NULL BEGIN
  
  SET @NewSessionGUID = newid()
  
  UPDATE Security.Person SET
    SessionGUID       = @NewSessionGUID,
    IPAddress         = @IPAddress,
    SessionExpiresUTC = @SessionExpiresDate
  WHERE 
    PersonID = @PersonID            

  SELECT
    cast(@NewSessionGUID as varchar(50)  )                                   'sessionCode',
    convert(varchar(19), @SessionExpiresDate, 126)                           'sessionExpires' 

END ELSE BEGIN
  
  SELECT 'User credentials are invalid' 'errorMessage' 

END
      
RETURN @@rowcount
GO

GRANT EXECUTE ON Security.GetSessionForExistingUser TO riskservice
GO

----------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Security.GetSessionForNewUser 'daniel.payne@keldan.co.uk', '123', '127.0.0.1'
----------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE Security.GetSessionForNewUser
(
   @EMailAddress    varchar(255),
   @Password        varchar(255),
   @IPAddress       Varchar(15)
)
AS

DECLARE
  @PersonID            integer,
  @GroupID             integer,
  @PasswordHash        varbinary(20),
  @GroupName           varchar(250)                                    

SELECT
  @PasswordHash = hashbytes('SHA1', @Password)

IF NOT EXISTS (SELECT 1 FROM Security.Person WHERE EMailAddress = @EMailAddress) BEGIN
 	  
	  INSERT INTO Security.Person  
	  (
		  IsActive,
		  EMailAddress, 
		  PasswordHash, 
		  CreatedUTC, 
		  IsLockedOut, 
		  BadTryCount 
	  )
	  VALUES
	  (
		  1,
		  @EMailAddress,
		  @PasswordHash,
		  getutcdate(),
		  0,
		  0  
	  )
	  
  EXECUTE Security.GetSessionForExistingUser  @EMailAddress, @Password, @IPAddress

END ELSE BEGIN
  
  SELECT 'User EMail exists' 'errorMessage' 

END
      
RETURN @@rowcount
GO

GRANT EXECUTE ON Security.GetSessionForNewUser TO riskservice
GO

----------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Security.GetRevocationForSession 'D488EC02-9E0C-46D6-8CDE-C035E76BDB3F', '127.0.0.1'
----------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE Security.GetRevocationForSession
(
   @SessionGUID     uniqueidentifier,
   @IPAddress       Varchar(15)
)
AS

UPDATE Security.Person SET
  SessionGUID       = null,
  SessionExpiresUTC = null 
WHERE
  SessionGUID = @SessionGUID AND
  IPAddress   = @IPAddress

IF @@rowcount = 1 BEGIN

SELECT
	convert(varchar(19), getutcdate(), 126)  'SessionExpired' 

END ELSE BEGIN

  SELECT 'Session does not exist' 'errorMessage' 

END
      
RETURN @@rowcount
GO

GRANT EXECUTE ON Security.GetRevocationForSession TO riskservice
GO




