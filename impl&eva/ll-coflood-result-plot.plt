set term post eps color solid enh 'ArialMT' 26
set output 'll-coflood.eps'
set xrange [0:6]
set key top right
set key samplen 2 spacing 2 font ',22'
set xtics ('512' 1, '640' 2, '768' 3, '896' 4, '1024' 5)
set xlabel 'Long Link Threshold (ms)'
set ylabel 'Compeletion Time (ms)'
set yrange [800:2400]
set ytics 800,400,3000
plot 'll-coflood-result.txt' using 2:4 with linespoints t 'Lab Testbed' lt 7 lw 4 lc rgb 'black' ps 2 pt 4, 'll-coflood-result.txt' using 2:3 with linespoints t 'Indriya Testbed' lt 4 lw 4 lc rgb 'red' ps 2 pt 8
