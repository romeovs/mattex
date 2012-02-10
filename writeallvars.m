function writeallvars(file,option)
	% WRITEALLVARS(file,option) writes all suitable variables in the workspace to the file 
	% specified in file using writevars options 'option'.
	% The variables are suitable when their size is equal to [1,1], [1,2] or [2,1] an when
	% they are of the 'double' class.
	%
	% See also WRITEVARS, FORMATVARS, WRITEMAT

	global var_names
	global var_names_l
	global temp
	evalin('caller',[ 'global var_names;',...
				   'var_names = who;',...
				   'global var_names_l;',...
				   'var_names_l=length(var_names);',...
				   'global temp;',...
				  ]);

	if var_names_l == 0
		warning('there were zero variables in workspace, nothing was done');
	else
		disp([num2str(var_names_l-1) ' variables were found...']);

		writestring = [];
		good = 0;
		bad = 0;
		bad_names={};
		for i = 1:var_names_l
			if ~strcmp(var_names{i},'var_names')
			evalin('caller', ['temp = ' char(var_names{i}) ';']);
			
			if numel(temp)>=1 && numel(temp)<=2 && strcmp(class(temp),'double')
				writestring = [writestring ',' char(var_names{i})];
				good = good + 1;
			else
				bad = bad +1;
				bad_names{end+1} = var_names{i};
			end
		end
	end

	if good > 0
		disp([num2str(good) ' of which are writable, ' num2str(bad) ' of which are not.']);
		fprintf('\n');
	try
		evalin('caller', [ 'writevars(''' file ''',''' option '''' writestring ');']);
	catch
		evalin('caller',[	'clear var_names var_names_l temp' ]);
		error('there was an error in writevars, probably a bad option or filename');
	end
	if strcmp(option,'as')
		disp(['silent appending variables to ''' file '''']);
	elseif strcmp(option,'ws')
		disp(['silent writing variables to ''' file '''']);
	end

		switch bad
			case 0

			case 1
				fprintf('the unwritten variable is:\n')
				fprintf(['\t' char(bad_names{1}) '\n'])
			otherwise
				if bad < 5
					fprintf('the unwritten variables are:\n')
					for i = 1:length(bad_names)
						fprintf(['\t' char(bad_names{i}) '\n'])
					end
				end
		end

	else
	warning([ 'none of the found variables were suitable for writing,'...
		     'make sure there are\n some variables that are 1x1 or 1x2']);
	end
	
	evalin('caller',[ 'clear var_names var_names_l temp' ]);

end
