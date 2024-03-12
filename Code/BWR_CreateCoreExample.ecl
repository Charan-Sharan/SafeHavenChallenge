// Let's create a core "risk" file that the county code (FIPS) and the primary city.
// We can extra ct this data from the Cities file.
// #OPTION('obfuscateOutput',TRUE);
IMPORT $,STD;
EXPORT BWR_CreateCoreExample:=MODULE 

SHARED CityDS := $.File_AllData.City_DS;
SHARED Crime  := $.File_AllData.CrimeDS;
SHARED Unemp  := $.File_AllData.unemp_byCountyDS;
SHARED pop    := $.File_AllData.pop_estimatesDS;
SHARED pov    := $.File_AllData.pov_estimatesDS;
SHARED Education := $.File_AllData.EducationDS;

//CityDS(county_fips = 5035); Test to verify data accuracy for the crime score


// Declare our core RECORD:
EXPORT RiskRec := RECORD
    STRING45  city;
    STRING2   state_id;
    STRING20  state_name;
    UNSIGNED3 county_fips;
    STRING30  county_name;
END;


SHARED BaseInfo := PROJECT(CityDS,RiskRec);
// OUTPUT(BaseInfo,NAMED('BaseData'));

EXPORT RiskPlusRec := RECORD
 BaseInfo;
 Decimal5_2 EducationScore  := 0;
 Decimal5_2 PovertyScore    := 0;
 Unsigned4 PopulationScore := 0;
 Unsigned4 CrimeScore      := 0;
 Decimal5_2 Total           := 0;
END; 
 
EXPORT RiskTbl := TABLE(BaseInfo,RiskPlusRec);
// OUTPUT(RiskTbl,NAMED('BuildTable'));
// output(count(risktbl),named('buildcnt'));
//Let's add a Crime Score!

EXPORT CrimeRec := RECORD
CrimeRate := TRUNCATE((INTEGER)Crime.crime_rate_per_100000);
Crime.fips_st;
fips_cty := (INTEGER)Crime.fips_cty;
Fips := Crime.fips_st + INTFORMAT(Crime.fips_cty,3,1);
END;

EXPORT CrimeTbl := TABLE(Crime,CrimeRec);
// OUTPUT(CrimeTbl,NAMED('BuildCrimeTable'));

EXPORT JoinCrime := JOIN(CrimeTbl,RiskTbl,
                  LEFT.fips = (STRING5)RIGHT.county_fips,
                  TRANSFORM(RiskPlusRec,
                            SELF.CrimeScore := LEFT.crimerate,
                            SELF            := RIGHT),
                            RIGHT OUTER);
                            
// OUTPUT(SORT(JoinCrime,-CrimeScore),NAMED('AddedCrimeScore')); 

// output(COUNT(JoinCrime),named('crime'));

PovRec:=RECORD
    UNSIGNED3 PrimaryFips;
    decimal5_2 Pov_rate:=0;
END;

PovTab:=PROJECT(pov(STD.str.CleanSpaces(attribute)='PCTPOVALL_2021'),TRANSFORM(povRec,
                                                           SELF.PrimaryFIPS:=(UNSIGNED3)LEFT.fips_code,
                                                           SELF.pov_rate:=LEFT.value));

JOINpov := JOIN(PovTab,JOINCrime,
                LEFT.PrimaryFIPS=RIGHT.county_fips,TRANSFORM(RiskPlusRec,
                SELF.PovertyScore:=LEFT.Pov_rate,
                SELF := RIGHT;
                ),RIGHT OUTER);   
// output(SORT(JOinpov,-CrimeScore),Named('addedPovRate'));        

// output(COUNT(Joinpov),named('pov'));
popRec:=RECORD
    UNSIGNED3 Primaryfips;
    UNSIGNED4 popCount;
    STRING2 state;
    UNSIGNED4 popscore;
END;
// output(SORT(pop(STD.Str.CleanSpaces(attribute)='POP_ESTIMATE_2021'),value));
popTab:=PROJECT(pop(STD.Str.CleanSpaces(attribute)='POP_ESTIMATE_2021'),TRANSFORM(popRec,
                                        SELF.Primaryfips:=LEFT.fips_code,
                                        SELF.popCount:=LEFT.value,
                                        SELF.state:=LEFT.state,
                                        SELF.popscore:=0));
popscore:=PROJECT(sort(popTab,popcount),TRANSFORM(popRec,
                                        SELF.popscore:=COUNTER,
                                        SELF:=LEFT));
joinpop:=JOIN(popscore,JoinPov, 
                LEFT.PrimaryFIPS=RIGHT.county_fips,TRANSFORM(RiskPlusRec,
                SELF.PopulationScore:=LEFT.popscore,
                SELF := RIGHT;
                ),RIGHT OUTER);  
// output(joinpop,named('joinedpop'));
// output(COUNT(Joinpop),named('pop'));

edcRec:=RECORD
    UNSIGNED3 PrimaryFips;
    STRING2 state;
    DECIMAL5_2 eduscore:=0;
END;


eduTab:=PROJECT(education(STD.Str.CleanSpaces(attribute)='Percent of adults with less than a high school diploma, 2017-21'),TRANSFORM(edcREC,
                                              SELF.PrimaryFips:=LEFT.fips_code,
                                              SELF.state:=LEFT.state,
                                              SELF.eduscore:=LEFT.value;
                                              ));
JOinEDU:=JOIN(eduTab,joinpop,
                LEFT.PrimaryFIPS=RIGHT.county_fips,TRANSFORM(RiskPlusRec,
                SELF.EducationScore:=LEFT.eduscore,
                SELF := RIGHT;
                ),RIGHT OUTER);   
EXPORT createDS:=OUTPUT(JoinEDU,,'~SAFE::DWC::OUT::SocialFact',OVERWRITE);

EXPORT FinalDs:=DATASET('~SAFE::DWC::OUT::SocialFact',RiskPlusRec,THOR);
END; 
  
// output(cleanedu);
// output(COUNT(Cleanedu));      
//Now go out and get the others! Good like with your challenge! 
// After you complete the other scores, make sure to OUTPUT to a file and then create a DATASET so
//that you can reference and deliver it to the judges.                           



