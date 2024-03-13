// #OPTION('obfuscateOutput',TRUE);
IMPORT $,STD;
EXPORT CleanHospitals:=MODULE
SHARED Hospitals:=$.File_AllData.HospitalDS;



SHARED FORMATCITY:=$.FORMATWORDS.FORMATCITY_V1;


EXPORT HospRec:=RECORD
    STRING91 NAME;
    STRING76 STREET;
    STRING33 CITY;
    STRING2 STATE;
    UNSIGNED3 ZIP;
    UNSIGNED3 PRIMARYFIPS;
    STRING14 TELEPHONE;
    // STRING6 STATUS;
    // STRING206 WEBSITE;
END;

EXPORT CleanHosp:=PROJECT(Hospitals,TRANSFORM(HospRec,
                                      SELF.NAME:=STD.Str.ToUpperCase(STD.STR.CleanSpaces(LEFT.NAME)),
                                      SELF.STREET:=STD.Str.ToUpperCase(STD.STR.CleanSpaces(LEFT.address)),
                                      SELF.ZIP:=(UNSIGNED3)LEFT.ZIP,
                                      SELF.CITY:=FORMATCITY(LEFT.CITY),
                                      SELF.STATE:=STD.Str.ToUpperCase(STD.STR.CleanSpaces(LEFT.STATE)),
                                      SELF.PrimaryFIPS:=(UNSIGNED3)LEFT.countyfips,
                                      SELF.TELEPHONE:=STD.Str.ToUpperCase(STD.STR.CleanSpaces(LEFT.TELEPHONE)),
                                    //   SELF.WEBSITE:=(STD.STR.CleanSpaces(LEFT.WEBSITE)),
                                    //   SELF.STATUS:=STD.Str.ToUpperCase(STD.STR.CleanSpaces(LEFT.status))
                                      ));
EXPORT WriteHosp:=OUTPUT(CleanHosp,,'~SAFE::DWC::OUT::HOSPITALS',OVERWRITE);
EXPORT HospitalDS:=DATASET('~SAFE::DWC::OUT::HOSPITALS',HospRec,THOR);

END;