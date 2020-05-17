{
	$gnufile = "multi-protocol.plt";
	open gnuout, ">$gnufile" or die "could not open $gnufile!\n";
	print gnuout "set term post eps color solid enh 'ArialMT' 26\n";
	print gnuout "set boxwidth 0.8 absolute\n";
    print gnuout "set xrange [0:26] noreverse nowriteback\n";
    print gnuout "set xtics (\"Chase\" 1, \"LPL\" 7, \"AMAC\" 13, \"Flooding\" 19, \"Contiki\" 25)\n";
	print gnuout "set output 'mp_ct.eps'\n";
	print gnuout "set ylabel 'Completion Time (ms)'\n";
	#print gnuout "set xrange [20:130]\n";
	#print gnuout "set xlabel 'Packet Length (Bytes)'\n";
	#print gnuout "set ylabel 'Completion Time (ms)'\n";
	#print gnuout "set ylabel 'PRR'\n";
	#print gnuout "set yrange [0.9:1]\n";
	#print gnuout "set ytics 0.9,0.02,1\n";
	print gnuout "set yrange [0:21000]\n";
	print gnuout "set ytics 0,3000,21000\n";
	#print gnuout "set xtics 20,10,130\n";
    #print gnuout "set key off\n";
	print gnuout "set size ratio 0.66\n";
	#print gnuout "set key bottom right\n";
    print gnuout "set key top left\n";
	print gnuout "set key samplen 3 spacing 2 font ',22'\n";
	#print gnuout "plot 'pl_ct.txt' u 1:2:3:4 with yerrorlines pt 4 ps 3 lw 6 notitle";
	#print gnuout "plot 'prr_ippi.txt' u 1:2 with linespoints pt 4 ps 2 lw 6 title '1344{/Symbol=22 \\155}s', '' u 1:3 with linespoints pt 6 ps 2 lw 6 title '2624{/Symbol=22 \\155}s', '' u 1:4 with linespoints pt 8 ps 2 lw 6 title '3904{/Symbol=22 \\155}s'";
	#print gnuout "'x_distribution.txt' u 1:3 title 'Uniform' with linespoints pt 1 ps 1 lw 2,";
	#print gnuout "'x_distribution.txt' u 1:4 title 'Gaussian' with linespoints pt 10 ps 1 lw 2";
	print gnuout "plot 'mp_ct.txt' using 1:3:2:6:5 with candlesticks lt 3 lw 4 title '[25% - 75%]' whiskerbars, '' using 1:4:4:4:4 with candlesticks lt -1 lw 4 notitle\n";
	close gnuout;
	
	system "gnuplot multi-protocol.plt";
}

{
	$gnufile = "multi-protocol.plt";
	open gnuout, ">$gnufile" or die "could not open $gnufile!\n";
	print gnuout "set term post eps color solid enh 'ArialMT' 26\n";
	print gnuout "set boxwidth 0.8 absolute\n";
    print gnuout "set xrange [0:26] noreverse nowriteback\n";
    print gnuout "set xtics (\"Chase\" 1, \"LPL\" 7, \"AMAC\" 13, \"Flooding\" 19, \"Contiki\" 25)\n";
	print gnuout "set output 'mp_eg.eps'\n";
	print gnuout "set ylabel 'Radio Duty Cycle'\n";
	#print gnuout "set xrange [20:130]\n";
	#print gnuout "set xlabel 'Packet Length (Bytes)'\n";
	#print gnuout "set ylabel 'Completion Time (ms)'\n";
	#print gnuout "set ylabel 'PRR'\n";
	#print gnuout "set yrange [0.9:1]\n";
	#print gnuout "set ytics 0.9,0.02,1\n";
	print gnuout "set yrange [0:0.3]\n";
	#print gnuout "set ytics 0,3000,21000\n";
	#print gnuout "set xtics 20,10,130\n";
    #print gnuout "set key off\n";
	print gnuout "set size ratio 0.66\n";
	#print gnuout "set key bottom right\n";
    print gnuout "set key top left\n";
	print gnuout "set key samplen 3 spacing 2 font ',22'\n";
	#print gnuout "plot 'pl_ct.txt' u 1:2:3:4 with yerrorlines pt 4 ps 3 lw 6 notitle";
	#print gnuout "plot 'prr_ippi.txt' u 1:2 with linespoints pt 4 ps 2 lw 6 title '1344{/Symbol=22 \\155}s', '' u 1:3 with linespoints pt 6 ps 2 lw 6 title '2624{/Symbol=22 \\155}s', '' u 1:4 with linespoints pt 8 ps 2 lw 6 title '3904{/Symbol=22 \\155}s'";
	#print gnuout "'x_distribution.txt' u 1:3 title 'Uniform' with linespoints pt 1 ps 1 lw 2,";
	#print gnuout "'x_distribution.txt' u 1:4 title 'Gaussian' with linespoints pt 10 ps 1 lw 2";
	print gnuout "plot 'mp_eg.txt' using 1:3:2:6:5 with candlesticks lt 3 lw 4 title '[25% - 75%]' whiskerbars, '' using 1:4:4:4:4 with candlesticks lt -1 lw 4 notitle\n";
	close gnuout;
	
	system "gnuplot multi-protocol.plt";
}