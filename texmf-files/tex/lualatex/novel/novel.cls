%% This is file `novel.cls', LuaLaTeX `novel' document class.
%% Copyright 2017-2024 Robert Allgeyer.
%% Contact: Username `rallg' @ GitHub and tex.stackexchange. `RobtAll' @ CTAN.
%% 
%% This file may be distributed and/or modified under the
%% conditions of the LaTeX Project Public License, version 1.3c.
%% License URL:  https://www.latex-project.org/lppl/lppl-1-3c/
%% 
\NeedsTeXFormat{LaTeX2e}[1995/12/01]
% Actually needs LuaLaTeX, at least version 0.95 from TeXLive 2016.
\ProvidesClass{novel}[2024/02/17 v2.1 LaTeX document class]
%%

%% During the years since `novel' was introduced, there have been
%% many changes in print-on-demand. Also, `novel` offers some
%% features that are rarely used, bloating the code and documentation.
%%   Although `novel` still works (as of late 2023), it is more complicated
%% than necessary for ordinary popular fiction. Unless you really need `novel',
%% try `novelette' instead. Available early 2024. Easier to use.


%% In addition to a minimal LaTeX setup, with luatex, you will need these:
%% textpos magaz xcolor adjustbox eso-pic pdfpages unicode-math fp iftex
%% libertinus-fonts makecmds xkeyval lm-math xstring xifthen silence
%% collectbox pgf lipsum wrapfig pdflscape microtype hyperref
%% You will need language support, for your language(s).
%% Default support is polyglossia. Write \setmainlanguage[options]{language}
%% in preamble. Alternative babel, write `v2' as a document class option,
%% and write choice of language as a document class option.
%% If using lipsum, you will need hyphen-latin.


%% DESCRIPTION:
%% ----------------------------------------------------------------------------
%% Class `novel' is designed for print fiction: novels or short stories.
%% It cannot be used for e-books or for journal publication.
%% It is not suitable for most non-fiction, because routine academic features
%% such as bibiography and automatic sectioning are defeated.
%% Only use it for ORIGINAL works, where you can edit your text. If your
%% purpose is a reprint of someone else's work, then `novel' is not for you.
%%
%% There are pre-configured layouts for the most commonly used choices of
%% trim size (finished book width and height), and internal layout consistent
%% with fiction. The user can over-ride the pre-configured settings.
%%
%% The class will automatically create PDF/X compliant files upon request,
%% using a self-contained command structure. Results have been tested.
%%
%% LuaLaTeX is required, and input files must be encoded utf-8.
%%
%% Fonts are loaded by luaotfload and fontspec, and massaged by microtype.
%% For best results, use modern Open Type fonts, or TrueType fonts.
%%
%% The Libertinus font family, fork of [Linux] Libertine/Biolinum, is default.
%% An included custom font, NovelDeco.otf, is used for special purposes.
%%


%% REQUIRE LUATEX and do some preliminary setup.
%% ----------------------------------------------------------------------------
%% These are not user settings.
%
\RequirePackage{iftex} % LuaTeX is required. Not XeTeX, dvips, or pdfTeX.
\RequirePackage{luatex85} % Needed for compatibility with LuaTeX 0.95 etc.
\RequirePackage{pdftexcmds} % compatibility
\ifluatex
  \pdfvariable suppressoptionalinfo 511 % writes only ID to PDF Catalog
\else
  \ClassError{novel}{Must compile with LuaLaTeX 0.95+}%
   {Sorry, LuaLaTeX only. No pdfTeX, dvips, or XeTeX.^^J%
    Command line:  lualatex your-document.tex}
