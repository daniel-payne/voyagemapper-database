---------------------------------------------------------------------------------------------------
--Drops
---------------------------------------------------------------------------------------------------
IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'AddPoint'      AND type = 'P') DROP PROCEDURE Itinerary.AddPoint   
IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'RemovePoint'   AND type = 'P') DROP PROCEDURE Itinerary.RemovePoint 
  
IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'AddGroup'      AND type = 'P') DROP PROCEDURE Itinerary.AddGroup   
IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'InviteMember'  AND type = 'P') DROP PROCEDURE Itinerary.InviteMember   
IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'RemoveMember'  AND type = 'P') DROP PROCEDURE Itinerary.RemoveMember   
go 
 
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- EXEC Itinerary.AddPoint 'Sheraton Los Angeles'
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE Itinerary.AddPoint
(
  @OwnerID             int,
  @IsOwnerPerson       bit,
  @PointType           char(5), 
  @PointName           varchar(255), 
  @PointCode           varchar(20),
  @CountryNo           int, 
  @StateNo             int, 
  @CountyNo            int, 
  @ConurbationID       int, 
  @Latitude            float, 
  @Longitude           float, 
  @ArrivalTimeOffset   datetimeoffset, 
  @DepartureTimeOffset datetimeoffset, 
  @TravelReference     varchar(255), 
  @BookingReference    varchar(255)
)
AS

DECLARE @POINT_TYPES varchar(50) = 'FLDEP,FLARR,HOTEL,USPLA,GRPLA'
 
INSERT INTO Itinerary.Point 
(
  OwnerID, 
  IsOwnerPerson, 
  PointType, 
  PointName, 
  PointCode, 
  CountryNo, 
  StateNo, 
  CountyNo, 
  ConurbationID, 
  Latitude, 
  Longitude, 
  ArrivalTimeOffset, 
  DepartureTimeOffset, 
  TravelReference, 
  BookingReference
)
VALUES
(
  @OwnerID,         
  @IsOwnerPerson,   
  @PointType,       
  @PointName,       
  @PointCode,       
  @CountryNo,       
  @StateNo,         
  @CountyNo,        
  @ConurbationID,   
  @Latitude,        
  @Longitude,       
  @ArrivalTimeOffset,  
  @DepartureTimeOffset,
  @TravelReference, 
  @BookingReference
)
 

RETURN @@ROWCOUNT
go

GRANT EXECUTE ON Itinerary.AddPoint TO restclient
go
 