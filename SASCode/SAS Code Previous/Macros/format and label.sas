/****************
%include "Y:\FC_CMK\2009\Web Enabling Node Label and State Name\Program\SpssDataContent.sas";
%include "Y:\FC_CMK\2009\Web Enabling Node Label and State Name\Program\SpssData2CSV.sas";

%SpssDataContent
				( path=Y:\FC_CMK\2009\Web Enabling Node Label and State Name\Data, 
				  dataInFile=AU GM Impact.sav,  
                  resultDirectory=Y:\FC_CMK\2009\Web Enabling Node Label and State Name\Output, 
                  txtFileName1=label_AU GM Impact.txt, txtFileName2=format_AU GM Impact.txt);

%SpssData2CSV
				(path=Y:\FC_CMK\2009\Web Enabling Node Label and State Name\Data, 
				 dataInFile=AU GM Impact.sav, 
				 resultDirectory=Y:\FC_CMK\2009\Web Enabling Node Label and State Name\Output, 
				 CSVFileName=AU GM Impact.csv);


***********/

%include "C:\Documents and Settings\tx3950\Desktop\SAS Code\Macros\SpssDataContent.sas";
%include "C:\Documents and Settings\tx3950\Desktop\SAS Code\Macros\SpssData2CSV.sas";

%SpssDataContent
				( path=C:\Documents and Settings\tx3950\Desktop\CMK\2009\YLoseConsumer\Q1ES\BBN\Data, 
				  dataInFile=ES0709 Tide.sav,  
                  resultDirectory=C:\Documents and Settings\tx3950\Desktop\CMK\2009\YLoseConsumer\Q1ES\BBN\Data, 
                  txtFileName1=label_ES0709Tide.txt, txtFileName2=format_ES0709Tide.txt);

%SpssData2CSV
				(path=C:\Documents and Settings\tx3950\Desktop\CMK\2009\YLoseConsumer\Q1ES\BBN\Data, 
				 dataInFile=ES0709 Tide.sav, 
				 resultDirectory=C:\Documents and Settings\tx3950\Desktop\CMK\2009\YLoseConsumer\Q1ES\BBN\Data, 
				 CSVFileName=data_ES0709Tide.csv);

