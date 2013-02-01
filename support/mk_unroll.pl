#!/usr/bin/perl
# mk_unroll.pl - spew out unrolled assembly for tuner/decimator

for($i=0;$i<32;$i=$i+1)
{
	$iter = 2*$i;
	$iter1 = $iter+1;
	$j = 4*$i;
	$k = 2*$j;
	print "\t/* iterations $iter, $iter1 */\n";
	print "\tldrd   r4, [r1, #$k]		/* get LO I1,I2,Q1,Q2 */\n";
	print "\tldr    r6, [r0, #$j]		/* get RF data 1,2 */\n";
	print "\tsmlad  r8, r6, r4, r8		/* Dual MAC I */\n";
	print "\tsmlad  r9, r6, r5, r9		/* Dual MAC Q */\n";
	print "\n";
}
