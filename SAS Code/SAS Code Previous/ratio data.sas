

data one(drop=i j) two(drop=i j);
 do i =1 to 1000;
  do j=1 to 2;
  x=normal(100);
  if j=1 then output one;
  else output two;
  end;
  end;
  run;



%macro ratio_data(indata1=one, indata2=two, var1=x, var2=x, nratio=1);
proc sql;
title ’Table One and Table Two’;
create table temp as
select (&indata1..&var1/&indata2..&var2)>&nratio as ratio_&var1._&var2._&nratio.X
from &indata1, &indata2;
run;

proc freq data=temp;
table ratio_&var1._&var2._&nratio.X;
run;
%mend;

%ratio_data(indata1=one, indata2=two, var1=x, var2=x, nratio=1);
%ratio_data(indata1=one, indata2=two, var1=x, var2=x, nratio=2);
%ratio_data(indata1=one, indata2=two, var1=x, var2=x, nratio=3);
