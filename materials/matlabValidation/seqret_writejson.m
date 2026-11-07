function seqret_writejson(file, S)
fid = fopen(file, 'w'); fwrite(fid, jsonencode(S), 'char'); fclose(fid);
end
