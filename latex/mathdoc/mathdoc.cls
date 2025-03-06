% mathdoc.cls
% Description: Custom math document class with standard macros and formatting
% Date: February 21, 2025

\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{mathdoc}[2025/02/21 v1.0 Math Document Class]

% Handle class options - pass all options to article class
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{article}}
\ProcessOptions\relax

% Load the base class with your default options
\LoadClass[11pt,letterpaper]{article}

% Load geometry package with your default settings
\RequirePackage[top=1in,textheight=9in]{geometry}

% Load all other required packages
\RequirePackage{amsmath, amsthm, amssymb}
\RequirePackage{enumerate}
\RequirePackage{xfrac}
\RequirePackage{xcolor}
\RequirePackage{multicol}
\RequirePackage{bbm}  % For indicator functions
\RequirePackage{mathtools} % For abs values

% Define math symbol macros
\newcommand{\C}{\mathbb{C}}
\newcommand{\N}{\mathbb{N}}
\newcommand{\Q}{\mathbb{Q}}
\newcommand{\R}{\mathbb{R}}
\newcommand{\Z}{\mathbb{Z}}
\renewcommand{\P}{\mathbb{P}}
\newcommand{\cB}{\mathcal{B}}
\newcommand{\cI}{\mathcal I}
\newcommand{\cF}{\mathcal F}
\newcommand{\cL}{\mathcal{L}}
\newcommand{\cP}{\mathcal{P}}
\newcommand{\cT}{\mathcal{T}}
\newcommand{\eps}{\varepsilon}
\renewcommand{\epsilon}{\eps}

% Indicator function
\newcommand{\1}{\mathbbm{1}}

% Absolute value macros
\DeclarePairedDelimiter\abs{\lvert}{\rvert}%
\DeclarePairedDelimiter\norm{\lVert}{\rVert}%

% Swap the definition of \abs* and \norm*, so that \abs
% and \norm resizes the size of the brackets, and the 
% starred version does not.
\makeatletter
\let\oldabs\abs
\def\abs{\@ifstar{\oldabs}{\oldabs*}}
%
\let\oldnorm\norm
\def\norm{\@ifstar{\oldnorm}{\oldnorm*}}
\makeatother

% Math operators
\DeclareMathOperator{\Id}{Id}
\DeclareMathOperator{\Int}{Int}
\DeclareMathOperator{\card}{card}
\DeclareMathOperator{\epi}{epi}

% Expected value operator with auto-sizing brackets
\newcommand{\E}[2][]{\mathbb{E}_{#1}\left[ #2 \right]}


% Theorem-like environments
\newtheorem{defn}{Definition}
\newtheorem{innerprob}{Problem}
\newenvironment{prob}[1]
  {\renewcommand\theinnerprob{#1}\innerprob}
  {\endinnerprob}

% Solution environment
\newenvironment{solution}
  {\renewcommand\qedsymbol{}\begin{proof}[Solution]}
  {\end{proof}\bigskip}

\endinput

