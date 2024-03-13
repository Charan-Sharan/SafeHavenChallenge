// #OPTION('obfuscateOutput',TRUE);
import $,STD;
EXPORT CleanFireStns:=MODULE
SHARED Fire:=$.File_AllData.FireDS;
SHARED City:=$.BaseCityInfo.BaseInfo;


SHARED FORMATCITY:=$.FORMATWORDS.FORMATCITY_V1;


EXPORT FireRec:=RECORD
    STRING100 NAME;
    STRING62 STREET;
    UNSIGNED3 ZIP;
    STRING31 CITY;
    STRING2 STATE;
    UNSIGNED3 PrimaryFips;

END;

SHARED FireDs:=PROJECT(Fire,TRANSFORM(FireRec,
                               SELF.NAME:=STD.Str.ToUpperCase(STD.STR.CleanSpaces(LEFT.NAME)),
                               SELF.STREET:=STD.Str.ToUpperCase(STD.STR.CleanSpaces(LEFT.address)),
                               SELF.ZIP:=(UNSIGNED3)LEFT.ZIPCODE,
                               SELF.CITY:=FORMATCITY(LEFT.CITY),
                               SELF.STATE:=STD.Str.ToUpperCase(STD.STR.CleanSpaces(LEFT.STATE)),
                               SELF.PrimaryFIPS:=0));

SHARED CleanFire:=JOIN(FireDs,City,
                STD.STR.ToUpperCase(LEFT.CITY)= STD.STR.ToUpperCase(RIGHT.city)AND
                STD.STR.ToUpperCase(LEFT.STATE)=RIGHT.STATE_ID,TRANSFORM(FireRec,
                SELF.PrimaryFIPS:=(UNSIGNED3)RIGHT.county_fips,
                SELF:=LEFT
                ),LEFT OUTER,LOOKUP);
EXPORT WriteFire:=OUTPUT(CleanFire,,'~SAFE::DWC::OUT::FireStns',OVERWRITE);
EXPORT CleanFireStns:=DATASET('~SAFE::DWC::OUT::FireStns',FireRec,THOR);

END;