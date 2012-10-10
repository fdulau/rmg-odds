use Test::More ( tests => 7 );

use_ok( 'OddsConverter' );

subtest 'even money' => sub {
    my $oc = new_ok( 'OddsConverter' => [ probability => 0.5 ] );
    is( $oc->decimal_odds, '2.00', 'Even money decimal odds are 2.00' );
    is( $oc->roi,          '100%', 'Even money ROI is 100%' );
};

subtest 'no chance' => sub {
    my $oc = new_ok( 'OddsConverter' => [ probability => 0 ] );
    is( $oc->decimal_odds, 'Inf.', 'No chance decimal odds are infinite' );
    is( $oc->roi,          'Inf.', 'No chance ROI is infinite' );
};

subtest 'sure thing' => sub {
    my $oc = new_ok( 'OddsConverter' => [ probability => 1 ] );
    is( $oc->decimal_odds, '1.00', 'Sure thing decimal odds are 1.00' );
    is( $oc->roi,          '0%',   'Sure thing ROI is 0%' );
};

subtest 'unlikely' => sub {
    my $oc = new_ok( 'OddsConverter' => [ probability => 0.1 ] );
    is( $oc->decimal_odds, '10.00', 'An unlikely event decimal odds might be 10.00' );
    is( $oc->roi,          '900%',  'An unlikely event ROI might be 900%' );
};

subtest 'likely' => sub {
    my $oc = new_ok( 'OddsConverter' => [ probability => 0.8 ] );
    is( $oc->decimal_odds, '1.25', 'A likely event decimal odds might be 1.25' );
    is( $oc->roi,          '25%',  'A likely event ROI might be 25%' );
};

subtest 'rounded' => sub {
    my $oc = new_ok( 'OddsConverter' => [ probability => 0.6 ] );
    is( $oc->decimal_odds, '1.67', 'Standard rounding rules apply for repeating decimal odds' );
    is( $oc->roi,          '67%',  'Standard rounding rules apply for ROI, as well' );
  }
