ACT:=#OPTION('obfuscateOutput',TRUE);
import $,STD;


BASEDATAF:=$.AnalyzeResources.BASEDATAF;
STRING44 City_key := ''     : STORED('City');
STRING2 State_key:= ''      : STORED('State_id');
UNSIGNED3 Fips_key:=0       : STORED('County_Fips');
STRING44 CountyName_key:=''    : STORED('County_Name');
UNSIGNED3 ZIPCODE_key:=0        : STORED('ZIPCODE');

Formatcity := $.FORMATWORDS.FORMATCITY_V1;

Basekey := $.Generate_IDX.CSIDX;



EXPORT DWCSearchHaven(STRING44 City_key,STRING2 State_key,UNSIGNED3 Fips_key,STRING44 CountyNameKey,UNSIGNED3 ZIPCODEKey)       := FUNCTION
         
Heaven_filter:=BASEKEY(City_key='' OR Formatcity(City_Key)=City,
                State_key='' OR formatcity(State_key)=State_id,
                Fips_key=0  OR Fips_key=county_fips,
                CountyNameKey='' OR formatcity(CountyName_Key)=county_name,
                ZipCode_Key=0 OR ZipCode_key in ZipCodes
                );

    AllFields:=FETCH(BASEDATAF,Heaven_Filter,RIGHT.RecPos);
   RETURN AllFields;
END;
