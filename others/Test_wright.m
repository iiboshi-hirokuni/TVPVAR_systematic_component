fileID = fopen('result.txt','w');
   
fprintf(fileID,'\n\n                        [ESTIMATION RESULT]');
fprintf(fileID,'\n----------------------------------');
fprintf(fileID,'------------------------------------');
fprintf(fileID,'\nParameter   Mean      Stdev       ');
fprintf(fileID,'95%%U       95%%L    Geweke     Inef.');
fprintf(fileID,'\n----------------------------------');
fprintf(fileID,'------------------------------------\n');

fclose(fileID);