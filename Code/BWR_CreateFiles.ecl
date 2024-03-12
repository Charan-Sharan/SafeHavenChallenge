#OPTION('obfuscateOutput',TRUE);
import $,STD;

Hospital:=$.BWR_CleanHospitals.WriteHosp;
Hospital;

Churches:=$.CleanChurches.WriteChurches;
Churches;

Police:=$.CleanPolicest.WRITEPolice;
Police;

Fire:=$.CleanFireStns.WriteFire;
Fire;

Food:=$.CleanFoodBanks.writeFOOD;
Food;
createfile:=$.BWR_CreateCoreExample.createDS;
createfile;

BaseFile:=$.BWR_XTAB.WriteBaseData;
BaseFile;