\fi
\pdfimageresolution=300 % default dpi if image does not say
\nofiles
%
\RequirePackage{etoolbox} % general good stuff
\RequirePackage{xifthen} % improved ifthenelse handling
\RequirePackage{xstring} % parses strings
\RequirePackage{fp} % used everywhere for math calculations
\RequirePackage{keyval} % used by drop cap
\FPmessagesfalse % eliminates numerous friendly messages from the log
%
\pdfminorversion=3 % might be reset later, depending on settings
\gdef\thepdfminorversion{\pdfminorversion} % compatibility
%
\RequirePackage{silence} % Used here:
% hyperref draft mode is always on, even when novel is not in draft mode:
\WarningFilter{hyperref}{Draft mode on} % So, get rid of the hyperref warning.
% Prevent complaints about no protrusion list for cmr, cmm, etc. in decimal pt:
\WarningFilter{microtype}{I cannot find a protrusion list} % It's not there!
%
\WarningsOff[Fancyhdr,fancyhdr] % complains about headheight when no header
\RequirePackage[relative]{textpos} % for inserting images
\RequirePackage{calc} % allows length expression calculations
\RequirePackage{atbegshi} % in oberdiek bundle. For one-page header changes.
\RequirePackage{letltxmacro} % in oberdiek bundle. For re-defining some macros
\RequirePackage{xparse} % for writing cool-looking commands
%
% In addition, the following packages are required, but not loaded yet.
% They must wait for something else to happen first. Then they will be loaded
%   with suitable arguments, when the time comes:
% fontspec -- in novel-LayoutSettings.sty
% unicode-math -- in novel-LayoutSettings.sty
% microtype -- in novel-Fonts.sty
% hyperref -- in novel-pdfx.sty
% fancyhdr -- in novel.HeadFootStyles.sty
% xcolor -- lower in this page
% adjustbox -- lower on this page
% eso-pic -- lower on this page
% lipsum -- lower on this page
%%


\newlength\@tempLength % scratch length for local calculations
\newif \if@tempTF % scratch boolean for local tests
\newif \ifnocle@rtoend % Only developer uses true.

