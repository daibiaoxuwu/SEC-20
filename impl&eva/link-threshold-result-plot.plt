set term post eps color solid enh 'ArialMT' 26
set output 'link_threshold.eps'
set xrange [0:6]
set key top left
set key samplen 2 spacing 2 font ',22'
set xtics ('0.5' 1, '0.6' 2, '0.7' 3, '0.8' 4, '0.9' 5)
set xlabel 'Threshold of Link Quality'
set ylabel 'Average Expected Broadcasts'
set yrange [0:30]
set ytics 0,5,30
plot 'link-threshold-result.txt' using 2:4 with linespoints t 'Lab Testbed' lt 7 lw 4 lc rgb 'black' ps 2 pt 4, 'link-threshold-result.txt' using 2:3 with linespoints t 'Indriya Testbed' lt 4 lw 4 lc rgb 'red' ps 2 pt 8
