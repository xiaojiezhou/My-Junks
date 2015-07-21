******************STEP 1- FORMATTING**************************************************;
*This code has the formats for 'SORTVAR' (sort variables), 'CLASSVAR' (Class variables) and 'VAR' defined in Global macro variables ;

proc format; 		

**********************************************************************************************************************************;
*  List here all the formats for SORT VARIABLES. Name of the formats should be same as the variables name in the initial dataset;
  
value $Gender                     
		'F' = 'Female'
		'M' = 'Male  '
		;

value Group
		1 = '1'
		2 = '2'
		;

value $Measure
		'ASFSTOTAL'     		= 'Total ASFS'
		'DIFFASFSTOTAL'			= 'Change from Baseline ASFS'
		'ASFSSIDETOTAL'			= 'Total Asfs'
		
		'LOGHSA'				= 'Log Hsa'
		'LOGHSANRM'				= 'Log Hsa Protein Normalized'
		'LOGIL1A'				= 'Log IL1a'
		'LOGIL1ANRM'			= 'Log IL1a Protein Normalized'
		'LOGIL1RA'				= 'Log IL1ra'
		'LOGIL1RAIL1ARATIO'		= 'Log IL1ra:IL1a Ratio'
		'LOGIL1RANRM'			= 'Log IL1ra Protein Normalized'
		'LOGIL8'				= 'Log IL8'
		'LOGIL8NRM'				= 'Log IL8 Protein Normalized'
		'LOGINVOLUCRIN'			= 'Log Involucrin'
		'LOGINVOLUCRINNRM'		= 'Log Involucrin Protein Normalized'
		'LOGKERATINS11011'		= 'Log Kertain'
		'LOGKERATINS11011NRM'	= 'Log Kertain Protein Normalized'
		'LOGMALASSEZIA'			= 'Log Malassezia'
		'LOGPROTEINCYTOKINE'	= 'Log Cytokine Protein'
		'LOGPROTEINSKINMAP'		= 'Log SkinMap Protein'
		'LOGHISTAMINENRM'		= 'Log Histamine Protein Normalized Avg Tape 1 & 2'
		'LOGHISTAMINE'			= 'Log Histamine Avg Tape 1 & 2'
		'LOGPROTEINHISTAMINE'	= 'Log Histamine Protein Avg Tape 1 & 2'
		'LOGCISACID'			= 'Log Cis Isomer of Urocanic Acid'
		'LOGCISACIDNRM'			= 'Log Cis Isomer of Urocanic Acid Protein Normalized'
		'LOGHISTIDINE'			= 'Log Histidine'
		'LOGHISTIDINENRM'		= 'Log Histidine Protein Normalized'
		'LOGPROLINE'			= 'Log Proline'
		'LOGPROLINENRM'			= 'Log Proline Protein Normalized'
		'LOGPROTEINNMF'			= 'Log NMF Protein'
		'LOGPYACID'				= 'Log 2 Pyrrolidone 5 Acid'
		'LOGPYACIDNRM'			= 'Log 2 Pyrrolidone 5 Acid Protein Normalized'
		'LOGTRUACID'			= 'Log Trans-Urocanic Acid'
		'LOGTRUACIDNRM'			= 'Log Trans-Urocanic Acid Protein Normalized'

		'SEVDANDRUFF'			= 'Rate the severity your dandruff symptoms over the last 24 hours'
		'SEVSCALPFLAKE'			= 'Rate the severity your scalp flaking over the last 24 hours'
		'SEVSCALPITCH'			= 'Rate the severity your scalp itch over the last 24 hours'
		'SEVSCALPDRY'			= 'Rate the severity your scalp dryness over the last 24 hours'
		'RATSHMPOVERALL'		= 'Rate the shampoo overall'
		'RATSHMPSCALPHLTH'		= 'Rate the shampoo for improvement in scalp health'
		'RATRLVDANDRUFF'		= 'Rate the shampoo for relieving dandruff symptoms'
		'RATRLVSCALPFLAKE'		= 'Rate the shampoo for relieving scalp flaking'
		'RATRLVSCALPITCH'		= 'Rate the shampoo for relieving scalp itch'
		'RATRLVSCALPDRY'		= 'Rate the shampoo for relieving scalp dryness'
		;

