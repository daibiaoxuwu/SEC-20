set term post eps color solid enh 'ArialMT' 24
set output 'completion-time-result.eps'
set style data histogram
set style histogram cluster gap 2
set style fill pattern 2 border
set boxwidth 1
set xlabel 'Testbed'
set ylabel 'Completion Time (ms)'
set yrange [0:2400]
set ytics 0,400,2400
set key top left
plot 'completion-time-result.txt' using 2:xtic(1) ti col lt -1 lw 4, '' u 3 ti col lt -1 lw 4, '' u 4 ti col lt -1 lw 4, '' u 5 ti col lt -1 lw 4, '' u 6 ti col lt -1 lw 4