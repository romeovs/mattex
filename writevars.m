function writevars(file, varargin)
	% WRITEVARS(file,options,a,b,c,...) writes the variables a, b, c, etc. to the 
	% file specified in file for later use in a LaTeX document.
	% The variable names will be given by their names
	% when passed on to writevars. eg. matlab variable 'a' will be passed as '\a' in the tex file
	%
	% You can  also use WRITEVARS to format variables with their corresponding error to the
	% correct notation for use in physical reports eg.
	%    
	%    A = (101.3 +- 2.4)e4
	%
	% that is: give the error two significant digits and round the variable so that it's
	% last two digits are of the same order of the error.
	%
	% To make use of this put the variable and it's error in a vector with the variables name:
	%
	%	a = [101.299e10,2.423e10];
	%	writevars('file.txt',a);
	%
	% results in the 'file.txt' containing
	%	
	% 	\Mset{a}{101.3}{2.4}{10}
	%
	% Use \input{file} in your tex file to gain acces to the variables, eg. 
	% 
	% 	\input{file.txt}
	% 	value of a is \Mnum{a}.
	%
	% You cannot use temporary variables when using WRITEVARS. This would result in nameless
	% variables in the tex file. So don't do:
	%	
	%	writevars('file.txt', [101.299, 2.423])
	%
	% You can use writevars to append variables to the file using the 'a' (append) option, which
	% is also implied when no option is given. So both
	% 	
	% 	writevars('file.txt', 'a', a, b, c, ... );
	% 
	% and
	%
	%	writevars('file.txt', a, b, c, ...);
	% 
	% will append the the variable definitions to the file. This is the smart thing to do since
	% LaTeX will only use the last of the defined values, and this way you will have a history 
	% of all the values you have written. This behaviour can be turned off by using
	% the 'w' option ('w' for write):
	% 
	% 	writevars('file.txt','w', a, b, c,...);
	%
	% will empty the file before writing to it. This can be a good thing if the file is 
	% becoming overly long, thus slowing tex compilation.
	%
	% The other options that can be given are:
	% 	a:   append (this is default). Latex will use only the last values that were written. 
	% 	w:   write instead of append. This clears the file before writing.
	% 	s:   silent, don't write information to console and refrain from writing a datestring 
	% 		to the file.
	%	e:   passes the 'e' option to formatvars.
	%	#:	replace by any number greater than 0. This tells formatvars which number
	%	     of significant digits to use.
	%
	% you can give these options in random order in the optional options string. eg
	% 
	%    writevars(file,'wse4',a,b,c,...);
	%
	% silently writes the variables to the file with the 'e' option using 4 significant digits.
	%
	% See also WRITEALLVARS, WRITEMAT, FORMATVARS

	appendstr = [ '%%-- ' datestr(now) ' --%%\n'];
	
	% check if any variables were passed at all
	if length(varargin) == 0
		error('no variables were given');
	end
	
	% check if options string was given and if so, parse it using parsemopts.
	switch class(varargin{1})
		case 'char'
			opts=varargin{1};
			[append, write, silent, n, e_given] = parsemopts(opts);
			s = 2;
		case 'double'
			[append, write, silent, n, e_given] = parsemopts('');
			s = 1;
		otherwise
			error('Unexpected class in argument 2')
	end;

	if append
		[FID] = fopen(file,'a');
		if ~silent
			fprintf(FID,appendstr);
			disp(['appending variables to ' file])
		end
	elseif write
		[FID] = fopen(file,'w');
		if ~silent
			fprintf(FID,appendstr);
			disp(['writing variables to ' file])
		end
	end

	if e_given
		e = 'e';
	else
		e = '';
	end

	% loop variables in varargin
	for i = s : length(varargin)

			% get name of variable
			str = inputname(i+1);

			% check if this name is good or empty (temporary variable)
			if length(str) == 0
				error([   'you cannot use temporary variables for they will ' ...
						'have no name on output. \nerror in input argument ' ...
						 num2str(i+1)]);
			end

			if ~strcmp(class(varargin{i}),'double') 
				error(['argument ' num2str(i+1) ' is not of class double']);
			end

		% check if variables is vector or single variables
		if max(size(varargin{i})) == 2
			% vector

			vec = varargin{i};		% get the inputed vector
			a   = vec(1);			% get first value
			s_a = vec(2);			% get second value
			
			[A,s_A] = formatvars(a,s_a,[num2str(n) e]);	% format the variables using formatvar
			eA = strfind(A,'e');
			Aexp = '';
			if size(eA) > 0
				Aexp = A(eA+1:end);
				A = A(1:eA-1);
			end

			es_A = strfind(s_A,'e');
			if size(es_A) > 0
				s_Aexp = s_A(es_A:end);
				s_A = s_A(1:es_A-1);
			end
			% defstr_s_a = [ '\\Mset{s_' str '}{' s_A '}\n' ];
			defstr = [ '\\Mset{' str '}{' A '}{' s_A '}{' Aexp '}\n' ];

		elseif size(varargin{i}) == [1 1]
			% normal

			if e_given
				f=e;	
			else
				f = 'g';
			end
			A = num2str(varargin{i},['%100.' num2str(n) f]);	% get value as string

			A(strfind(A,'+'))='';
			eA = strfind(A,'e');
			if size(eA) > 0
				Aval = A(1:eA-1);
				Aexp = A(eA+1:end);

				% remove 0 in front of exponential
				if Aexp(1) == '0'
					Aexp(1) = '';
				end
				defstr = [ '\\Mset{' str '}{' Aval '}{}{' Aexp '}\n' ];
			else
				defstr = [ '\\Mset{' str '}{' A '}\n' ];
			end
		else
			% unknown	
			error('variable must be of size [1 1] or [1 2]');

		end
		% print the string
		fprintf(FID, defstr);
	end

	% close the file
	fclose(FID);

end
