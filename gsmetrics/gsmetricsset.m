function [Aidx, H2idx, Eidx, g, h, ncited,pcited]=gsmetrics(name,fullname,varargin)
%HINDEX  Computes the h-index of an author from Google Scholar.
%   HINDEX(AUTHORNAME,FULLAUTHORNAME) computes the h-index of the author 
%i  AUTHORNAME, on the basis of the publications referenced by Google Scholar
%   (http://scholar.google.com). An active internet connection is required.
%
%   The index h is defined as "the number of papers with citation number
%   higher or equal to h", and has been proposed by J.E. Hirsch to
%   "characterize the scientific output of a researcher" [Proc. Nat. Acad.
%   Sci. 46, 16569 (2005)]. Note that the number of citations referenced by
%   Google Scholar may be lower than the actual one (old publications are
%   not available online).
%
%   The string AUTHORNAME should contain the last name, or the initial(s)
%   of the first name(s) followed by the last name, of the author (eg,
%   'A. Einstein'). Do not put the initial(s) after the last name. The scan
%   is not case sensitive. Points (.) and spaces ( ) are not taken into
%   account. See Google Scholar Help for more details about the syntax.
%
%   Example: HINDEX('A. Einstein') returns 43 (ie: 43 papers by A. Einstein
%   have been cited at least 43 times, according to Google Scholar).
%
%   H = HINDEX(AUTHORNAME,FULLAUTHORNAME) only returns the h-index, without display.
%
%   HINDEX(AUTHORNAME, FULLAUTHORNAME,'Property1',...) specifies the properties:
%     'verb'       also displays the list of papers returned by Google
%                  Scholar, rejecting the ones for which AUTHORNAME is not
%                  one of the authors.
%     'plot'       also plots the 'Cited by' number as a function of the
%                  paper rank.
%
%   HINDEX should be used with care. Many biases exist (homonyms, errors
%   from Google Scholar, old papers are not available online, but
%   unpublished or draft papers are...) For the true h-index of an author,
%   it is recommended to use an official citation index database (eg, ISI).
%   Use HINDEX just for fun.
%
%   Remark: Massive usage of hindex may be considered by the Google
%   Scholar server as a spam attack, and may invalidate the IP number of
%   your computer. If this happens, you get an 'Internet connection failed'
%   error message -- but you still can use Google Scholar from a web
%   browser.
%
%   F. Moisy, moisy@fast.u-psud.fr
%   Revision: 1.11,  Date: 10-jul-2006


% History:
% 22-jan-2006: v1.00-1.10, first versions.
% 07-jul-2006: v1.11, check ML version; help text improved; use properties
% 03-sep-2010: v1.12, updated for new version of gscholar; added function to compute h for a set

% check the matlab version:
if str2double(version('-release'))<14,
    error('hindex requires Matlab 7 (R14) or higher.');
end;

% error(nargchk(1,2,nargin));

% clean the input text:

name=lower(name);
name=strrep(name,'.',' ');
name=strrep(name,'  ',' ');

if fullname,
    fullname=lower(fullname);
    fullname=strrep(fullname,'.',' ');
    fullname=strrep(fullname,'  ',' ');
end;
ncit=0;           % total number of citation
ncitinthispage=0; % number of citation in the current page
ncited=[];
pcited=0;

seenextpage=1;
numpage=0;

textResult = "";
while seenextpage,
    numpage=numpage+1;

    % Query Google Scholar for Results 
    % - Search is made only for authors, quoting the names to further limit the results and increase accuracy
    pagename=['http://scholar.google.com/scholar?num=100&start=' num2str(200*(numpage-1)) '&q=%22author%3A' strrep(name,' ','+author%3A') '%22'];
    
    % fullname is the Name+Lastname of the author, instead of only Initials+Lastname 
    % (was included only as quick shortcut for some tests)
    if fullname,
        pagename=['http://scholar.google.com/scholar?num=100&start=' num2str(200*(numpage-1)) '&q=%22author%3A' strrep(fullname,' ','+author%3A') '%22'];
    end; 
 
    %printf('getting %s\n\n',pagename);
    if nargout==0,
        disp(['Scanning: ' pagename]);
    end;

    [s, res]=urlread(pagename);

    if ~res,
        error('Internet connection failed.');        
    end;

    rem=s; % remainder of the string

    textResult = [textResult, rem]; 
    %while strfind(rem,'Cited by '),
    while strfind(rem,'<div class=gs_r>'),
        pauth1 = strfind(rem,'<span class=gs_a>')+17;
         
        pauth1 = pauth1(1);
        subrem = rem(pauth1:min(end,(pauth1+500)));
        pauth2 = strfind(subrem,'-')-1; 
        
        if length(pauth2),
            pauth2 = pauth2(1);
        else
            pauth2 = 0;
        end;

        authstring = lower(rem(pauth1:(pauth1+pauth2-1))); % list of authors of the paper
        authstring = strrep(authstring,'<b>','');
        authstring = strrep(authstring,'</b>','');
        authstring = strrep(authstring,'&hellip;','...');
        % check that the required name is indeed in the author list.
        paperok=0;

        pos=strfind(authstring,name);

        %subrem = rem(pauth1:min(end,(pauth1+500)));
        if length(pos),
            pos=pos(1);
            paperok=1;
            if pos>1,
                % check for wrong initials (eg, 'ga einstein' should not
                % match for 'a einstein')
                pl=authstring(pos-1);
                if ((pl>='a')&&(pl<='z'))||(pl=='-'),
                    paperok=0;
                end;
            end;
            if pos<(length(authstring)-length(name)),
                % check for wrong 'suffix' (eg, 'einstein-joliot' should not
                % match for 'einstein')
                nl=authstring(pos+length(name));
                if ((nl>='a')&&(nl<='z'))||(nl=='-'),
                    paperok=0;
                end;
            end;
        end;

        if paperok, % if the required name is indeed in the author list
            ncit = ncit+1;
            ncitinthispage = ncitinthispage +1;

            cithtml=strfind(rem,'class=gs_fl');

            if length(cithtml),
                cithtml=cithtml(1);
                subcit = rem(cithtml:min(end,(cithtml+1500)));
                cithtmlend=strfind(subcit,'</span>');

                if length(cithtmlend),
                    cithtmlend=cithtmlend(1);
                end;
                cithtmlend=cithtml+cithtmlend+7;
                subcit=rem(cithtml:cithtmlend);

                p=strfind(subcit,'Cited by ')+9;
            else
                p=0;
                cithtmlend=strfind(rem,'<div class=gs_r>');
                cithtmlend=cithtmlend(1)+15;
            end;

            if p,
                 %p=p(1);
                 substr=subcit(p:(p+5));
                 pend=strfind(substr,'<');
                 pend=pend(1);
                 ncited(ncit)=str2double(substr(1:(pend-1)));
                 if ncited(ncit),
                     pcited++;
                 end;
                 rem=rem(cithtmlend:end);
                 if any(strncmpi(varargin,'verb',1))
                     disp(['#' num2str(ncit) ': (' num2str(ncited(ncit)) '), ' authstring]);
                 end;
            else
                 rem=rem(cithtmlend:end);
                 nocitation=1;
                 ncited(ncit)=0;
            end;
        else
            if any(strncmpi(varargin,'verb',1))
                disp(['rejected: ' authstring]);
            end;
            next=strfind(rem,'<div class=gs_r>');
            next = next(1)+15;
            rem=rem(next:end);
        end;
    end;
    if any(strncmpi(varargin,'verb',1))
        disp(' ');
    end;

    if ncit==0,
        seenextpage=0;
    else
        if ((ncited(ncit)<2)||(~length(findstr(rem,'<span class=b>Next</span>')))),
            seenextpage=0;
        end;
    end;
end; % while seenextpage

if length(ncited),
    % sort the list (it should be sorted, but sometimes GS produces unsorted results)
    ncited=sort(ncited); ncited=ncited(ncit:-1:1);

%Hirsch, J.E. (2005) An index to quantify an individual's scientific
%research output, arXiv:physics/0508025 v5 29 Sep 2006.
%[...] The h-index is defined as follows:
%A scientist has index h if h of his/her Np papers have at least h
%citations each, and the other (Np-h) papers have no more than h citations
%each. [...] The relation between Ctot and h will depend on the detailed
%form of the particular distribution, and it is useful to define the
%proportionality constant a as Ctot=ah^2. I find empirically that a ranges 
%between 3 and 5. 
    h=sum(ncited>=(1:ncit));

%Egghe, L. (2006) Theory and practice of the g-index, Scientometrics, vol.
%69, No 1, pp. 131-152.
%The g-index is defined as follows:
%[Given a set of articles] ranked in decreasing order of the number of
%citations that they received, the g-index is the (unique) largest number
%such that the top g articles received (together) at least g2 citations.
%Although the g-index has not yet attracted much attention or empirical
%verification, it would seem to be a very useful complement to the h-index. 
    %ncitedDec = fliplr(ncited);
    ncitedDec = ncited;
    x = 1:ncit;
    ncit2=x.^2; cC=cumsum(ncitedDec);
    g=sum(cC>=ncit2);

%Jin, B. H. (2006). h-Index: An evaluation indicator proposed by scientist.
%Science Focus, 1(1), 89.
%The A-index is the "A"verage number of citations of the papers in the
%h-core
    if h==0, 
        Aidx=0;
    else 
        Aidx=mean(ncited(1:h));
    end;


%Kosmulski, M. (2006). A new Hirsch-type index saves time and works equally
%well as the original h-index. ISSI Newsletter, 2(3), 46.
%A scientists h(2) index is defined as the highest natural number such
%that his h(2) most-cited papers received each at least [h(2)]2 citations.
    H2idx=sum(ncited>=ncit2);

%Zhang, C.T. The e-index, complementing the h-index for excess citations,
%PLoS ONE, Vol 5, Issue 5 (May 2009), e5429. The e-index is the square
%root of the surplus of citations in the h-set beyond h2, i.e., beyond the
%theoretical minimum required to obtain a h-index of 'h'. The aim of the
%e-index is to differentiate between scientists with similar h-indices but
%different citation patterns. 
    H2=h^2;
    if h==0,
        Eidx=0;
    else
        Eidx=sqrt(sum(ncited(1:h))-H2);
    end;


    % plot the 'Cited by' number:
    if any(strncmpi(varargin,'plot',1))
        loglog(1:ncit,ncited,'.-',1:ncit,1:ncit,'--',h,h,'o');
        xlabel('Paper rank'); ylabel('Number of citations');
        title(['h-index plot for ''' name ''' (h=' num2str(h) ')']);
    end;

    % some displays if no output argument:
    if nargout==0,
        disp(['Number of cited papers: ' num2str(length(ncited))]);
        disp(['''Cited by'' list: ' num2str(ncited)]);
        disp(['Total number of citations: ' num2str(sum(ncited))]);
        disp(['h-index = ' num2str(h)]);
        disp(['g-index = ' num2str(g)]);
        disp(['A-index = ' num2str(Aidx)]);
        disp(['H(2)-index = ' num2str(H2idx)]);
        disp(['e-index = ' num2str(Eidx)]);
        clear h;
    end;
else
    h=0;
    g=0;
    Aidx=0;
    Eidx=0;
    H2idx=0;
    ncited=[];
    if nargout==0,
        disp('No result found');
        clear h;
    end;
end;

% saving gscholar results for future analysis
datenow = datestr(now);
%system("mkdir out");
file=["out/",fullname,"-",datenow,".txt"];
save("-text",file, "textResult");

endfunction
