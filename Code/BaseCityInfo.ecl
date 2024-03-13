//This file holds the base city information based on which further files like social factors and resources will be added to this


import $,STD;
EXPORT BaseCityInfo:=MODULE
SHARED CityDS:=$.File_AllData.City_DS;

SHARED FORMATCITY:=$.FORMATWORDS.FORMATCITY_V1;
SHARED RiskRec := RECORD
    STRING45  city;
    STRING2   state_id;
    STRING20  state_name;
    UNSIGNED3 county_fips;
    STRING30  county_name;
   SET OF UNSIGNED3 ZIpcodes:=[];
END;


EXPORT BaseInfo := PROJECT(CityDS,TRANSFORM(RiskRec,
                                    SELF.Zipcodes:=(SET OF UNSIGNED3)STD.Str.SplitWords(LEFT.zips,' '),
                                    SELF.CITY:=FORMATCITY(LEFT.CITY),
                                    SELF.state_name:=FORMATCITY(LEFT.STATE_NAME),
                                    SELF.county_name:=FORMATCITY(LEFT.county_name),
                                    SELF:=LEFT));



END;