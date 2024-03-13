// #OPTION('obfuscateOutput',TRUE);

import $,STD;
EXPORT AnalyzeResources:=MODULE


SHARED FORMATCITY:=$.FORMATWORDS.FORMATCITY_V1;


SHARED layout:=$.AnalyzeSocialFactors.RiskPlusRec;
SHARED crime:=$.AnalyzeSocialFactors.JoinCrime;
SHARED rawCrime:=$.File_AllData.CrimeDS;
SHARED SocialFactorDs:=$.AnalyzeSocialFactors.SocialFactorDS;



EXPORT MainRec:=RECORD
    layout;
    UNSigned1 HospCount;
    DATASET($.CleanHospitals.HospRec) HospitalList;
    UNSIGNED1 PoliceCount;
    DATASET($.CleanPolicest.policerec) POliceList;
    UNSIGNED1 FireStationCount;
    DATASET($.CleanFireStns.FireRec) FireStationList;
    UNSIGNED1 ChurchesCnt;
    DATASET($.CleanChurches.CleanChurchRec)  ChurchList;
    UNSIGNED1 FoodBanksCount;
    DATASET($.CleanFoodBanks.FoodRec)    FoodBankList;
 

END;

MainRec MakeRoom(layout L):=TRANSFORM
    SELF.HospCount:=0;
    SELF.HospitalList:=[];
    SELF.PoliceCount:=0;
    SELF.POliceList:=[];
    SELF.FireStationCount:=0;
    SELF.FireStationList:=[];
    SELF.ChurchesCnt:=0;
    SELF.ChurchList:=[];
    SELF.FoodBanksCount:=0;
    SELF.FoodBankList:=[];
    SELF:=L;

END;
EXPORT MainParent:=PROJECT(SocialFactorDs,MakeRoom(LEFT));


MainRec MoveChild(MainRec L, $.CleanHospitals.HospRec R, UNSIGNED8 Cnt):=TRANSFORM
    SELF.HospCount:=Cnt;
    SELF.HospitalList:=L.HospitalList+ R ;
    SELF:=L;
END;

EXPORT JoinHosp:=DENORMALIZE(MainParent,$.CleanHospitals.HospitalDS,
                     LEFT.county_fips=RIGHT.PrimaryFIPS AND 
                      (STD.STR.Cleanspaces(STD.STR.TOUPPERCASE(LEFT.CITY))=STD.STR.Cleanspaces(RIGHT.CITY) OR RIGHT.ZIP IN LEFT.ZIpcodes ),
                     MoveChild(LEFT,RIGHT,COUNTER));
// OUTPUT(JOINHOSP);
EXPORT JoinPolice:=DENORMALIZE(JoinHosp,$.CleanPolicest.CleanPoliceDs,
                         LEFT.county_fips=RIGHT.PrimaryFIPS AND 
                    ( STD.STR.Cleanspaces(STD.STR.TOUPPERCASE(LEFT.CITY))=STD.STR.Cleanspaces(RIGHT.CITY) OR RIGHT.ZIP IN LEFT.ZIpcodes ),
                     TRANSFORM(Mainrec,
                     SELF.PoliceCount:=COUNTER,
                     SELF.POliceList:=LEFT.POliceList+RIGHT;
                     SELF:=LEFT
                     ));

// OUTPUT(JoinPOlice);

EXPORT JoinFireStns:=DENORMALIZE(JoinPolice,$.CleanFireStns.CleanFireStns,
                         LEFT.county_fips=RIGHT.PrimaryFIPS AND 
                    ( STD.STR.Cleanspaces(STD.STR.TOUPPERCASE(LEFT.CITY))=STD.STR.Cleanspaces(RIGHT.CITY) OR RIGHT.ZIP IN LEFT.ZIpcodes ),
                     TRANSFORM(Mainrec,
                     SELF.FireStationCount:=COUNTER,
                     SELF.FireStationList:=LEFT.FireStationList+RIGHT,
                     SELF:=LEFT
                     ));
// OUTPUT(JOINFirestns);

EXPORT JoinChurches:=DENORMALIZE(JoinFirestns,$.CleanChurches.CLeanChurchesDs,
                         LEFT.county_fips=RIGHT.PrimaryFIPS AND 
                     ( STD.STR.Cleanspaces(STD.STR.TOUPPERCASE(LEFT.CITY))=STD.STR.Cleanspaces(RIGHT.CITY) OR RIGHT.ZIP IN LEFT.ZIpcodes ),
                     TRANSFORM(Mainrec,
                     SELF.ChurchesCnt:=COUNTER,
                     SELF.ChurchList:=LEFT.ChurchList+RIGHT,
                     SELF:=LEFT
                     ));
EXPORT JoinFoodBank:=DENORMALIZE(JoinChurches,$.CleanFoodBanks.CleanFoodBanksDs,
                         LEFT.county_fips=RIGHT.PrimaryFIPS AND 
                     ( FORMATCITY(LEFT.CITY)=FORMATCITY(RIGHT.CITY) OR RIGHT.ZIP IN LEFT.ZIpcodes ),
                     TRANSFORM(Mainrec,
                     SELF.FoodBanksCount:=COUNTER,
                     SELF.FoodBankList:=LEFT.FoodBankList+RIGHT ,
                     SELF:=LEFT
                     ));
// output(JoinFoodBank(foodbankscount<>0),,'~SAFE::DWC::OUT::JFB');
EXPORT WriteBaseData:=output(JoinFoodBank,,'~SAFE::DWC::OUT::JoinALL',OVERWRITE);

EXPORT BASEDATA:=DATASET('~SAFE::DWC::OUT::JoinALL',MainRec,THOR);
EXPORT BASEDATAF:=DATASET('~SAFE::DWC::OUT::JoinALL',{MainRec,UNSIGNED8 RecPos {VIRTUAL(FilePosition)}},THOR);



END;

