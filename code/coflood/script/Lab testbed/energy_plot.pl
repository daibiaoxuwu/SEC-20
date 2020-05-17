{
	$gnufile = "energy.plt";
	open gnuout, ">$gnufile" or die "could not open $gnufile!\n";
	print gnuout "set term post eps color solid enh 'ArialMT' 26\n";
	#print gnuout "set style data histograms\n";
    #print gnuout "set style histogram rowstacked\n";
    #print gnuout "set boxwidth 0.6 relative\n";
    #print gnuout "set style fill pattern 2 border -1\n";
    #print gnuout "set style line 2 lt 1 lw 7\n";
	print gnuout "set output 'energy.eps'\n";
	print gnuout "set xrange [0:6]\n";
	print gnuout "set xtics ('10' 1, '20' 2, '30' 3, '40' 4, '50' 5)\n";
	print gnuout "set xlabel 'Number of Concurrent Senders'\n";
	print gnuout "set ylabel 'Radio Duty Cycle (%)'\n";
	print gnuout "set yrange [0:14]\n";
	print gnuout "set ytics 0,2,14\n";
    #print gnuout "set key off\n";
	#print gnuout "set size ratio 0.25\n";
	#print gnuout "set key bottom right\n";
    print gnuout "set key top right\n";
	print gnuout "set key samplen 2 spacing 2 font ',22' box lw 2\n";
	print gnuout "plot 'data.txt' using 1:2 with linespoints t 'Lab Testbed' lt 7 lw 4 ps 2 pt 4\n";
	close gnuout;

	system "gnuplot energy.plt";
}