{
	$gnufile = "completion-time-result.plt";
	open gnuout, ">$gnufile" or die "could not open $gnufile!\n";
	print gnuout "set term post eps color solid enh 'ArialMT' 24\n";
	print gnuout "set output 'completion-time-result.eps'\n";
	print gnuout "set style data histogram\n";
	print gnuout "set style histogram cluster gap 2\n";
	print gnuout "set style fill pattern 2 border\n";
	print gnuout "set boxwidth 1\n";
	print gnuout "set xlabel 'Testbed'\n";
	print gnuout "set ylabel 'Completion Time (ms)'\n";
	#print gnuout "set size ratio 0.25\n";
	print gnuout "set yrange [0:2400]\n";
	#print gnuout "set xrange [0:4]\n";
	print gnuout "set ytics 0,400,2400\n";
	#print gnuout "set boxwidth 0.25\n";
	print gnuout "set key top left\n";
	#print gnuout "set key bottom right\n";
	print gnuout "plot 'completion-time-result.txt' using 2:xtic(1) ti col lt -1 lw 4, '' u 3 ti col lt -1 lw 4, '' u 4 ti col lt -1 lw 4, '' u 5 ti col lt -1 lw 4, '' u 6 ti col lt -1 lw 4";
	close gnuout;
	
	system "gnuplot completion-time-result.plt";
}