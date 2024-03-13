
IMPORT $,STD;
EXPORT AnalyzeSocialFactors:=MODULE 

SHARED CityDS := $.File_AllData.City_DS;
SHARED Crime  := $.File_AllData.CrimeDS;
SHARED Unemp  := $.File_AllData.unemp_byCountyDS;
SHARED pop    := $.File_AllData.pop_estimatesDS;
SHARED pov    := $.File_AllData.pov_estimatesDS;
SHARED Education := $.File_AllData.EducationDS;


SHARED FORMATCITY:=$.FORMATWORDS.FORMATCITY_V2;


SHARED BAseinfo:= $.BaseCityInfo.BaseInfo;


EXPORT RiskPlusRec := RECORD
 BaseInfo;
 Decimal5_2 EducationScore  := 0;
 Decimal5_2 PovertyScore    := 0;
 Unsigned4 PopulationScore := 0;
 Decimal5_2 UnemploymentScore :=0;
 Unsigned4 CrimeScore      := 0;
 Decimal5_2 RiskFactor           := 0;
END; 
 
EXPORT RiskTbl := TABLE(BaseInfo,RiskPlusRec);

//JOin crime records


EXPORT CrimeRec := RECORD
CrimeRate := TRUNCATE((INTEGER)Crime.crime_rate_per_100000);
Crime.fips_st;
violentCrimeRate:=(((UNSIGNED4)Crime.MURDER+(UNSIGNED4)Crime.AGASSLT+(UNSIGNED4)Crime.ROBBERY+(UNSIGNED4)Crime.RAPE)/(UNSIGNED4)Crime.POPULATION)*100000,
fips_cty := (INTEGER)Crime.fips_cty;
STRING5 Fips := INTFORMAT(Crime.fips_st,2,1) + INTFORMAT(Crime.fips_cty,3,1);
END;

EXPORT CrimeTbl := TABLE(Crime,CrimeRec);
// OUTPUT(CrimeTbl,NAMED('BuildCrimeTable'));

EXPORT JoinCrime := JOIN(CrimeTbl,RiskTbl,
                  LEFT.fips = (STRING5)RIGHT.county_fips ,
                  TRANSFORM(RiskPlusRec,
                            SELF.CrimeScore := LEFT.crimerate,
                            SELF            := RIGHT),
                            RIGHT OUTER);
                            

//join Poverty Records

PovRec:=RECORD
    UNSIGNED3 PrimaryFips;
    STRING35  Area_name;
    decimal5_2 Pov_rate:=0;
END;

PovTab:=PROJECT(pov(STD.str.CleanSpaces(attribute)='PCTPOVALL_2021'),TRANSFORM(povRec,
                                                           SELF.PrimaryFIPS:=(UNSIGNED3)LEFT.fips_code,
                                                           SELF.Area_Name:=FORMATCITY(LEFT.AREA_NAME),
                                                           SELF.pov_rate:=LEFT.value));

EXPORT JOINpov := JOIN(PovTab,JOINCrime,
                LEFT.PrimaryFIPS=RIGHT.county_fips,
                TRANSFORM(RiskPlusRec,
                SELF.PovertyScore:=LEFT.Pov_rate,
                SELF := RIGHT;
                ),RIGHT OUTER);   
// output(SORT(JOinpov,-CrimeScore),Named('addedPovRate'));  

//JOin UNEMPLOYMENT Records

UnempRec:=RECORD
    UNSIGNED3 PrimaryFips;
    STRING35  Area_name;
    decimal5_2 Unemp_rate:=0;
END;

EXPORT UnempTab:=PROJECT(Unemp(STD.str.CleanSpaces(attribute)='Unemployment_rate_2021'),TRANSFORM(UnempRec,
                                                           SELF.PrimaryFIPS:=(UNSIGNED3)LEFT.fips_code,
                                                           SELF.Area_Name:=FORMATCITY(LEFT.AREA_NAME),
                                                           SELF.Unemp_rate:=LEFT.value));

