{
	$gnufile = "ll-coflood-result-plot.plt";
	open gnuout, ">$gnufile" or die "could not open $gnufile!\n";
    #print gnuout "set tmargin 0\n";
    #print gnuout "set bmargin 0\n";
    #print gnuout "set lmargin 3\n";
    #print gnuout "set rmargin 3\n";
	print gnuout "set term post eps color solid enh 'ArialMT' 26\n";
	#print gnuout "set style data histograms\n";
    #print gnuout "set style histogram rowstacked\n";
    #print gnuout "set boxwidth 0.6 relative\n";
    #print gnuout "set style fill pattern 2 border -1\n";
    #print gnuout "set style line 2 lt 1 lw 7\n";
    #print gnuout "set multiplot layout 2,1\n";
    print gnuout "set output 'll-coflood.eps'\n";
	print gnuout "set xrange [0:6]\n";
    #print gnuout "unset xtics\n";
    #print gnuout "unset ytics\n";
    print gnuout "set key top right\n";
	print gnuout "set key samplen 2 spacing 2 font ',22'\n";
	print gnuout "set xtics ('512' 1, '640' 2, '768' 3, '896' 4, '1024' 5)\n";
	print gnuout "set xlabel 'Long Link Threshold (ms)'\n";
    print gnuout "set ylabel 'Compeletion Time (ms)'\n";
    print gnuout "set yrange [800:2400]\n";
    print gnuout "set ytics 800,400,3000\n";
    #print gnuout "set key off\n";
	#print gnuout "set size ratio 0.25\n";
	#print gnuout "set key bottom right\n";
    print gnuout "plot 'll-coflood-result.txt' using 2:4 with linespoints t 'Lab Testbed' lt 7 lw 4 lc rgb 'black' ps 2 pt 4, 'll-coflood-result.txt' using 2:3 with linespoints t 'Indriya Testbed' lt 4 lw 4 lc rgb 'red' ps 2 pt 8\n";
    #print gnuout "unset multiplot\n";
	close gnuout;

	system "gnuplot ll-coflood-result-plot.plt";
}
