set term post eps color solid enh 'ArialMT' 24
set output 'duty-cycle-result.eps'
set style data histogram
set style histogram cluster gap 2
set style fill pattern 2 border
set boxwidth 1
set xlabel 'Testbed'
set ylabel 'Radio Duty Cycle (%)'
set yrange [0:12]
set ytics 0,3,12
set key top right
plot 'duty-cycle-result.txt' using 2:xtic(1) ti col lt -1 lw 4, '' u 3 ti col lt -1 lw 4, '' u 4 ti col lt -1 lw 4, '' u 5 ti col lt -1 lw 4, '' u 6 ti col lt -1 lw 4