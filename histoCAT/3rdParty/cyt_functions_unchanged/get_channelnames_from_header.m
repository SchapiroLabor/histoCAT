function channel_names=get_channelnames_from_header(fcshdr)
% GET_CHANNELNAMES_FROM_HEADER Get the channel names from header
%
% This function is from CYT (Dana Pe'er Lab)
% https://www.c2b2.columbia.edu/danapeerlab/html/cyt-download.html
%
% Input: fcshdr --> header output from fca_fcsread
%
% Output: channel_names --> channel names
%
% Histology Topography Cytometry Analysis Toolbox (histoCAT)
% Denis Schapiro - Bodenmiller Group - UZH


    channel_names1 = {fcshdr.par.name};
    channel_names2 = {fcshdr.par.name2};
	if (strcmp(channel_names1,channel_names2)==0)
        channel_names = combineNames(channel_names1,channel_names2);
    else
        channel_names=channel_names2; %channel_names2
	end
end
