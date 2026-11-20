\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{unireport}[2026/05/30 University Report Class]

\RequirePackage{kvoptions}
\SetupKeyvalOptions{family=unireport,prefix=unireport@}
\DeclareStringOption[python]{codelanguage}
\DeclareDefaultOption{\PassOptionsToClass{\CurrentOption}{report}}
\ProcessKeyvalOptions*

\LoadClass{report}

\RequirePackage{tikz}
\RequirePackage{fontspec}
\RequirePackage{minted}
\RequirePackage{tcolorbox}
\RequirePackage{pgf-umlsd}
\RequirePackage{adjustbox}
\RequirePackage{listings}
\RequirePackage{url}
\RequirePackage{hyperref}
\RequirePackage{geometry}
\RequirePackage{tocloft}
\RequirePackage{graphicx}

\setsansfont{Fira Sans}
\setmonofont[Scale=0.88]{JetBrains Mono}
\renewcommand{\familydefault}{\sfdefault}

% \code{} reads its argument verbatim (xparse v-type), renders spaces
% as ␣ (U+2423), and allows line breaks after common punctuation.
\def\UrlFont{\ttfamily}
\ExplSyntaxOn
\NewDocumentCommand{\code}{m}{%
  \group_begin:
  \ttfamily
  \str_set:Nn \l_tmpa_str {#1}%
  \str_map_inline:Nn \l_tmpa_str {%
    \str_case:nnF {##1} {%
      {~} {\discretionary{}{}{\char 32}}%
      {/} {/\penalty 0}%
      {-} {-\penalty 0}%
      {.} {.\penalty 0}%
      {:} {:\penalty 0}%
      {=} {=\penalty 0}%
      {_} {_\penalty 0}%
      {,} {,\penalty 0}%
    }{##1}%
  }%
  \group_end:
}
\ExplSyntaxOff

\setlength{\parskip}{0.8em}
\setlength{\cftbeforechapskip}{2.0em}
\geometry{a4paper, margin=1.2in}
\setlength{\parindent}{0pt}
\setlength{\emergencystretch}{3em}

% Report parameters
\newcommand{\reportauthor}{Aiden Cachia}
\newcommand{\reportstudentid}{0279305L}
\newcommand{\reportcoursecode}{}
\newcommand{\reportcoursename}{}
\newcommand{\reportassignmenttitle}{}
\newcommand{\reportassignmentsubtitle}{}

\newcommand{\Author}[1]{\renewcommand{\reportauthor}{#1}}
\newcommand{\StudentID}[1]{\renewcommand{\reportstudentid}{#1}}
\newcommand{\CourseCode}[1]{\renewcommand{\reportcoursecode}{#1}}
\newcommand{\CourseName}[1]{\renewcommand{\reportcoursename}{#1}}
\newcommand{\AssignmentTitle}[1]{\renewcommand{\reportassignmenttitle}{#1}}
\newcommand{\AssignmentSubtitle}[1]{\renewcommand{\reportassignmentsubtitle}{#1}}

\AtBeginDocument{
    \author{\reportauthor\\\reportstudentid}
    \title{\textbf{\reportcoursecode\ |\ \reportcoursename}\\[15pt] \reportassignmenttitle%
        \ifx\reportassignmentsubtitle\empty\else\\[6pt]\large\reportassignmentsubtitle\fi}
}

\setminted{breaklines=true, breakanywhere=true}
\setmintedinline[java]{fontsize=\small}
\setminted[java]{breaklines=true}
\setmintedinline[python]{fontsize=\small}
\setminted[python]{breaklines=true}
\hypersetup{
    colorlinks,
    citecolor=black,
    filecolor=black,
    linkcolor=black,
    urlcolor=black
}

\tcbuselibrary{skins,minted}
\tcbset{tile, colback=cyan!10!white, title style=cyan!80!white, sharp corners, fonttitle=\bfseries, borderline north={2pt}{-2pt}{cyan!80!white}}

\usemintedstyle{colorful}

\newtcblisting{codebox}[2][\unireport@codelanguage]{
    listing engine=minted,
    listing only,
    minted language=#1,
    minted options={breaklines=true, breakanywhere=true},
    title={#2}
}
