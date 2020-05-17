set term post eps color solid enh 'ArialMT' 26
set output 'beacon_number.eps'
set xrange [0:6]
set key top right
set key samplen 2 spacing 2 font ',22'
set xtics ('5' 1, '10' 2, '15' 3, '20' 4, '25' 5)
set xlabel 'Number of Beacons'
set ylabel 'Average Expected Broadcasts'
set yrange [0:30]
set ytics 0,5,30
plot 'beacon-number-result.txt' using 2:4 with linespoints t 'Lab Testbed' lt 7 lw 4 lc rgb 'black' ps 2 pt 4, 'beacon-number-result.txt' using 2:3 with linespoints t 'Indriya Testbed' lt 4 lw 4 lc rgb 'red' ps 2 pt 8
