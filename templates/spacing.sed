# divide file into 15 line chunks with LaTeX code added after each chunk
x
s/^/x/
t reset_t_cond
: reset_t_cond
# check if there are 15 'x' chars now
s/x\{15\}//
x
t insert
b

: insert
a\
\\\end{multicols}\
\\\pagebreak\
\
\\\begin{multicols}{3}\