EXPORT JOINUnemp := JOIN(UnempTab,JOINPov,
                LEFT.PrimaryFIPS=RIGHT.county_fips,
                TRANSFORM(RiskPlusRec,
                SELF.UnemploymentScore:=LEFT.Unemp_rate,
                SELF := RIGHT;
                ),RIGHT OUTER); 

// output(COUNT(Joinpov),named('pov'));
SHARED popRec:=RECORD
    UNSIGNED3 Primaryfips;
    UNSIGNED4 popCount;
    STRING2 state;
    STRING50  Area_Name;
    UNSIGNED4 popscore;
END;
// output(SORT(pop(STD.Str.CleanSpaces(attribute)='POP_ESTIMATE_2021'),value));
EXPORT popTab:=PROJECT(pop(STD.Str.CleanSpaces(attribute)='POP_ESTIMATE_2021'),TRANSFORM(popRec,
                                        SELF.Primaryfips:=LEFT.fips_code,
                                        SELF.popCount:=LEFT.value,
                                        SELF.state:=LEFT.state,
                                        SELF.Area_Name:=FORMATCITY(LEFT.AREA_NAME),
                                        SELF.popscore:=0));
EXPORT popscore:=PROJECT(sort(popTab,popcount),TRANSFORM(popRec,
                                        SELF.popscore:=COUNTER,
                                        SELF:=LEFT));
EXPORT joinpop:=JOIN(popscore,JoinUnemp, 
                LEFT.PrimaryFIPS=RIGHT.county_fips ,
                TRANSFORM(RiskPlusRec,
                SELF.PopulationScore:=LEFT.popscore,
                SELF := RIGHT;
                ),RIGHT OUTER);  

//Join Education records

edcRec:=RECORD
    UNSIGNED3 PrimaryFips;
    STRING2 state;
     STRING45  Area_name;
    DECIMAL5_2 eduscore:=0;
   
END;


SHARED eduTab:=PROJECT(education(STD.Str.CleanSpaces(attribute)='Percent of adults with less than a high school diploma, 2017-21'),TRANSFORM(edcREC,
                                              SELF.PrimaryFips:=LEFT.fips_code,
                                              SELF.state:=LEFT.state,
                                              SELF.Area_Name:=FORMATCITY(LEFT.AREA_NAME),
                                              SELF.eduscore:=LEFT.value;
                                              ));
EXPORT JOinEDU:=JOIN(eduTab,joinpop,
                LEFT.PrimaryFIPS=RIGHT.county_fips ,
                TRANSFORM(RiskPlusRec,
                SELF.EducationScore:=LEFT.eduscore,
                SELF := RIGHT;
                ),RIGHT OUTER);   


//Normalize scores to a range of 1 to 100

SHARED NormalizeScore:=PROJECT(JoinEDu,TRANSFORM(RiskPlusRec,
                        SELF.crimescore:=(LEFT.crimeScore/1791)*100,
                        SELF.populationScore:=(LEFT.populationScore/3264)*100,
                        SELF:=LEFT));


//RiskFactor Contrubution by weights

SHARED Decimal2_2 CrimeWt:=0.5;
SHARED Decimal2_2 PovertyWt:=0.2;
SHARED Decimal2_2 educationWt:=0.10;
SHARED Decimal2_2 populationWt:=0.05;
SHARED Decimal2_2 unemploymentWt:=0.15;

//calculate RiskFactor
EXPORT CalcRiskFactor:=PROJECT(NormalizeScore,TRANSFORM(RiskPlusRec,
                    SELF.RiskFactor:=(LEFT.crimeScore*crimeWt+LEFT.PovertyScore*PovertyWt+LEFT.UnemploymentScore*UnemploymentWt+LEFT.EducationScore*educationWt+LEFT.PopulationScore*PopulationWt),
                    SELF:=LEFT));

EXPORT createDS:=OUTPUT(CalcRiskFactor,,'~SAFE::DWC::OUT::SocialFactors',OVERWRITE);
EXPORT SocialFactorDS:=DATASET('~SAFE::DWC::OUT::SocialFactors',RECORDOF(Joinedu),THOR);
END; 
  