%% Global lengths are often passed around in `novel'.
%% But \setlength is not always global in effect.
%% This code defines a global command.
%% Via Heiko Oberdiek at tex.stackexchange.com:
\gdef\gsetlength#1#2{% #1 is the length command, #2 is the length value
  \begingroup%
    \setlength\skip@{#2}% Local assignment to a TeX scratch register.
    \global#1=\skip@% Global assignment to #1
  \endgroup% \skip@ is restored by end of group.
}% end \gsetlength
%%


%% Process document class options.
%% ----------------------------------------------------------------------------
% Allowed option list:
%   draft xml shademargins cropmarks cropview closecrop
%   coverart sandbox unblock mtoff test revert v2 (babel languages)
% Version 2 change allows language support from polyglossia or babel.
% Version 1.80 has minor tweaks. Option `revert' for version 1.52 behavior.
\newif \if@novrevert
\DeclareOption{revert}{\@novreverttrue}
% If used, option `draft' shows overflow rule.
\newif \ifdraftdoc
\setlength\overfullrule{0pt}
\DeclareOption{draft}{
  \setlength\overfullrule{6pt}
  \draftdoctrue
  \ClassWarning{novel}{^^JCompiled with draft mode. Not for final release! ^^J}
}
\newif \ifmsdoc % manuscript, always false. Compatibility with other packages.
% If used, option `xml' creates a file `\jobname-XMPasXML.xml` that contains
% the XMP metadata with an xml declaration and comments at top.
% Only works when \SetPDFX is not `off'. Note that you do not need to use
% this option to get PDF/X. It is only for your own usage.
\newif \if@wantXMPasXML
\DeclareOption{xml}{\@wantXMPasXMLtrue}
\DeclareOption{xmp}{ % in case you mis-type.
  \ClassError{novel}{No class option `xmp'. Use `xml'}%
   {There is no class option named `xmp'. It is `xml'.}
}
% Option `shademargins' does just that. Ignored unless in draft mode.
\newif \if@shademargins
\DeclareOption{shademargins}{\@shademarginstrue}
%
\newif \if@graytext % remains here for backwards compatibility
\@graytexttrue % Always true.
%
% Usually you do NOT want crop (trim) marks!
\newif \if@cropmarks
\DeclareOption{cropmarks}{\@cropmarkstrue}
% PDF viewers display CropBox, which normally is identical to MediaBox.
% Option `cropview', sets CropBox to TrimBox instead, so that's all you see.
% Only makes a difference when MediaBox is larger than TrimBox.
% Ignored unless in draft mode.
\newif \if@cropview
\DeclareOption{cropview}{\@cropviewtrue}
% With `closecrop', the TrimSize and margins are re-sized, to preserve the
% live area, but with reduced margins on all sides (same for verso/recto).
% This option is available only in draft mode, and disables shademargins.
% The purpose is to create a PDF that is more easily read on a handheld device,
% so you can think about edits while traveling. It is NOT an e-book, since
% it has no hyperlinks and is missing some features that an e-book should have.
\newif \if@closecrop
\DeclareOption{closecrop}{\@cropviewtrue\@closecroptrue}
% This is used to create a 1-page file with no text, just an image.
% Option coverart. Intended purpose is PDF/X for novel cover.
\newif \if@coverart
\DeclareOption{coverart}{\@coverarttrue}
% Option unblock, for developer use only.
% Normally, a number of packages known to be incompatible with `novel'
% are blocked from loading. If the user tries to get them via \usepackage
% or \RequirePackage, or if they are called within some other loaded package,
% then compile halts with an error. The `unblock' option turns off blocking,
% and allows incompatible packages to load. Use only at own risk!
\newif \if@novelunblock % For developer use.
\DeclareOption{unblock}{\@novelunblocktrue}
% Option mtoff. Primarily for developer use.
% With mtoff, the microtype package is not loaded.
\newif \if@mtoff
\DeclareOption{mtoff}{\@mtofftrue}
% Option test. Primarily for developer use.
\newif \if@testsuite
\DeclareOption{test}{\@testsuitetrue}
\newif \ifusing@vtwo
\DeclareOption{v2}{\using@vtwotrue} % Reserved for future use.
%
% Option sandbox. for artwork and tables. Max 4 pages.
\newif \if@sandbox
\DeclareOption{sandbox}{\@sandboxtrue}
%
%% Note that document size and normal font size are not class options.
%% They are set by commands in the Preamble, and have default values.
%
\ProcessOptions\relax
% Disable some options, depending on compatibilities:
\ifdraftdoc\else
  \global\@shademarginsfalse
  \global\@cropviewfalse
  \global\@closecropfalse
\fi
%
\if@testsuite
  \gdef\@testintentional{Test suite intentionally generates this warning. ^^J}
\else
  \gdef\@testintentional{}
\fi
%
\if@cropview
  \global\@cropmarksfalse
\fi
%
\if@closecrop
  \global\@cropviewtrue
  \global\@shademarginsfalse
  \global\@cropmarksfalse
\fi
%
\if@coverart
  \global\draftdocfalse
  \global\@shademarginsfalse
  \global\@cropviewfalse
  \global\@closecropfalse
  \global\@sandboxfalse
\fi
%
\if@sandbox
  % Thanks to user Compholio at stackexchange.com:
  \newcounter{sandboxcount}
  \ifx\latex@outputpage\@undefined\relax%
      \global\let\latex@outputpage\@outputpage%
  \fi%
  \gdef\@outputpage{%
    \addtocounter{sandboxcount}{1}%
    \ifnum\value{sandboxcount}>4\relax% no output after 4 pages
    \else%
      \latex@outputpage%
    \fi%
  }%
  \AtEndPreamble{%
    \gdef\@title{untitled interior artwork}%
  }%
  \AfterEndPreamble{%
    \ifdraftdoc\else\thispagestyle{empty}\fi%
  }%
\fi
%% end class options


\RequirePackage{noindentafter} % for unindented chapter and scene starts
\RequirePackage{changepage} % provides block indents, etc. Do not use strict!
\RequirePackage{magaz} % special treatment of first lines


%% Activate xcolor, adjustbox, and eso-pic:
%% ----------------------------------------------------------------------------
% The final book must be black/white and gray only, for all text.
% Interior images must be raster black/white or grayscale. See documentation.
%   Vector graphics are strongly discouraged, in any case.
% In draft mode only, the `shademargins' option requires `grayscale',
%   which will be temporarily enabled, even if not specifically requested.
%
\RequirePackage[gray]{xcolor}
%
% adjustbox and eso-pic cannot precede xcolor.
\RequirePackage{adjustbox} % for scaling and moving
\RequirePackage{eso-pic} % background effects in draft mode
\RequirePackage{pdfpages} % only used for pdf pre-processed by novel-scripts
%% end activate xcolor and adjustbox


