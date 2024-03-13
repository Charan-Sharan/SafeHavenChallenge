IMPORT $,STD;
EXPORT Generate_IDX:=MODULE
SHARED BaseFile:=$.AnalyzeResources.BASEDATAF;
SHARED SocialFactorDs:=$.AnalyzeSocialFactors.SocialFactorDS;
EXPORT CSIDX:=INDEX(BaseFile,{city,state_id,county_fips},{city,county_Fips,County_name,ZipCodes,state_id,recPos},'~SAFE::DWC::OUT::BASEINDEX');
EXPORT RSIDX:=INDEX(SocialFactorDs,{City,state_id,County_fips},{city,state_id,state_Name,County_name,educationScore,PovertyScore,CrimeScore,riskFactor},'~SAFE::DWC::OUT::SOCIALINDEX');


END;