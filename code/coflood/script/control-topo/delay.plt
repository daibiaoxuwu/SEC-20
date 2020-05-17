set term post eps color solid enh 'ArialMT' 26
set style data histograms
set style histogram rowstacked
set boxwidth 0.6 relative
set style fill pattern 2 border -1
set output 'delay.eps'
set xlabel 'Number of Concurrent Senders'
set ylabel 'Receiving Delay of R (ms)'
set key top center
set key samplen 2 spacing 2 font ',22' box lw 2
plot 'delay.txt' using 4 t 'Sleep' lc rgb 'grey' lw 4, '' using 3:xticlabels(1) t 'Tail' lc rgb 'black' lw 4
