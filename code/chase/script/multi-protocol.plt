set term post eps color solid enh 'ArialMT' 26
set boxwidth 0.8 absolute
set xrange [0:26] noreverse nowriteback
set xtics ("Chase" 1, "LPL" 7, "AMAC" 13, "Flooding" 19, "Contiki" 25)
set output 'mp_eg.eps'
set ylabel 'Radio Duty Cycle'
set yrange [0:0.3]
set size ratio 0.66
set key top left
set key samplen 3 spacing 2 font ',22'
plot 'mp_eg.txt' using 1:3:2:6:5 with candlesticks lt 3 lw 4 title '[25% - 75%]' whiskerbars, '' using 1:4:4:4:4 with candlesticks lt -1 lw 4 notitle