%% Temporary normal font size, baselineskip, and fontspec
%% ----------------------------------------------------------------------------
%% This normalsize is temporary, so that packages can load without complaint.
%% It will be modified later, during layout calculations.
%% Actual default font size will be 11pt-12pt, with 11.4pt average.
%% The small temporary size is to ensure that overly-large struts and skips
%%   are not created prior to page layout calculation.
\gdef\@TentativeEmN{10}
\gdef\@TentativeBLSkipN{13}
\renewcommand\normalsize{%
  \@setfontsize\normalsize{\@TentativeEmN}{\@TentativeBLSkipN}%
}
\normalsize
%%
\ifusing@vtwo\else
  \RequirePackage{polyglossia}
  \ExplSyntaxOn
  \pretocmd\xpg@set@alias@values{%
	\prop_if_exist:cF { xpg@alias@keyvals@#1@#4 }
	{ \prop_new:c {xpg@alias@keyvals@#1@#4} }
  }{}{}
  \ExplSyntaxOff
  \setmainlanguage[variant=american]{english}
\fi
%%


\RequirePackage[no-math]{fontspec} % For LuaLaTeX. NOT package `fontenc'.
% The `novel' class is not intended for math. But TeX assumes you do math,
%   so it needs a math font, whether you like it or not.
\RequirePackage{unicode-math}
%% end temporary normal point size, baselineskip, and fontspec.


%% Define commands used for File Data, including PDF/X Settings.
%% ----------------------------------------------------------------------------
%% As used here, `File Data' refers to PDF metadata as found in PDF/Info
%% and in XMP. This class does not write it to the PDF Catalog.
\RequirePackage{novel-FileData}
%%


%% Physical Layout Commands and Settings.
%% ----------------------------------------------------------------------------
%% Define user commands that over-ride class option pre-configured settings.
%% Also sets a variety of miscellaneous lengths: \parsep, \parindent, etc.
\RequirePackage{novel-LayoutSettings}


%% Additional Macros, Loaded in Preamble.
%% ----------------------------------------------------------------------------
\RequirePackage{novel-Fonts} % font settings and defaults
\if@coverart\else\RequirePackage{lipsum}\fi % generates dummy text for examples
\RequirePackage{novel-DropCap}
% Macros for use in document body:
\RequirePackage{novel-TextMacros}
% Standard header footer styles, based on `fancyhdr':
% Each pre-configured style will set these booleans true or false:
\newif\if@HasHeader \newif\if@HasFooter
\RequirePackage{novel-HeadFootStyles}
% Chapter and Scene styles:
\RequirePackage{novel-ChapterScene}
% Image placement:
\RequirePackage{novel-Images}
% Footnotes and endnotes:
\RequirePackage{novel-Footnotes}
%%


%% For convenience, from `article' class.
%% ----------------------------------------------------------------------------
\newenvironment{verse}{% Not very useful.
  \let\\\@centercr
  \list{}{%
    \itemsep\z@
    \itemindent -\parindent%
    \listparindent\itemindent
    \rightmargin \leftmargin
    \advance\leftmargin \parindent%
  }%
  \item\relax%
}{%
  \endlist%
}
%%
\newenvironment{quotation}{% Not very useful.
  \list{}{%
    \listparindent \parindent%
    \itemindent \listparindent
    \rightmargin \leftmargin
    \parsep \z@%
  }%
  \item\relax%
}{%
  \endlist%
}
%%
\newenvironment{quote}{% Not very useful.
  \list{}{%
    \rightmargin\leftmargin%
  }%
  \item\relax%
}{%
  \endlist%
}
%
%% end convenience.



%% Special features of test suite (for developers and error reporting)
%% ----------------------------------------------------------------------------
% Files `novel-testsuite.tex' and `novel-testimage.png' are within the novel
%   documentation extras folder. To run the test suite, copy these files to
%   a writeable location (such as your home directory) and compile there.
\newcommand\testsuiteoops[1]{%
  \ClassError{novel}{#1 missing}{Install the necessary file(s).}%
}
\if@testsuite
  \IfFontExistsTF{libertinusserif-regular.otf}{}{%
    \testsuiteoops{`libertinus' fonts}%
  }
  \IfFileExists{lmodern.sty}{}{\testsuiteoops{`lmodern' package}}
  \IfFileExists{novel-testimage.png}{}{\testsuiteoops{`novel-testimage.png'}}
  \NewFontFamily\mustbelibertinus{Libertinus Serif}
  \NewFontFamily\mustbelmodern{Latin Modern Roman}
\fi
%% end special features of test suite.


%% \AtEndPreamble sets defaults, calculates layout, and writes PDF/X
%% ----------------------------------------------------------------------------
% This is prior to \AtBeginDocument, and ensures that the results are available
%   prior to any \AtBeginDocument routines from user macros or loaded packages. 
\AtEndPreamble{
  \@ActivateFonts % in `novel-Fonts.sty'
  \RequirePackage{novel-CalculateLayout} % may load novel-ChangeLayout.sty
  \RequirePackage{novel-PostLayout} % calculates shademargins, cropmarks, etc.
  \RequirePackage{novel-pdfx}% also provides an \AtBeginDocument macro
  \@GetInitialYpos% in `novel-TextMacros.sty
  \ifdefined\setmainlanguage\else
    \ifusing@vtwo
      \@ifpackageloaded{babel}{}{\RequirePackage[american]{babel}}
    \fi
  \fi
}%
%% end AtEndPreamble


%% Messages that may be issued by \AtBeginDocument routines:
%% ----------------------------------------------------------------------------
%
%% Dealing with known incompatible packages:
\gdef\really@no#1#2#3{ % cannot be used, even with unblock or sandbox
  \@ifpackageloaded{#1}{%
   \ClassError{novel}{Sorry, package `#1' cannot be used in `novel' class}%
    {No exceptions. You are out of luck. ^^J%
     Reason: `novel' has #2 ^^J%
     See `novel' HTML documentation, section #3. ^^J%
     Note: The offending package may have been loaded by another package.}%
  }{}%
} %
%
%% Command or environment native to LuaLaTeX, but banned except in sandbox:
\gdef\@OnlySandbox#1{%
  \ClassError{novel}{Use of `#1' page \thepage\space requires sandbox}%
   {`novel' class prohibits command or environment `#1' ^^J%
    unless you use class option `sandbox'. See documentation.}%
}
%
%% Package can be used, but Alert:
\gdef\alert@nodisp#1{%
  \@ifpackageloaded{#1}{%
  \typeout{^^JClass `novel' Alert: Beware of package #1. ^^J%
   Commands from this package may cause mis-positioning in main text. ^^J%
   Maybe, maybe not. Best if usage is confined to display pages. ^^J}%
  }%
}
%
%% Dealing with blocked packages, allowed with `unblock':
\if@novelunblock
  \gdef\sorry@no#1{} % no package-specific errors, when unblock
  \ClassWarning{novel}{Using `unblock' class option, at your own risk. ^^J%
    The `unblock' option is for developer use, not production documents. ^^J%
    If the unblocked packages and commands cause problems, ^^J%
    they are not bugs. Do not report them. You have been warned. ^^J%
    Perhaps your document will compile without error, and perhaps the ^^J%
    results are OK. But in other cases, unexpected typesetting results. ^^J}%
\else % package-specific errors, when no unblock
  \gdef\sorry@no#1{
    \@ifpackageloaded{#1}{%
     \ClassError{novel}{Sorry, package `#1' cannot be used in `novel' class}%
      {See `novel' HTML documentation, regarding `sandbox' option. ^^J%
       Note: The offending package may have been loaded by another package.}%
    }{}%
  } %
\fi
%
\gdef\@needsandboxmsg{%
  \ClassError{novel}{Need `sandbox' for picture, figure, table environments}%
   {You cannot use picture, figure, or table environments in `novel' unless ^^J%
    you use the `sandbox' document class option. See docs.}%
}
%% end messages.


%% \AtBeginDocument finishes the setup
%% ----------------------------------------------------------------------------
%
\AtBeginDocument{ %
  \@RedefineParapos % in `novel-TextMacros.sty'
  \@ActivateTextLengths % in `novel-TextMacros.sty'
  \@ActivateDropCaps % in `novel-DropCaps.sty'
  \@ActivateChapterScene % in `novel-ChapterScene.sty'
  \@ActivateHeadFootStyles % in file `novel-HeadFootStyles.sty'
  \@AlertNoPDFX % in file `novel-pdfx.sty'
  \@ActivatePDFInfo % in file `novel-pdfx.sty'
  \@ActivateTextMacros % in `novel-TextMacros.sty'
  \@ActivateFootnotes % in `novel-Footnotes.sty'
  \@DisableFontSizes % in file `novel-LayoutSettings.sty'
  \@DisableLayoutSettings % in file `novel-LayoutSettings.sty'
  \@DisableFileDataSettings % in file `novel-FileData.sty'
  \@DisableChapterSceneSettings % in file `novel-ChapterScene.sty'
  \@RedefineBreakpos % in file `novel-ChapterScene.sty'
  \@DisableHeadFootSettings % in file `novel-HeadFootStyles.sty'
  \@GatherGoodImages % in file `novel-Images.sty'.
  % List of always-blocked packages (not exhaustive, since TeX has so many):
  \really@no{geometry}{its own layout commands.}{4}
  \really@no{pdfx}{built-in PDF/X capability.}{3.4}
  \really@no{xmpincl}{built-in PDF/X capability.}{3.4}
  \really@no{hyperxmp}{built-in PDF/X capability.}{3.4}
  \really@no{pdfxmult}{built-in PDF/X capability.}{3.4}
  \really@no{inputenc}{utf-8 encoding always.}{1.2.1}
  \really@no{fontenc}{`fontspec' and utf-8 encoding always.}{1.2.1, 1.2.3}
  \really@no{biblatex}{no bibiography capability.}{1.2.5}
  \really@no{showkeys}{an incompatible layout method.}{1.2.5}
  \really@no{booktabs}{no capability for this, due to printer specs.}{3.4}
  \really@no{pax}{no capability for this, due to printer specs.}{3.4}
  \really@no{bookmark}{focus on paper books, not e-books.}{(top of file)}
  \really@no{endnotes}{limited, built-in endnote methods.}{6.5}
  \really@no{acronym}{focus on paper books, not e-books.}{(top of file)}
  \really@no{embedfile}{incompatible print requirements.}{(top of file)}
  \really@no{makeidx}{an incompatible layout method.}{1.2.5}
  \really@no{gridset}{a command name conflict.}{4}
  % Potential problem packages, allowed in sandbox or with unblock:
  \if@sandbox
    \RequirePackage{novel-Sandbox}
  \else
    \gdef\mplibcode{\@OnlySandbox{mplibcode}}
    % Related to floats:
    \sorry@no{floatflt}
    \sorry@no{floatfig}
    \sorry@no{flafter}
    \sorry@no{float}
    \sorry@no{morefloats}
    \sorry@no{endfloat}
    \sorry@no{placeins}
    % Related to footnotes and endnotes:
    \sorry@no{footmisc}
    \sorry@no{footnote}
    \sorry@no{manyfoot}
    % Related to tables:
    \sorry@no{multirow}
    \sorry@no{tabu}
    \sorry@no{tabularx}
    \sorry@no{tabulary}
    \sorry@no{longtable}
    % Related to lists:
    \sorry@no{array}
    \sorry@no{easylist}
    \sorry@no{listings}
    \sorry@no{numitem}
    \sorry@no{tasks}
    % Related to graphics or layout:
    \sorry@no{pagegrid}
    \sorry@no{subfig}
    \sorry@no{lpic}
    \sorry@no{pinlabel}
    \sorry@no{overpic}
    \sorry@no{caption}
    \sorry@no{sidecap}
    \sorry@no{subcaption}
    \sorry@no{paracol}
    \sorry@no{scrextend}
    \sorry@no{exsheets}
    \sorry@no{eqparbox}
    \sorry@no{colortbl}
    \sorry@no{tikz}
    \sorry@no{pstricks}
    \sorry@no{xypic}
    \sorry@no{xfig}
    \sorry@no{pgfcalendar}
    \sorry@no{pgfpages}
    \sorry@no{pst-pdf}
    \sorry@no{auto-pst-pdf}
    \sorry@no{epstopdf}
    \sorry@no{pdftricks}
    \sorry@no{pdftricks2}
    \sorry@no{mpgraphics}
    \sorry@no{pict2e}
    \sorry@no{picman}
    \sorry@no{scalerel}
    \sorry@no{pmgraph}
    \sorry@no{reflectgraphics}
  \fi % end sandbox.
  % Alert packages, might cause minor layout problems, not enough to block:
  \alert@nodisp{nth}
  \alert@nodisp{engord}
  \alert@nodisp{ulem}
  \alert@nodisp{soul}
  % end list of Alert packages.
  % Package `pagegrid' interacts with `shademargins' and `draft' options:
  \@ifpackageloaded{pagegrid}{ % that is, if permitted by sandbox or unblock
    \ifdraftdoc
      \if@shademargins
        \ClassWarning{novel}{^^JGrid from `pagegrid' is concealed. ^^J%
         Document class option `shademargins' over-writes page grid. ^^J%
         To see the grid, use `draft' but not `shademargins'. ^^J}
      \else\fi
    \else
      \ClassError{novel}{Package `pagegrid' needs `draft' mode}%
       {Package `pagegrid' only with document class option `draft'.}%
    \fi
  }{} % end if pagegrid
}% end \AtBeginDocument
%%


%% AtEndDocument adds one or two blank pages, required by printers.
% Also writes list of inspected, good images to aux, for later use:
\AtEndDocument{%
  \if@coverart\else%
    \if@sandbox\else%
      \ifnocle@rtoend\else\cleartoend\fi%
    \fi%
  \fi%
}
%%


%% AfterEndDocument writes final message:
\AfterEndDocument{
  \@WarnUnknownImages % in `novel-Images.sty'.
}
%%



%%
%% End of file `novel.cls'

