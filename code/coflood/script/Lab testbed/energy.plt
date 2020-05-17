set term post eps color solid enh 'ArialMT' 26
set output 'energy.eps'
set xrange [0:6]
set xtics ('10' 1, '20' 2, '30' 3, '40' 4, '50' 5)
set xlabel 'Number of Concurrent Senders'
set ylabel 'Radio Duty Cycle (%)'
set yrange [0:14]
set ytics 0,2,14
set key top right
set key samplen 2 spacing 2 font ',22' box lw 2
plot 'data.txt' using 1:2 with linespoints t 'Lab Testbed' lt 7 lw 4 ps 2 pt 4
