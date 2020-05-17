@delay[1650];
@is_cal[1650];
@rec[1650];
@src[1650];
@time_rec[1650];
@src_delay[1650];
@tail_time[1650];
@hop[1650];

@count[30];
@avg_delay[30];
@com_time[30];
@last_id[30];
@max_tail_time[30];
@max_tail_id[30];
@avg_tail_time[30];

@all_tail[1650];
$tail_count;

@duty_cyle[51];
@tmp_tail_time[51];

for ($i = 0; $i < 30; $i++) {
	@delay[$i] = 0;
	@time_rec[$i] = 0;
	@is_cal[$i] = 1;
	@rec[$i] = 1;
}

for ($i = 0; $i < 51; $i++) {
	for ($j = 0; $j < 30; $j++) {
		@rec[$i*30+$j] = 0;
	}
	$log_file = "$i.log";
	open fin, "<$log_file" or die "could not open file!\n";
	while (<fin>) {
      chomp;
      @log = split;
      #if (@log[0] eq "Thread[Thread-1,5,main]") {
      #	@log[0] = @log[1];
      #	@log[1] = @log[2];
      #	@log[2] = @log[3];
      #}
      if (@log[0] eq "Thread[Thread-1,5,main]radio") {
        @log[0] = "radio";
      }

      if (@log[0] eq "radio") {
      	$time_h = @log[1];
      	$time_l = @log[2];
        @tmp_tail_time[$i] = $time_h * 65536 + $time_l;
      } elsif (@log[0] eq "delay") {
        $seq_no = @log[1];
        if ($seq_no < 30) {
        	@rec[$i*30+$seq_no] = 1;
        	@src[$i*30+$seq_no] = @log[2];
        	@time_rec[$i*30+$seq_no] = @log[3] * 65535 + @log[4];
        	@src_delay[$i*30+$seq_no] = @log[5] * 65535 + @log[6];

            @tail_time[$i*30+$seq_no] = @time_rec[$i*30+$seq_no] - @tmp_tail_time[$i];
        }
      } elsif (@log[0] eq "flood") {
      	$seq_no = @log[1];
      	if ($seq_no < 30) {
      		@time_rec[$seq_no] = @log[2] * 65535 + @log[3];
      	}
      } elsif (@log[0] eq "energy") {
        $radio_on_time = @log[3]*65535 + @log[4];
        $time_now = @log[1]*65535 + @log[2];
        @duty_cycle[$i] = $radio_on_time / $time_now;
      }
    }
    close fin;
}

$hops = 1;
for ($i = 0; $i < 30; $i++) {
	@hop[$i] = 0;
}

while ($hops < 10) {
for ($i = 0; $i < 30; $i++) {
	for ($j = 1; $j < 51; $j++) {
		if (@rec[$j*30+$i] == 1) {
			if (@is_cal[$j*30+$i] == 0) {
				if (@is_cal[@src[$j*30+$i]*30+$i] == 1) {
					@delay[$j*30+$i] = @delay[@src[$j*30+$i]*30+$i] + @src_delay[$j*30+$i] - @time_rec[@src[$j*30+$i]*30+$i];
					#if ($hops == 1) {
					#	printf "hops $hops nodeid $j srcid @src[$j*10+$i] src_delay @src_delay[$j*10+$i] delay @delay[$j*10+$i]\n";
					#}
					@is_cal[$j*30+$i] = 1;
					@hop[$j*30+$i] = @hop[@src[$j*30+$i]*30+$i] + 1;
				}
			}
		}
	}
}
$hops++;
}

$avg_duty_cycle = 0;
for ($i = 0; $i < 51; $i++) {
    #printf "@duty_cycle[$i]\n";
    $avg_duty_cycle += @duty_cycle[$i];
}
$avg_duty_cycle = $avg_duty_cycle / 51;
printf "average duty cycle $avg_duty_cycle\n";