value $StudySite
		'Bower'			= 'Bower'
		'CRG'			= 'CRG'
		'ERF'			= 'ERF'
		'Hilltop-Winn'	= 'Hilltop-Winnepeg'
		'NCC-Colrain'	= 'NorthCliff Consultants-Colrain'
		'NCC-Warsaw'	= 'NorthCliff Consultants-Warsaw'
		'RHRC'			= 'RHRC'
		;

value $Race
		'Asian'='Asian'
		'Black'='Black'
		'Hispanic'='Hispanic'
		'Other'='Other'
		'White'='White'
		;

value $OperGrade 	
		'Joelle Potrebka'='Joelle Potrebka'
		'Yu Wei'='Yu Wei'
		'Zhang Hai Yan'='Zhang Hai Yan'
		'Liu Lan'='Liu Lan'
		'Jennifer Davis'='Jennifer Davis'
		'Jennifer Vialpando'='Jennifer Vialpando'
		'Sherry Schmidt'='Sherry Schmidt'
		;

value StudyDay   				 
		1   = 'Baseline'
		7   = 'Week 1'
		14  = 'Week 2'
		21  = 'Week 3'
		;

value $Depth
		'01' = 'Tape 1'
		'02' = 'Tape 2'
		'05' = 'Tape 5'
		'10' = 'Tape 10'
		;
	
	
**********************************************************************************************************************************;
* Two types of formats may be required while creating the PVALUE report. Name of the format should be equal to the name of class variable in Initial dataset
  for the second format the name of the class variable should be have 's' as suffix;
   

value $trtnum              /* Format of CLASS VARIABLE used in graph macro*/
		'1' = '[A] BC-171 Aqua D'	
		'2' = '[B] BC-171 BSOG Wacker'
		'3' = '[C] BC-178' 
		'4' = '[D] IT'
		;

value $trt              /* Format of CLASS VARIABLE used in GROUPING and PVLAUE report*/
		'A' = '[A] BC-171 Aqua D'	
		'B' = '[B] BC-171 BSOG Wacker'
		'C' = '[C] BC-178' 
		'D' = '[D] IT'
		'E' = '[E]'
		'F' = '[F]'
		'G' = '[G]'
		'H' = '[H]'
		'I' = '[I]'
		'J' = '[J]'
		'K' = '[K]'
		;
   
value $trts             /*This is required for Formatting the Class Variable Across in PVALUE Report Generation*/
		'A' = '[A] BC-171 Aqua D'
		'B' = '[B] BC-171 BSOG Wacker'
		'C' = '[C] BC-178'
		'D' = '[D] IT'
		'E' = '[E]'
		'F' = '[F]'
		'G' = '[G]'
		'H' = '[H]'
		'I' = '[I]'
		'J' = '[J]'
		'K' = '[K]'
		;
  
