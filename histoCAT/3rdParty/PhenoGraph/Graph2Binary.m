function Graph2Binary( G, filename )


    
	% Write to binary file
    G = tril(G);
    t = tic;
    fprintf(1,'Writing graph to .bin file\n');
    textname = [filename '.bin'];
    out = fopen( textname, 'w+' );
    f = find( G > 0 );
    [i,j] = ind2sub( size(G), f );
    srctarget = uint32([i-1 j-1]);
    weights = G(f);
    pctdone = 10;
    tick = round(length(i)/10);
    fprintf(1,'Percent done: ');
    for idx = 1:length(srctarget)
        fwrite(out,srctarget(idx,:),'uint32');
        fwrite(out,full(weights(idx)),'double');
        if ~mod(idx,tick) && idx>1
            fprintf(1,'%i ',pctdone);
            pctdone = pctdone + 10;
        end
    end
    fprintf(1,'\n');
    fprintf(1,'Finished writing .bin file in %.2f s\n', toc(t));
    fclose(out);