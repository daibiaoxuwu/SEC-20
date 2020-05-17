set term post eps color solid enh 'ArialMT' 26
set output 'energy.eps'
set xrange [0:6]
set xtics ('10' 1, '20' 2, '30' 3, '40' 4, '50' 5)
set xlabel 'Number of Concurrent Senders'
set ylabel 'Radio Duty Cycle (%)'
set yrange [4:14]
set ytics 4,2,14
set key top right
set key samplen 2 spacing 2 font ',22'
plot 'lab_data.txt' using 1:2 with linespoints t 'Lab Testbed' lt 7 lw 4 lc rgb 'black' ps 2 pt 4, 'indriya_data.txt' using 1:2 with linespoints t 'Indriya Testbed' lt 4 lw 4 lc rgb 'red' ps 2 pt 8
