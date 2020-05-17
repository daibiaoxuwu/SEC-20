set term post eps color solid enh 'ArialMT' 26
set output 'sp-coflood.eps'
set xrange [0:8]
set key top right
set key samplen 2 spacing 2 font ',22'
set xtics ('64' 1, '128' 2, '192' 3, '256' 4, '320' 5, '384' 6, '448' 7)
set xlabel 'Shortcut Path Threshold (ms)'
set ylabel 'Completion Time (ms)'
set yrange [800:2400]
set ytics 800,400,2400
plot 'sp-coflood-result.txt' using 2:4 with linespoints t 'Lab Testbed' lt 7 lw 4 lc rgb 'black' ps 2 pt 4, 'sp-coflood-result.txt' using 2:3 with linespoints t 'Indriya Testbed' lt 4 lw 4 lc rgb 'red' ps 2 pt 8
