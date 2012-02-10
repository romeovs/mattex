function writemat(file,varargin)
	% WRITEMAT(file,opts,A,s_A) writes the matrix to mat-tex variables to file.
	% This can be included using in latex using the mat-tex commands.
	% eg. 
	%     A   = [ 1, 2; 3, 4]*1e-9;
	%     s_A = [ 0.1, 0.2; 0.3, 0.4]*1e-9;
	%     writemat('example.txt',A,s_A);
	%
	% will result in a file 'example.txt' that contains
	%     
	%     \Mset{A(1,1)}{1}{0.1}{-9}
	%     \Mset{A(1,2)}{2}{0.2}{-9}
	%     \Mset{A(2,1)}{3}{0.3}{-9}
	%     \Mset{A(2,2)}{4}{0.4}{-9}
	%
	% which can be included in a tex file. Then use 
	%    
	%     \makematrix{A}{2}{2}
	%     \begin{tabular}{MM}
	%         \usematrix
	%     \end{tabular}
	%
	% to typeset the table.
	%
	% The optional options argument can be a char string that contains in random order any
	% of these options:
	%
	% 	a: append, this is default
	% 	w: write to the file in stead of appending to it. This will clear the file.
	% 	s: do not write timestamps into the file and don't be verbose on screen (good when
	%       writing from a loop.
	%    e: always use exponential notation (see formatvars).
	%    #: replace this by any number. It will cause # significant digits to be used instead
	%       of just 2.
	%
	% See also WRITEVARS, FORMATVARS, WRITEALLVARS


	appendstr = [ '%%-- ' datestr(now) ' --%%\n'];

	% check if options were given.
	if strcmp(class(varargin{1}),'char')
		opts=varargin{1};
		[append, write, silent, n, e_given] = parsemopts(opts);
		o = 1; 
	else
		[append, write, silent, n, e_given] = parsemopts('');
		o = 0;
	end

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
	
	if numel(varargin) - o == 2
		a = varargin{1+o};
		s_a = varargin{2+o};
		str = inputname(2+o);

		if size(a)==size(s_a)
			[I,J] = size(a);
			for i = 1:I
				for j = 1:J
					[A,s_A] = formatvars(a(i,j),s_a(i,j),[num2str(n) e]);
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
					posstr = ['(' num2str(i) ',' num2str(j) ')'];
					defstr = [ '\\Mset{' str posstr '}{' A '}{' s_A '}{' Aexp '}\n' ];
					fprintf(FID,defstr);
				end
			end

		else
			error('matrix sizes must coincide');
		end

	elseif numel(varargin) - o == 1
		if n < 1
			error('n cannot be smaller than 1. This would result in no significant digits.');
		end
		str = inputname(2+o);
		a = varargin{1+o};
		[I,J] = size(a);
		for i = 1:I
			for j=1:J
				A = num2str(a(i,j),['%100.' num2str(n) 'g']);	% get value as string
				A(strfind(A,'+'))='';
				eA = strfind(A,'e');
				posstr = ['(' num2str(i) ',' num2str(j) ')'];
				if size(eA) > 0
					Aval = A(1:eA-1);
					Aexp = A(eA+1:end);
					defstr = [ '\\Mset{' str posstr '}{' Aval '}{}{' Aexp '}\n' ];
				else
					defstr = [ '\\Mset{' str posstr '}{' A '}\n' ];
				end
				fprintf(FID,defstr);
			end
		end

	else
		error('can only take one or two matrices.')
	end

	fclose(FID);

end
