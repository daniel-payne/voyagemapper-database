EXEC Geographic.MatchAirportTransitPoints 'lax'
EXEC Geographic.MatchAirportTransitPoints 'LHR'
EXEC Geographic.MatchAirportTransitPoints 'CDG'

EXEC Geographic.MatchTransitPoints 'heathrow'
EXEC Geographic.MatchTransitPoints 'stevenage'
EXEC Geographic.MatchTransitPoints 'preston'

EXEC Geographic.MatchAccommodationPoints 'Sheraton Gateway Los Angeles'

EXEC Geographic.MatchPoints 'Sheraton Gateway'
EXEC Geographic.MatchPoints 'heathrow'
EXEC Geographic.MatchPoints 'stevenage'
EXEC Geographic.MatchPoints 'Los Angeles'

EXEC Geographic.FindLocationForLatLong 33.400,   73.100  
EXEC Geographic.FindLocationForLatLong 52.043,   0.014  
EXEC Geographic.FindLocationForLatLong 33.400,   73.100  
EXEC Geographic.FindLocationForLatLong 52.2053,  0.1218  
EXEC Geographic.FindLocationForLatLong 53.4808, -2.2426  

EXEC Geographic.FindContextForLatLong 33.400,   73.100  
EXEC Geographic.FindContextForLatLong 52.2053,  0.1218  
EXEC Geographic.FindContextForLatLong 53.4808, -2.2426 

EXEC Geographic.MatchCountriesInText 'Kenya travel advice - GOV.UK'

EXEC Geographic.MatchAddress 'Winnipeg, MB, Canada'
EXEC Geographic.MatchAddress 'London, England'
EXEC Geographic.MatchAddress 'Paris, France'
EXEC Geographic.MatchAddress 'Stevenage, England'

EXEC Geographic.GetContexstForReferences '170:7:25, 239:1:13:45306, 239:1:58:45952'

EXEC Risk.ListIncidentsForCountry 239 
EXEC Risk.GetIncidentsForIDs '287,288,289' 
EXEC Risk.GetIncidentsForIDs '1237,1287,1295,1299,1323,1336,3000,3008,5402,5478,6353,6357,6363,6416,6430,6451,6475,6476,6479,6480,6857,6872,6881,6936,7535,7536,7537,8616,8619,8625,8708,9780,9904,9914,9927,9957,12672,12686,14528,14536,16384,16389,16466,16495,16527,16555,16899,16908,16914,16946,17025,17026,17033,17034,17155,17171,17177,17610,17619,17647,17881,17947,19404,19439,19450,19491,54734,54912,55220,55221,55222,55223,55702,55717,55731,55739,55756,56010,56040,56070,56102,56744,56780,56883,57058,57480,57519,57520,57542,57590,57607,57686,57768,58032,58197,58215,58251,58390,58500,58505,58740,58855,58929,58995,58996,59032,59251,59274,59275,59276,59279,59325,59379,59413,59583,59586,59817,59879,59925,59928,59963,60153,60154,60158,60177,60178,60317,60351,60695,60874,61357,61358,61359,61387,61631,61632,61755,61770,61805,61809,61822,62913,62950,63740,63787,63910,63972,63976,64000,64011,64012,65125,65126,98689,98730,98735,98736,98750,98758,99830,99831,99884,101297,101307,101369,102109,102956,102990,102993,102998,102999,103816,106621,107251,112934,113312'  
 
EXEC Geographic.MatchConurbation'Los Angeles'
EXEC Geographic.MatchConurbation'London'
EXEC Geographic.MatchConurbation'Paris'
EXEC Geographic.MatchConurbation'Stevenage'

EXEC Geographic.MatchSettlement'Los Angeles'
EXEC Geographic.MatchSettlement'London'
EXEC Geographic.MatchSettlement'Paris'
EXEC Geographic.MatchSettlement'Stevenage'
 