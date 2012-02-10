function [ap,wr,sil,n,eg] = parsemopts(opts)
	% [append, write, silent, n , eg] = PARSEMOPTS(opts)
	% Returns which options were given in the opts char string.
	% This is used in several of the mattex ;

	% set default values
	ap = 1;
	wr = 0;
	sil = 0;
	n  = 2;
	eg = 0;


	if strcmp(class(opts),'double')
		% if only a number was given this must be n.
		n = opts;
	elseif strcmp(class(opts),'char')

		w = strfind(opts,'w');	% write  ?
		a = strfind(opts,'a');	% append ?
		s = strfind(opts,'s');	% silent ?
		e = strfind(opts,'e');	% scientific ?

		% error if both write and append are given, default append if nothing is given
		if ( (numel(a) > 0) && ( numel(w) > 0 ) )
			error('both the append and write options were given, this is contradictory');
		elseif (numel(a) == 0) && ( numel(w) == 0 )
			append = 1;
			write = 0;
		end

		% write
		if numel(w) > 0
			ap = 0;
			wr = 1;
			opts(w) = ' ';
		end

		% append
		if numel(a) > 0
			ap = 1;
			wr = 0;
			opts(a) = ' ';
		end

		% silent
		if numel(s) > 0 
			sil = 1;
			opts(s) = ' ';
		else
			sil = 0;
		end

		% scientific
		if numel(e) > 0 
			eg = 1;
			opts(e)=' ';
		else
			eg = 0;
		end

		% find numerical characters in string
		id = regexp(opts,'\d');

		if length(id) == 0
			n = 2;
		else
			% check if there is a gap in id (this would be bad, two numbers are given)
			bad = 0;
			for i = id(1):id(end)
				if sum(i==id) == 0
					bad = bad + 1;
				end
			end
			if bad > 0
				error(['there are multiple numbers given in the options string, I expected'...
						' only one.']);
			else
				numstr = opts(id);
				n = str2num(numstr);
				opts(id) = '';
			end
		end

		opts(strfind(opts,' '))=''; % clear remaining whitespace

		% are any unknown options given?
		if numel(opts)>0
			error(['unknown option: ' opts]);
		end
	end

	% check if value of n is erranous
	if n < 1
		error([ 'n must be absolutely positive (n>0). ' ...
			   'You cannot have 0 or less significant digits.']);
	end
end
