---------------------------------------------------------------------------------------------------
--Drops
---------------------------------------------------------------------------------------------------
IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'GetAuthorizationForNewUser'       AND type = 'P') DROP PROCEDURE Security.GetAuthorizationForNewUser
IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'GetAuthorizationForExistingUser'  AND type = 'P') DROP PROCEDURE Security.GetAuthorizationForExistingUser
IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'GetAuthorizationForAnonymousUser' AND type = 'P') DROP PROCEDURE Security.GetAuthorizationForAnonymousUser
go

---------------------------------------------------------------------------------------------------
-- GetAuthorizationForAnonymousUser '127.0.0.1'
---------------------------------------------------------------------------------------------------
CREATE PROCEDURE Security.GetAuthorizationForAnonymousUser
(
   @IPAddress       Varchar(15)
)
AS
--
DECLARE @EXPIRY_HOURS integer = 96;
--
DECLARE
  @NewSessionGUID      uniqueidentifier,
  @SessionExpiresDate  DateTime   
--
SET @SessionExpiresDate = dateadd(hour, @EXPIRY_HOURS, getutcdate())
SET @NewSessionGUID     = newid()
--
INSERT INTO [Security].[Session]
(
	SessionGUID, 
	IsActive,
	IPAddress, 
	SessionExpiresUTC,
	IsAnynmous
)
VALUES
(
	@NewSessionGUID,
	1,
	@IPAddress,
	@SessionExpiresDate,
	1
) 
--
SELECT
	cast(@NewSessionGUID as varchar(50)  )                                   'authorizationCode',
	convert(varchar(19), @SessionExpiresDate, 126)                           'authorizationExpires' 
--      
RETURN @@rowcount
GO


---------------------------------------------------------------------------------------------------
-- GetAuthorizationForExistingUser 'daniel.payne@keldan.co.uk', '123', '127.0.0.1'
---------------------------------------------------------------------------------------------------
CREATE PROCEDURE Security.GetAuthorizationForExistingUser
(
   @EMail           Varchar(255),
   @Password        Varchar(255),
   @IPAddress       Varchar(15)
)
AS
--
DECLARE @EXPIRY_HOURS             integer;     SET @EXPIRY_HOURS             = 48;
DECLARE @MAX_BAD_TRY_COUNT        integer;     SET @MAX_BAD_TRY_COUNT        = 4;
--
DECLARE
  @PasswordHash        varbinary(20),
  @PersonID            integer,
  @NewSessionGUID      uniqueidentifier,
  @SessionExpiresDate  DateTime                               
--
SET @SessionExpiresDate = dateadd(hour, @EXPIRY_HOURS, getutcdate())
--
SELECT
  @PasswordHash = hashbytes('SHA1', @Password)
--
SELECT                                                                   
  @PersonID      = PersonID
FROM
  [Security].[Person]
WHERE                                                                   
  EMailAddress  = @EMail               AND
  PasswordHash  = @PasswordHash        AND
  IsLockedOut   = 0                    AND
  BadTryCount   < @MAX_BAD_TRY_COUNT
--
IF @PersonID IS NOT NULL BEGIN
  --
  UPDATE [Security].[Session] SET
    IsActive = 0 
  WHERE 
    PersonID = @PersonID             
  --
  SET @NewSessionGUID = newid()
  --
  INSERT INTO [Security].[Session]
  (
  	SessionGUID, 
  	PersonID, 
	IsActive,
  	IPAddress, 
  	SessionExpiresUTC,
	IsAnynmous
  )
  VALUES
  (
  	@NewSessionGUID,
  	@PersonID,
	1,
  	@IPAddress,
  	@SessionExpiresDate,
	0
  ) 
  --
  SELECT
    cast(@NewSessionGUID as varchar(50)  )                                   'authorizationCode',
    convert(varchar(19), @SessionExpiresDate, 126)                           'authorizationExpires' 
END ELSE BEGIN
  --
  SELECT 'User credentials are invalid' 'errorMessage' 
END
--      
RETURN @@rowcount
GO


---------------------------------------------------------------------------------------------------
-- GetAuthorizationForNewUser 'daniel.payne@keldan.co.uk', '123', '127.0.0.1'
---------------------------------------------------------------------------------------------------
CREATE PROCEDURE Security.GetAuthorizationForNewUser
(
   @EMailAddress    varchar(255),
   @Password        varchar(255),
   @IPAddress       Varchar(15)
)
AS
--
DECLARE @FREE_MEMBERSHIP_COUNT smallint = 3
--
DECLARE
  @PersonID            integer,
  @GroupID             integer,
  @PasswordHash        varbinary(20),
  @GroupName           varchar(250)                                    
--
SELECT
  @PasswordHash = hashbytes('SHA1', @Password)
--
IF NOT EXISTS (SELECT 1 FROM [Security].[Person] WHERE EMailAddress = @EMailAddress) BEGIN
  BEGIN TRANSACTION
	  --
	  INSERT INTO [Security].[Person]  
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
	  --
	  SELECT @PersonID  = SCOPE_IDENTITY()
	  SELECT @GroupName = REPLACE(REPLACE(@EMailAddress, '@', ' '), '.', ' ')
	  --
	  INSERT INTO Itinerary.Person
	  (
		PersonID,
		IsActive,
		PrimaryEMailAddress
	  )
	  VALUES
	  (
		@PersonID,
		1,
		@EMailAddress
	  )
	  --
	  INSERT INTO Itinerary.[Group]
	  (
		GroupName,
		PrimaryGroupAdminstratorPersonID,
		MaxMembershipCount 
	  )
	  VALUES
	  (
		@GroupName,
		@PersonID,
		@FREE_MEMBERSHIP_COUNT
	  )
	  --
	  SELECT @GroupID = SCOPE_IDENTITY()
	  --
	  INSERT INTO Itinerary.Member
	  (
		GroupID,
		PersonID,
		IsActive,
		DisplayName,
		InvitedAtUTC,
		AccecptedAtUTC
	  )
	  VALUES
	  (
		@GroupID,
		@PersonID,
		1,
		@EMailAddress,
		GETUTCDATE(),
		GETUTCDATE()
	  )
  COMMIT TRANSACTION
  --
  EXECUTE GetAuthorizationForExistingUser  @EMailAddress, @Password, @IPAddress
END ELSE BEGIN
  --
  SELECT 'User EMail exists' 'errorMessage' 
END
--      
RETURN @@rowcount
GO


