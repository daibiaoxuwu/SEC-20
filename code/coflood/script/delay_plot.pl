{
	$gnufile = "delay.plt";
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
    print gnuout "set output 'delay.eps'\n";
	print gnuout "set xrange [0:6]\n";
    #print gnuout "unset xtics\n";
    #print gnuout "unset ytics\n";
    print gnuout "set key top right\n";
	print gnuout "set key samplen 2 spacing 2 font ',22'\n";
	print gnuout "set xtics ('10' 1, '20' 2, '30' 3, '40' 4, '50' 5)\n";
	print gnuout "set xlabel 'Number of Concurrent Senders'\n";
    print gnuout "set ylabel 'Completion Time (ms)'\n";
    print gnuout "set yrange [1000:2200]\n";
    print gnuout "set ytics 1000,200,2200\n";
    #print gnuout "set key off\n";
	#print gnuout "set size ratio 0.25\n";
	#print gnuout "set key bottom right\n";
	print gnuout "plot 'lab_data.txt' using 1:3 with linespoints t 'Lab Testbed' lt 7 lw 4 lc rgb 'black' ps 2 pt 4, 'indriya_data.txt' using 1:3 with linespoints t 'Indriya Testbed' lt 4 lw 4 lc rgb 'red' ps 2 pt 8\n";
    #print gnuout "unset multiplot\n";
	close gnuout;

	system "gnuplot delay.plt";
}