value $var			/* Name of variable defined in VAR global macro variable */
		'ASFSTOTAL'     		= 'Total ASFS'
		'DIFFASFSTOTAL'			= 'Change from Baseline ASFS'
		'ASFSSIDETOTAL'			= 'Total Asfs'
		
		'LOGHSA'				= 'Log Hsa'
		'LOGHSANRM'				= 'Log Hsa Protein Normalized'
		'LOGIL1A'				= 'Log IL1a'
		'LOGIL1ANRM'			= 'Log IL1a Protein Normalized'
		'LOGIL1RA'				= 'Log IL1ra'
		'LOGIL1RAIL1ARATIO'		= 'Log IL1ra:IL1a Ratio'
		'LOGIL1RANRM'			= 'Log IL1ra Protein Normalized'
		'LOGIL8'				= 'Log IL8'
		'LOGIL8NRM'				= 'Log IL8 Protein Normalized'
		'LOGINVOLUCRIN'			= 'Log Involucrin'
		'LOGINVOLUCRINNRM'		= 'Log Involucrin Protein Normalized'
		'LOGKERATINS11011'		= 'Log Kertain'
		'LOGKERATINS11011NRM'	= 'Log Kertain Protein Normalized'
		'LOGMALASSEZIA'			= 'Log Malassezia'
		'LOGPROTEINCYTOKINE'	= 'Log Cytokine Protein'
		'LOGPROTEINSKINMAP'		= 'Log SkinMap Protein'
		'LOGHISTAMINENRM'		= 'Log Histamine Protein Normalized Avg Tape 1 & 2'
		'LOGHISTAMINE'			= 'Log Histamine Avg Tape 1 & 2'
		'LOGPROTEINHISTAMINE'	= 'Log Histamine Protein Avg Tape 1 & 2'
		'LOGCISACID'			= 'Log Cis Isomer of Urocanic Acid'
		'LOGCISACIDNRM'			= 'Log Cis Isomer of Urocanic Acid Protein Normalized'
		'LOGHISTIDINE'			= 'Log Histidine'
		'LOGHISTIDINENRM'		= 'Log Histidine Protein Normalized'
		'LOGPROLINE'			= 'Log Proline'
		'LOGPROLINENRM'			= 'Log Proline Protein Normalized'
		'LOGPROTEINNMF'			= 'Log NMF Protein'
		'LOGPYACID'				= 'Log 2 Pyrrolidone 5 Acid'
		'LOGPYACIDNRM'			= 'Log 2 Pyrrolidone 5 Acid Protein Normalized'
		'LOGTRUACID'			= 'Log Trans-Urocanic Acid'
		'LOGTRUACIDNRM'			= 'Log Trans-Urocanic Acid Protein Normalized'

		'LOGIL1AREP1'			= 'Log IL1a'
		'LOGIL1ANRMREP1'		= 'Log IL1a Protein Normalized'
		'LOGIL1RAREP1'			= 'Log IL1ra'
		'LOGIL1RANRMREP1'		= 'Log IL1ra Protein Normalized'
		'LOGIL1RAIL1ARATIOREP1'	= 'Log IL1ra:IL1a Ratio'
		'LOGHISTAMINENRMREP1'		= 'Log Histamine Protein Normalized	Tape 1'
		'LOGHISTAMINEREP1'			= 'Log Histamine Tape 1'
		'LOGPROTEINHISTAMINEREP1'	= 'Log Histamine Protein Tape 1'
		'LOGHISTAMINENRMREP2'		= 'Log Histamine Protein Normalized	Tape 2'
		'LOGHISTAMINEREP2'			= 'Log Histamine Tape 2'
		'LOGPROTEINHISTAMINEREP2'	= 'Log Histamine Protein Tape 2'
		'LOGPROTEINCYTOKINEREP1'	= 'Log Cytokine Protein'

		'SEVDANDRUFF'			= 'Rate the severity your dandruff symptoms over the last 24 hours'
		'SEVSCALPFLAKE'			= 'Rate the severity your scalp flaking over the last 24 hours'
		'SEVSCALPITCH'			= 'Rate the severity your scalp itch over the last 24 hours'
		'SEVSCALPDRY'			= 'Rate the severity your scalp dryness over the last 24 hours'
		'RATSHMPOVERALL'		= 'Rate the shampoo overall'
		'RATSHMPSCALPHLTH'		= 'Rate the shampoo for improvement in scalp health'
		'RATRLVDANDRUFF'		= 'Rate the shampoo for relieving dandruff symptoms'
		'RATRLVSCALPFLAKE'		= 'Rate the shampoo for relieving scalp flaking'
		'RATRLVSCALPITCH'		= 'Rate the shampoo for relieving scalp itch'
		'RATRLVSCALPDRY'		= 'Rate the shampoo for relieving scalp dryness'
		;
run;

