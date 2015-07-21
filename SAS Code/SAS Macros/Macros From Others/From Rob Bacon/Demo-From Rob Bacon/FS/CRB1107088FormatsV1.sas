******************STEP 1- FORMATTING**************************************************;
*This code has the formats for 'SORTVAR' (sort variables), 'CLASSVAR' (Class variables) and 'VAR' defined in Global macro variables ;

proc format; 		

**********************************************************************************************************************************;
*  List here all the formats for SORT VARIABLES. Name of the formats should be same as the variables name in the initial dataset;
  
value Pair
	1='1'
	2='2';
value $Gender                     
		'F' = 'Female'
		'M' = 'Male  '
		;

value TrtGroup
		1 = '1'
		2 = '2'
		;

value $Measure
		'ASFSTOTAL'     		= 'Total ASFS'
		'DIFFASFSTOTAL'			= 'Change from Baseline ASFS'
		'ASFSSIDETOTAL'			= 'Total Asfs'

		'AQUATEWL'				= 'Aquaflux Tewl'
		'VAPOTEWL'				= 'Vapometer Tewl'
		'MOISTUREMETER'			= 'Dermalab Moisturemeter'
		'SCALPSENSE'			= 'Scalp Sense'
		'LOGVAPOTEWL'			= 'Log Vapometer TEWL'
		
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
		'LOGKERATINS11011'		= 'Log Keratin'
		'LOGKERATINS11011NRM'	= 'Log Keratin Protein Normalized'
		'LOGMALASSEZIA'			= 'Log Malassezia'
		'LOGADJDNACOPIES'		= 'Log Qpcr Counts'
		'LOGPROTEINCYTOKINE'	= 'Log Cytokine Protein'
		'LOGPROTEINSKINMAP'		= 'Log SkinMap Protein'
		'LOGHISTAMINENRM'		= 'Log Histamine Protein Normalized'
		'LOGHISTAMINE'			= 'Log Histamine'
		'LOGPROTEINHISTAMINE'	= 'Log Histamine Protein'
		'LOGCISACID'			= 'Log Cis Isomer of Urocanic Acid'
		'LOGCISACIDNRM'			= 'Log Cis isomer of Urocanic Acid'
		'LOGHISTIDINE'			= 'Log Histidine'
		'LOGHISTIDINENRM'		= 'Log Histidine Protein Normalized'
		'LOGPROLINE'			= 'Log Proline'
		'LOGPROLINENRM'			= 'Log Proline Normalized'
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
		'RATSHAMPSCALPHLTH'		= 'Rate the shampoo for improvement in scalp health'
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
		;

value StudyDay   				 
		1   = 'Baseline'
		8   = 'Week 1'
		15  = 'Week 2'
		22  = 'Week 3'
		;

value $Depth
		'01' = 'Tape 1'
		'02' = 'Tape 2'
		'05' = 'Tape 5'
		'10' = 'Tape 10'
		;

value $Population
		'Dandruff'     = 'Dandruff'
		'Non Dandruff' = 'Non Dandruff'
		;
	
	
**********************************************************************************************************************************;
* Two types of formats may be required while creating the PVALUE report. Name of the format should be equal to the name of class variable in Initial dataset
  for the second format the name of the class variable should be have 's' as suffix;
   

value $trtnum              /* Format of CLASS VARIABLE used in graph macro*/
		'1' = '[A] No Tonic'	
		'2' = '[B] BC10 Tonic'
		'3' = '[C] ' 
		'4' = '[D] '
		;


value $trt              /* Format of CLASS VARIABLE used in GROUPING and PVLAUE report*/
		'A' = '[A] No Tonic'	
		'B' = '[B] BC10 Tonic'
		'C' = '[C]' 
		'D' = '[D]'
		'E' = '[E]'
		'F' = '[F]'
		'G' = '[G]'
		'H' = '[H]'
		'I' = '[I]'
		'J' = '[J]'
		'K' = '[K]'
		;
   
value $trts             /*This is required for Formatting the Class Variable Across in PVALUE Report Generation*/
		'A' = '[A] No Tonic'	
		'B' = '[B] BC10 Tonic'
		'C' = '[C]' 
		'D' = '[D]'
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

		'AQUATEWL'				= 'Aquaflux Tewl'
		'VAPOTEWL'				= 'Vapometer Tewl'
		'MOISTUREMETER'			= 'Dermalab Moisturemeter'
		'SCALPSENSE'			= 'Scalp Sense'
		'LOGVAPOTEWL'			= 'Log Vapometer TEWL'
		
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
		'LOGKERATINS11011'		= 'Log Keratin'
		'LOGKERATINS11011NRM'	= 'Log Keratin Protein Normalized'
		'LOGMALASSEZIA'			= 'Log Malassezia'
		'LOGADJDNACOPIES'		= 'Log Qpcr Counts'
		'LOGPROTEINCYTOKINE'	= 'Log Cytokine Protein'
		'LOGPROTEINSKINMAP'		= 'Log SkinMap Protein'
		'LOGHISTAMINENRM'		= 'Log Histamine Protein Normalized'
		'LOGHISTAMINE'			= 'Log Histamine'
		'LOGPROTEINHISTAMINE'	= 'Log Histamine Protein'
		'LOGCISACID'			= 'Log Cis Isomer of Urocanic Acid'
		'LOGCISACIDNRM'			= 'Log Cis isomer of Urocanic Acid'
		'LOGHISTIDINE'			= 'Log Histidine'
		'LOGHISTIDINENRM'		= 'Log Histidine Protein Normalized'
		'LOGPROLINE'			= 'Log Proline'
		'LOGPROLINENRM'			= 'Log Proline Normalized'
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
		'RATSHAMPSCALPHLTH'		= 'Rate the shampoo for improvement in scalp health'
		'RATRLVDANDRUFF'		= 'Rate the shampoo for relieving dandruff symptoms'
		'RATRLVSCALPFLAKE'		= 'Rate the shampoo for relieving scalp flaking'
		'RATRLVSCALPITCH'		= 'Rate the shampoo for relieving scalp itch'
		'RATRLVSCALPDRY'		= 'Rate the shampoo for relieving scalp dryness'
		;
run;


