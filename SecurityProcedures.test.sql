-- SELECT * FROM Security.Person

DECLARE @SessionGUID uniqueidentifier

DELETE FROM Security.Person

EXEC Security.GetSessionForNewUser            'daniel.payne@keldan.co.uk',  '123', '127.0.0.1'
EXEC Security.GetSessionForExistingUser       'daniel.payne@keldan.co.uk',  '123', '127.0.0.1'
                                              
EXEC Security.GetSessionForExistingUser       'daniel.payne@keldan.co.uk', '1234', '127.0.0.1'
EXEC Security.GetSessionForExistingUser       'daniel.payne4@keldan.co.uk', '123', '127.0.0.1'

EXEC Security.GetPasswordResetForExistingUser 'daniel.payne@keldan.co.uk', '1234', '127.0.0.1'
EXEC Security.GetSessionForExistingUser       'daniel.payne@keldan.co.uk',  '123', '127.0.0.1'
EXEC Security.GetSessionForExistingUser       'daniel.payne@keldan.co.uk', '1234', '127.0.0.1'

SELECT @SessionGUID = SessionGUID FROM Security.Person WHERE EMailAddress = 'daniel.payne@keldan.co.uk'

EXEC Security.GetRefreshForSession    @SessionGUID, '127.0.0.1'
EXEC Security.GetValidationForSession @SessionGUID, '127.0.0.1'

SELECT @SessionGUID = SessionGUID FROM Security.Person WHERE EMailAddress = 'daniel.payne@keldan.co.uk'
EXEC Security.GetValidationForSession @SessionGUID, '127.0.0.1'

EXEC Security.GetRevocationForSession @SessionGUID, '127.0.0.1'
EXEC Security.GetValidationForSession @SessionGUID, '127.0.0.1'
