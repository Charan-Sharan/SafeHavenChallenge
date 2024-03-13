

import $,STD;
BaseFile:=$.AnalyzeResources.BASEDATAF;
 BOOLEAN TOP10:= FALSE : STORED('TOP10');
 BOOLEAN ListRisky:=FALSE : STORED('ListRisky');
 ds:=$.AnalyzeSocialFactors.SocialFactorDS;

EXPORT DWCLIstHaven(BOOLEAN ListRisky,BOOLEAN Top10):=FUNCTION
 
  Lmt:=IF(Top10,10,1);
  AllFields:=IF(ListRisky,OUTPUT(SORT(ds(Crimescore<>0),-RiskFactor)[1..lmt],{city,state_id,state_Name,County_name,educationScore,UnemploymentScore,PopulationScore,PovertyScore,CrimeScore,riskFactor}),
                          OUTPUT(SORT(ds(Crimescore<>0),RiskFactor)[1..lmt],{city,state_id,state_Name,County_name,educationScore,UnemploymentScore,PopulationScore,PovertyScore,CrimeScore,riskFactor}));
                    
  RETURN ALLFields;
END;