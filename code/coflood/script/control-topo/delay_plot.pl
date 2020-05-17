{
	$gnufile = "delay.plt";
	open gnuout, ">$gnufile" or die "could not open $gnufile!\n";
	print gnuout "set term post eps color solid enh 'ArialMT' 26\n";
	print gnuout "set style data histograms\n";
    print gnuout "set style histogram rowstacked\n";
    print gnuout "set boxwidth 0.6 relative\n";
    print gnuout "set style fill pattern 2 border -1\n";
    #print gnuout "set style line 2 lt 1 lw 7\n";
	print gnuout "set output 'delay.eps'\n";
	#print gnuout "set xrange [0:100000]\n";
	print gnuout "set xlabel 'Number of Concurrent Senders'\n";
	print gnuout "set ylabel 'Receiving Delay of R (ms)'\n";
	#print gnuout "set yrange [0:1]\n";
    #print gnuout "set key off\n";
	#print gnuout "set size ratio 0.25\n";
	#print gnuout "set key bottom right\n";
    print gnuout "set key top center\n";
	print gnuout "set key samplen 2 spacing 2 font ',22' box lw 2\n";
	print gnuout "plot 'delay.txt' using 4 t 'Sleep' lc rgb 'grey' lw 4, '' using 3:xticlabels(1) t 'Tail' lc rgb 'black' lw 4\n";
	close gnuout;

	system "gnuplot delay.plt";
}
