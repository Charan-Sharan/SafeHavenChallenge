// #OPTION('obfuscateOutput',TRUE);

import $,STD;
EXPORT BWR_XTAB:=MODULE
// createfile:=$.BWR_CreateCoreExample.createDS;
// createfile;
// createHosp:=$.BWR_CleanHospitals.WriteHosp;
// createHosp;

SHARED ScoreDs:=$.BWR_CreateCoreExample.FinalDs;
SHARED layout:=$.BWR_CreateCoreExample.RiskPlusRec;
SHARED crime:=$.BWR_CreateCoreExample.JoinCrime;
SHARED rawCrime:=$.File_AllData.CrimeDS;
SHARED NormalizeScore:=PROJECT(ScoreDs,TRANSFORM(layout,
                        SELF.crimescore:=(LEFT.crimeScore/1791)*100,
                        SELF.populationScore:=(LEFT.populationScore/3264)*100,
                        SELF:=LEFT));

//RiskFactor Contrubution by weights
SHARED Decimal2_2 CrimeWt:=0.5;
SHARED Decimal2_2 PovertyWt:=0.3;
SHARED Decimal2_2 educationWt:=0.15;
SHARED Decimal2_2 populationWt:=0.05;
EXPORT CalcTotalval:=PROJECT(NormalizeScore,TRANSFORM(layout,
                    SELF.total:=(LEFT.crimeScore*crimeWt+LEFT.PovertyScore*PovertyWt+LEFT.EducationScore*educationWt+LEFT.PopulationScore*PopulationWt),
                    SELF:=LEFT));

EXPORT MainRec:=RECORD
    layout;
    UNSigned1 HospCount;
    DATASET($.BWR_CleanHospitals.HospRec) HospitalList{MAXCOUNT(25)};
    UNSIGNED1 PoliceCount;
    DATASET($.CleanPolicest.policerec) POliceList{MAXCOUNT(15)};
    UNSIGNED1 FireStationCount;
    DATASET($.CleanFireStns.FireRec) FireStationList{MAXCOUNT(15)};
    UNSIGNED1 ChurchesCnt;
    DATASET($.CleanChurches.CleanChurchRec)  ChurchList{MAXCOUNT(15)};
    UNSIGNED1 FoodBanksCount;
    DATASET($.CleanFoodBanks.FoodRec)    FoodBankList{MAXCOUNT(5)};
 

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
EXPORT MainParent:=PROJECT(CalcTotalval,MakeRoom(LEFT));


MainRec MoveChild(MainRec L, $.BWR_CleanHospitals.HospRec R, UNSIGNED8 Cnt):=TRANSFORM
    SELF.HospCount:=Cnt;
    SELF.HospitalList:=L.HospitalList+ R ;
    SELF:=L;
END;

JoinHosp:=DENORMALIZE(MainParent,$.BWR_CleanHospitals.HospitalDS,
                     LEFT.county_fips=RIGHT.PrimaryFIPS AND 
                     STD.STR.Cleanspaces(STD.STR.TOUPPERCASE(LEFT.CITY))=STD.STR.Cleanspaces(RIGHT.CITY),
                     MoveChild(LEFT,RIGHT,COUNTER));
// OUTPUT(JOINHOSP);
EXPORT JoinPolice:=DENORMALIZE(JoinHosp,$.CleanPolicest.CleanPoliceDs,
                         LEFT.county_fips=RIGHT.PrimaryFIPS AND 
                     STD.STR.Cleanspaces(STD.STR.TOUPPERCASE(LEFT.CITY))=STD.STR.Cleanspaces(RIGHT.CITY),
                     TRANSFORM(Mainrec,
                     SELF.PoliceCount:=COUNTER,
                     SELF.POliceList:=LEFT.POliceList+RIGHT;
                     SELF:=LEFT
                     ));

// OUTPUT(JoinPOlice);

EXPORT JoinFireStns:=DENORMALIZE(JoinPolice,$.CleanFireStns.CleanFireStns,
                         LEFT.county_fips=RIGHT.PrimaryFIPS AND 
                     STD.STR.Cleanspaces(STD.STR.TOUPPERCASE(LEFT.CITY))=STD.STR.Cleanspaces(RIGHT.CITY),
                     TRANSFORM(Mainrec,
                     SELF.FireStationCount:=COUNTER,
                     SELF.FireStationList:=LEFT.FireStationList+RIGHT,
                     SELF:=LEFT
                     ));
// OUTPUT(JOINFirestns);

EXPORT JoinChurches:=DENORMALIZE(JoinFirestns,$.CleanChurches.CLeanChurchesDs,
                         LEFT.county_fips=RIGHT.PrimaryFIPS AND 
                     STD.STR.Cleanspaces(STD.STR.TOUPPERCASE(LEFT.CITY))=STD.STR.Cleanspaces(RIGHT.CITY),
                     TRANSFORM(Mainrec,
                     SELF.ChurchesCnt:=COUNTER,
                     SELF.ChurchList:=LEFT.ChurchList+RIGHT,
                     SELF:=LEFT
                     ));
EXPORT JoinFoodBank:=DENORMALIZE(JoinChurches,$.CleanFoodBanks.CleanFoodBanksDs,
                         LEFT.county_fips=RIGHT.PrimaryFIPS AND 
                     STD.STR.Cleanspaces(STD.STR.TOUPPERCASE(LEFT.CITY))=STD.STR.Cleanspaces(RIGHT.CITY),
                     TRANSFORM(Mainrec,
                     SELF.FoodBanksCount:=COUNTER,
                     SELF.FoodBankList:=LEFT.FoodBankList+RIGHT ,
                     SELF:=LEFT
                     ));
// output(JoinFoodBank(foodbankscount<>0),,'~SAFE::DWC::OUT::JFB');
EXPORT WriteBaseData:=output(JoinFoodBank,,'~SAFE::DWC::OUT::JoinALL',OVERWRITE);

EXPORT BASEDATA:=DATASET('~SAFE::DWC::OUT::JoinALL',MainRec,THOR);
EXPORT BASEDATAF:=DATASET('~SAFE::DWC::OUT::JoinALL',{MainRec,UNSIGNED8 RecPos {VIRTUAL(FilePosition)}},THOR);

// JoinonlyFoodBank:=DENORMALIZE(MainParent,$.CleanFoodBanks.CleanFoodBanksDs,
//                          LEFT.county_fips=RIGHT.PrimaryFIPS AND 
//                      STD.STR.Cleanspaces(STD.STR.TOUPPERCASE(LEFT.CITY))=STD.STR.Cleanspaces(RIGHT.CITY),
//                      TRANSFORM(Mainrec,
//                      SELF.FoodBanksCount:=COUNTER,
//                      SELF.FoodBankList:=LEFT.FoodBankList+RIGHT,
//                      SELF:=LEFT
//                      ));
// output(JOinonlyFoodBank);
// output(JOinonlyFoodBank(foodbankscount<>0));


END;