$tail_count = 0;
$avg_50delay = 0;
$avg_50tail = 0;
$avg_50count = 0;
for ($i = 0; $i < 30; $i++) {
=pod
	@count[$i]=0;
	@avg_delay[$i]=0;
	for ($j = 1; $j < 50; $j++) {
		if (@rec[$j*10+$i] == 1 && @is_cal[$j*10+$i] == 1) {
			@count[$i]++;
			@avg_delay[$i]+=@delay[$j*10+$i];
		}
	}
	if (@count[$i]>0) {
		@avg_delay[$i] = @avg_delay[$i] / @count[$i];
	}
	printf "count @count[$i] average delay @avg_delay[$i]\n";
=cut
	@count[$i]=0;
	@avg_delay[$i]=0;
	@com_time[$i]=0;
	@max_tail_time[$i]=0;
	@avg_tail_time[$i]=0;
	for ($j = 1; $j < 51; $j++) {
		if (@rec[$j*30+$i] == 1 && @is_cal[$j*30+$i] == 1) {
			@count[$i]++;
			@avg_delay[$i]+=@delay[$j*30+$i];
			if (@delay[$j*30+$i] > @com_time[$i]) {
				@com_time[$i] = @delay[$j*30+$i];
				@last_id[$i] = $j;
			}
			@all_tail[$tail_count] = @tail_time[$j*30+$i];
			$tail_count++;
			@avg_tail_time[$i]+=@tail_time[$j*30+$i];
			if (@tail_time[$j*30+$i] > @max_tail_time[$i]) {
				@max_tail_time[$i] = @tail_time[$j*30+$i];
				@max_tail_id[$i] = $j;
			}
		}
	}
	if (@count[$i]>0) {
		@avg_delay[$i] = @avg_delay[$i] / @count[$i];
		@avg_tail_time[$i] = @avg_tail_time[$i] / @count[$i];
	}

    #printf "count @count[$i] completion time @com_time[$i] id @last_id[$i] hop @hop[@last_id[$i]*30+$i] tail @tail_time[@last_id[$i]*30+$i] max tail time @max_tail_time[$i] id @max_tail_id[$i] delay @delay[@max_tail_id[$i]*30+$i] hop @hop[@max_tail_id[$i]*30+$i] avg @avg_tail_time[$i]\n";
    if (@rec[1500+$i] == 1 && @is_cal[1500+$i] == 1) {
        if (@src[1500+$i] != 0) {
          $avg_50delay += @delay[1500+$i];
          $avg_50tail += @tail_time[1500+$i];
          $avg_50count++;
        }
        printf "delay @delay[1500+$i] tail @tail_time[1500+$i] elder @src[1500+$i]\n";
    }

}

$avg_50delay = $avg_50delay / $avg_50count;
$avg_50tail = $avg_50tail / $avg_50count;
printf "average delay $avg_50delay, average tail $avg_50tail\n";

=pod
printf "$tail_count\n";
if ($tail_count != 0) {
  for ($j = 1; $j < $tail_count; $j++) {
  	$k = $j - 1;
  	$tmp_tail = @all_tail[$j];
  	while ($tmp_tail < @all_tail[$k] and $k >= 0) {
  	  @all_tail[$k+1] = @all_tail[$k];
  	  $k--;
  	}
  	@all_tail[$k+1] = $tmp_tail;
  }
  $data = "tail_time_cdf.txt";
  open $dataout, ">$data" or die "could not open $data!\n";
  $cdf_count = 0;
  $cdf_delta = 0;
  for ($j = 0; $j < 1650 and $cdf_count < $tail_count; $j++) {
  	while ($cdf_count < $tail_count and @all_tail[$cdf_count] <= $cdf_delta) {
  		#printf "@delta_valid[$cdf_count]\n";
  		$cdf_count++;
  	}
  	$percentage = $cdf_count / $tail_count;
  	print $dataout "$cdf_delta $percentage\n";
  	$cdf_delta = $cdf_delta + 2;
  }
  close $dataout;
}

{
	$gnufile = "tail_cdf.plt";
	open gnuout, ">$gnufile" or die "could not open $gnufile!\n";
	print gnuout "set term post eps color solid enh 'ArialMT' 26\n";
	print gnuout "set output 'tail_cdf.eps'\n";
	#print gnuout "set xrange [0:100000]\n";
	print gnuout "set xlabel 'Tail Length'\n";
	print gnuout "set ylabel 'CDF'\n";
	print gnuout "set yrange [0:1]\n";
    print gnuout "set key off\n";
	#print gnuout "set size ratio 0.25\n";
	#print gnuout "set key bottom right\n";
    #print gnuout "set key top left\n";
	#print gnuout "set key samplen 2 spacing 2 font ',22' box lw 2\n";
	print gnuout "plot 'tail_time_cdf.txt' u 1:2 title '40 Bytes' with linespoints pt 4 ps 1 lw 2, ";
	close gnuout;

	system "gnuplot tail_cdf.plt";
}
=cut
