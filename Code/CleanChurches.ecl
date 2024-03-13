// #OPTION('obfuscateOutput',TRUE);
IMPORT $,STD;
EXPORT CLeanChurches:=MODULE
//This file is used to demonstrate how to "clean" a raw dataset (Churches) and create an index to be used in a ROXIE service
SHARED Churches := $.File_AllData.ChurchDS;
SHARED Cities   := $.BaseCityInfo.BaseInfo;

SHARED FORMATCITY:=$.FORMATWORDS.FORMATCITY_V1;


//First, determine what fields you want to clean:
EXPORT CleanChurchRec := RECORD
    STRING70  name;
    STRING35  street;
    STRING22  city;
    STRING2   state;
    UNSIGNED3 zip;
    UNSIGNED1 affiliation; 
    UNSIGNED3 PrimaryFIPS; //New - will be added from Cities DS
END;
//PROJECT is used to transform one data record to another.
SHARED CleanChurch := PROJECT(Churches,TRANSFORM(CleanChurchRec,
                                          SELF.name                := STD.STR.ToUpperCase(LEFT.name),
                                          SELF.street              := STD.STR.ToUpperCase(LEFT.street),
                                          SELF.CITY:=FORMATCITY(LEFT.CITY),
                                          SELF.State               := STD.STR.ToUpperCase(LEFT.state),
                                          SELF.zip                 := LEFT.zip,
                                          SELF.affiliation         := LEFT.affiliation,
                                          SELF.PrimaryFIPS         := 0));
//JOIN is used to combine data from different datasets 
SHARED CleanChurchFIPS :=       JOIN(CleanChurch,Cities,
                           LEFT.city  = STD.STR.ToUpperCase(RIGHT.city) AND
                           LEFT.state = RIGHT.state_id,
                           TRANSFORM(CleanChurchRec,
                                     SELF.PrimaryFIPS := (UNSIGNED3)RIGHT.county_fips,
                                     SELF             := LEFT),LEFT OUTER,LOOKUP);
//Write out the new file and then define it using DATASET
EXPORT WriteChurches      := OUTPUT(CleanChurchFIPS,,'~SAFE::DWC::OUT::Churches',OVERWRITE);                                        
EXPORT CleanChurchesDS    := DATASET('~SAFE::DWC::OUT::Churches',CleanChurchRec,FLAT);

//Declare and Build Indexes (special datasets that can be used in the ROXIE data delivery cluster
CleanChurchIDX     := INDEX(CleanChurchesDS,{city,state},{CleanChurchesDS},'~SAFE::IDX::Church::CityPay');
CleanChurchFIPSIDX := INDEX(CleanChurchesDS,{PrimaryFIPS},{CleanChurchesDS},'~SAFE::IDX::Church::FIPSPay');
BuildChurchIDX     := BUILD(CleanChurchIDX,OVERWRITE);
BuildChurchFIPSIDX := BUILD(CleanChurchFIPSIDX,OVERWRITE);

//SEQUENTIAL is similar to OUTPUT, but executes the actions in sequence instead of the default parallel actions of the HPCC
// SEQUENTIAL(WriteChurches,BuildChurchIDX,BuildChurchFIPSIDX);


END;