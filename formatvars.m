function [A,s_A] = formatvars(a, s, varargin)
	% [A,s_A] = FORMATVARS(a,s_a,opts) 
	% assigns formatted strings to A and s_A that comply to the requirements of 
	% physics reports eg.
	% 	- order of magnitude for the last two digits of A equal the order of magnitude of s_A
	% 	- scientific notation
	% the optional parameter n tells matlab how many significant digits the error s_A should
	% have. The default is 2. eg.
	%
	%     [A,s_A] = formatvars(123.456,3.567)
	%
	% results in: A = 123.4; s_A = 3.6; where A and s_A are both stings (not numbers!).
	%
	% The optional opts argument is a char string that contains on or more of the following
	% options (in random order):
	%	
	% 	e:  if the 'e' option is given, formatvars will always use scientific notation,
	% 	    even when it normally wouldn't. The standard behaviour is that numbers of
	%	    order -1, 0 or 1 (eg. 0.1, 1 and 10) would not be written in scientific notation.
	%	    This can be turned of using the 'e' option.
	%	#:  This can be any number greater than or equal to 1. It denotes the number of
	%	    significant digits that formatvars will output (on the error value). For abvious
	%	    reasons this must be greater than or equal to 1. If only this options need be given
	%	    you can also pass it as a double (in stead of char string).
	% 
	% eg, one would give an options string 'e3' to use 3 significant digits and make sure that
	% scientific notation is always used.
	% 
	% Known problems: if the number of significant digits you are trying to use is much larger
	% (2 or more larger) this will result in rounding errors. This shouldn't be a problem,
	% since this should never be the case in normal use.

	% parse options
	l = length(varargin);
	switch l
		case 0
			% no options given
			n = 2;
			e_given = 0;
		case 1
			opts=varargin{1};
			[append, write, silent, n, e_given] = parsemopts(opts);

			% issue warning if unused option silent is given
			if silent
				warning('the silent option doesn''t apply here')
			end

			% issue warning if unused option write is given
			if write
				warning('the write option doesn''t apply here')
			end

			% issue warning if unused option append is given
			if strcmp(class(opts),'char')
				 if size(strfind(opts,'a'))>0
					 warning('the append option doesn''t apply here')
				 end
			end

		otherwise
			error('too many options strings were given.');
	end


	% order of magnitude of a must be greater than s
	if abs(a/s) < 1
		disp('order of magnitude of s_a cannot bigger than that of a');
	end

	% FORMAT S
	m = floor(log10(abs(s)));	% get the magnitude of the first significant digit of s

	s_r  = s/(10^m);			% scale s to magnitude 1

	RS = 10^(n-1);				% round s_r to n significant digits
	s_rr = round(s_r*RS)/RS;

	% check if second significant digit of s is a zero
	s_2 = s_rr - round(s_r*RS/10)/RS;
	n_2 = floor(log10(abs(s_2)));
	if n_2 < -1 
		% it is a zero
		zerostr = '0';
		dotstr  = '.';
	else
		% it isn't a zero
		zerostr = '';
		dotstr  = '';
	end;
		
	% FORMAT A
	RA = 10 ^ (-m+n);			% round a to the same order of magnitude as s_a
	a_r = round(a*RA)/RA;

	% special cases when magn(s_a) is equal to that of 10, 1 or 0.1
	normal = 0;
	switch m
	      case -1
	  	    % 0.1
	  	    A   = [num2str(a_r, ['%20.' num2str(n) 'f'])];
	  	    s_A = [num2str(s_rr*10^m,['%#100.' num2str(n) 'g'])  ];
	
	      case 0
	  	    % 1
	  	    A   = [num2str(a_r,['%20.' num2str(n-1) 'f'])];
	  	    s_A = [num2str(s_rr*10^m,['%#100.' num2str(n) 'g'])  ];

	      case 1
	  	    % 10
	  	    A   = [num2str(a_r,['%20.' num2str(n-2) 'f'])];
	  	    s_A = [num2str(s_rr*10^m,['%#100.' num2str(n) 'g'])  ];
	  	    
	
	      otherwise
	  	    normal=1;		
	end

	% use normal (scientific) behaviour
	if normal || e_given
		A   = [num2str(a_r/(10^m),['%20.' num2str(n-1) 'f']) 'e' num2str(m)];
		s_A = [num2str(s_rr, ['%20.' num2str(n-1) 'f']) zerostr 'e' num2str(m)];
	end

	% remove trailing dots
	if (s_A(end) == '.')
		s_A = s_A(1:end-1);
	end

end

