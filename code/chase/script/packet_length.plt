set term post eps color solid enh 'ArialMT' 26
set output 'pl_eg.eps'
set xrange [20:130]
set xlabel 'Packet Length (Bytes)'
set ylabel 'Radio Duty Cycle'
set xtics 20,10,130
plot 'pl_eg.txt' u 1:2:3:4 with yerrorlines pt 4 ps 3 lw 6 notitle