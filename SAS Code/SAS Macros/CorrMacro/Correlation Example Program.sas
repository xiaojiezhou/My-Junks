/*  This program demonstrate how the corr.sas macro can be called  */
*  The macro takes two dataset: 
*           indata:  takes that are to be used for corr;
*        GenVarGrp:  Variable names should be exactly as shown in the example dataset; 




options nofmterr;
libname in "Q:\clinical\Biometrics\XiaojieZhou\SAS_R Code\SAS Code\SAS Macros\CorrMacro";
%include "Q:\clinical\Biometrics\XiaojieZhou\SAS_R Code\SAS Code\SAS Macros\CorrMacro\CorrMacro23Apr2013.sas";

data baseline;
 set in.baseline;
 run;

data GenVarGrp;
 set in.GenVarGrp;
 run;

%CorrMacro(indata=baseline,
          VarGrpData=GenVarGrp,
          Method=pearson,
          corcutoff=0.5 0.6,
          Outfile=Q:\clinical\Biometrics\XiaojieZhou\SAS_R Code\SAS Code\SAS Macros\CorrMacro\Corr Out.xml
);
