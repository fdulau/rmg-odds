use lib "./lib";
use Test::More ( tests => 11 );

use_ok( 'OddsConverter' );

my @PROBABILITIES = qw( 0.9901 0.9 0.75 0.6667 0.5 0.3333 0.25 0.1 0.0099  );
my @DECIMALS      = qw(1.01 1.11 1.33 1.50 2.00 3.00 4.00 10.00 101.01 );
my @ROIS          = qw( 1% 11% 33% 50% 100% 200% 300% 900% 10001%  );

foreach my $ind ( 0 .. $#PROBABILITIES )
{
    subtest "probability " . $PROBABILITIES[$ind] => sub {
        my $oc = new_ok( 'OddsConverter' => [ probability => $PROBABILITIES[$ind] ] );
        is( $oc->decimal, $DECIMALS[$ind], 'decimal odds are ' . $DECIMALS[$ind] );
        is( $oc->roi,          $ROIS[$ind],     'ROI is ' . $ROIS[$ind] );
    };
}

subtest 'ROI 900' => sub {
    my $oc = new_ok( 'OddsConverter' => [ roi => 900 ] );
    is( $oc->decimal,   '10.00', 'decimal odds are 10.00' );
    is( $oc->win_break, '10.00', 'Win break is 10%' );
};

