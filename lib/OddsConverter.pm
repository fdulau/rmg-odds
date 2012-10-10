package OddsConverter;

=head1 NAME

OddsConverter

=head1 SYNOPSIS

    my $oc = OddsConverter->new(probability => 0.5);
    print $oc->decimal_odds;    # '2.00' (always to 2 decimal places)
    print $oc->roi;             # '100%' (always whole numbers or 'Inf.')

=head1 COMMENT
    
    This version use the 'old fashion' module declaration.
    This easy the possibility to create a self contained package with PAR to distribute the module on computer with obsolete OS/PERL version.

=cut

use strict;
use Carp;
use Scalar::Util qw(looks_like_number);

use fields qw{ probability probability_rounded fractional fractional_rounded win_break win_break_rounded decimal decimal_rounded moneyline roi roi_rounded};

use vars qw( $VERSION );

$VERSION = '0.01';

=head1 METHODS


=over

=item B<new()>

Instanciate a new OddsConverter object
a parameter is needed to start the conversion.
	

=over 

=item List of possible parameters:

=over 
	
=item I<probability>
	
=item I<fractional>

=item I<decimal>

=item I<win_break>

=item I<moeny_line>

=item I<roi>
	
=back			

Example:

	my $oc = OddsConverter->new( probability => 0.5 );

=back

=back

=cut

sub new
{
#  my ( $class ) = @_;

    my $self = shift;
    no strict "refs";
    $self                  = fields::new( $self );

    my $empty_flag;
    if ( exists { @_ }->{ probability } )
    {  
        $empty_flag++;
       	if ( ! looks_like_number( { @_ }->{ probability } ))
	{
	croak 'No non-numeric probabilities';
	}
        if ( { @_ }->{ probability } < 0 || { @_ }->{ probability } > 1 )
        {
            croak "Probability must in the range ]0,1]";
        }

	$self->{ probability } = sprintf("%.10g", { @_ }->{ probability });
        _from_probability( $self );
    }
    if ( exists { @_ }->{ fractional } )
    {  
        $empty_flag++;
        if ( { @_ }->{ fractional } < 0 )
        {
           croak  "Fractional must be a positive value";
        }
	$self->{ fractional }  = sprintf("%.10g", { @_ }->{ fractional });
        _from_fractional( $self );
    }
    if ( exists { @_ }->{ decimal } )
    {  
        $empty_flag++;
        if ( { @_ }->{ decimal } < 1 )
        {
            croak "Decimal must be greater than 1";
        }
	$self->{ decimal }     = sprintf("%.10g", { @_ }->{ decimal });
        _from_decimal( $self );
    }
    if ( exists { @_ }->{ win_break } )
    {  
        $empty_flag++;
    if ( { @_ }->{ win_break } < 0 || { @_ }->{ win_break } >= 100 )
        {
            croak "Win_break must in the range ]0,100[";
        }
	$self->{ win_break }   = { @_ }->{ win_break };
        _from_win_break( $self );
    }
    if ( exists { @_ }->{ roi } )
    {  
        $empty_flag++;    
	$self->{ roi }         = sprintf("%.10g", { @_ }->{ roi });
        _from_roi( $self );
    }
    if ( exists { @_ }->{ moneyline } )
    {  
        $empty_flag++;    
	$self->{ moneyline }   = { @_ }->{ moneyline };
        _from_moneyline( $self );
    }
    
    if ( $empty_flag != 1 )
    {
    croak "We need one and only one parameter in the constructor";  
 
    }
    return $self;
}

=over

=item B<decimal_odds>

Without parameter, return the decimal odds for the object instantiate with the parameter from the method B<new()>

Example:

	print $oc->decimal_odds . "\n";
	
With a parameter, re-initialise the object instance with that decimal value
and return the new decimal odds value.

Example:

	print $oc->decimal_odds( 3 ) . "\n";
	
=back 

=cut

sub decimal_odds
{
    my ( $self, $val ) = @_;

    if ( $val )
    {
        $self->{ decimal } = $val;
        _from_decimal( $self );
    }

    return $self->{ decimal_rounded };
}

=over

=item B<roi>

Without parameter, return the roi ( return on investment ) for the object instantiate with the parameter from the method B<new()>

Example:

	print $oc->roi . "\n";
	
With a parameter, re-initialise the object instance with that roi value
and return the new roi value.

Example:

	print $oc->roi( 50 ) . "\n";
		
=back 

=cut

sub roi
{
    my ( $self, $val ) = @_;

    if ( $val )
    {
        $self->{ roi } = $val;
        _from_roi( $self );
    }

    return $self->{ roi_rounded };
}

=over

=item B<fractional_odds>

Without parameter, return the fractional odds for the object instantiate with the parameter from the method B<new()>

Example:

	print $oc->fractional_odds . "\n";
	
With a parameter, re-initialise the object instance with that fractional odds value
and return the new fractional odds value

Example:

	print $oc->fractional_odds( 50 ) . "\n";
			
=back 

=cut

sub fractional_odds
{
    my ( $self, $val ) = @_;

    if ( $val )
    {
        $self->{ fractional } = $val;
        _from_fractional( $self );
    }

    return $self->{ fractional_rounded };
}

=over

=item B<win_break_odds>

Without parameter, return the win to break even odds for the object instantiate with the parameter from the method B<new()>

Example:

	print $oc->win_break_odds . "\n";
	
With a parameter, re-initialise the object instance with that win_break odds value
and return the new win to break odds value

Example:

	print $oc->win_break_odds( 90 ) . "\n";
			
=back 

=cut

sub win_break_odds
{
    my ( $self, $val ) = @_;

    if ( $val )
    {
        $self->{ win_break } = $val;
        _from_win_break( $self );
    }

    return $self->{ win_break_rounded };
}

=over

=item B<probability_odds>

Without parameter, return the probability odds for the object instantiate with the parameter from the method B<new()>

Example:

	print $oc->probability_odds . "\n";
	
With a parameter, re-initialise the object instance with that probability odds value
and return the new win to probability odds value

Example:

	print $oc->probability_odds( 90 ) . "\n";		
	
=back 

=cut

sub probability_odds
{
    my ( $self, $val ) = @_;

    if ( $val )
    {
        $self->{ probability } = $val;
        _from_probability( $self );
    }

    return $self->{ probability_rounded };
}

=over

=item B<money_line_odds>

Without parameter, return the moneyline odds for the object instantiate with the parameter from the method B<new()>

Example:

	print $oc->money_line_odds . "\n";
	
With a parameter, re-initialise the object instance with that moneyline odds value
and return the new win to moneyline odds value

Example:

	print $oc->moneyline_odds( 90 ) . "\n";		
	
=back 

=cut

sub money_line_odds
{
    my ( $self, $val ) = @_;

    my @head = ( '', '+/-', '+' );
    my $head_ind = 1 + ( $self->{ moneyline } <=> 100 );

    if ( $val )
    {
        $self->{ moneyline } = $val;
        _from_moneyline( $self );
    }

    return $head[$head_ind] . $self->{ moneyline };
}

sub _from_probability
{
    my ( $self ) = @_;

    $self->{ probability_rounded } = sprintf( "%.2f", $self->{ probability } );
    if (  $self->{ probability } == 0 )
    {
    $self->{ decimal } = $self->{ decimal_rounded } ='Inf.';
    $self->{ roi } = $self->{ roi_rounded }='Inf.';
    $self->{ fractional } =0;
    $self->{ fractional_rounded }  = sprintf( "%.2f", $self->{ fractional } );
    $self->{ moneyline } = '-Inf.';
    }
    elsif (  $self->{ probability } == 1 )
    {
    $self->{ decimal } = 1;
    $self->{ decimal_rounded }     = sprintf( "%.2f", $self->{ decimal } );
    $self->{ roi } = 0;
    $self->{ roi_rounded }         = sprintf( "%.0f%%", $self->{ roi } );
    $self->{ fractional } =0;
    $self->{ fractional_rounded }  = sprintf( "%.2f", $self->{ fractional } );
    $self->{ moneyline } = '+Inf.'; 
    }
    else
    {
    $self->{ win_break }           = $self->{ probability } * 100;
    $self->{ win_break_rounded }   = sprintf( "%.2f", $self->{ win_break } );
    $self->{ decimal }             = (100 / $self->{ win_break } );
    $self->{ fractional }          = $self->{ decimal } - 1;
    $self->{ decimal_rounded }     = sprintf( "%.2f", $self->{ decimal } );
    $self->{ fractional_rounded }  = sprintf( "%.2f", $self->{ fractional } );
    $self->{ moneyline }           = $self->{ fractional } < 1 ? -(100 / $self->{ fractional } ) : $self->{ fractional } * 100 ;
    $self->{ roi }                 = 100 * $self->{ fractional };
    $self->{ roi_rounded }         = sprintf( "%.0f%%", $self->{ roi }  );
}

    return $self;
}

sub _from_roi
{
    my ( $self ) = @_;

    $self->{ roi_rounded }         = sprintf( "%.2f", $self->{ roi } );
    $self->{ fractional }          = $self->{ roi } / 100;
    $self->{ fractional_rounded }  = sprintf( "%.2f", $self->{ fractional } );
    $self->{ decimal }             = $self->{ fractional } + 1;
    $self->{ decimal_rounded }     = sprintf( "%.2f", $self->{ decimal } );
    $self->{ moneyline }           = $self->{ fractional } < 1 ? -(100 / $self->{ fractional } ) : $self->{ fractional } * 100 ;
    $self->{ win_break }           = 100 / ( $self->{ fractional } + 1 );
    $self->{ win_break_rounded }   = sprintf( "%.2f", $self->{ win_break } );
    $self->{ probability }         = $self->{ win_break } / 100;
    $self->{ probability_rounded } = sprintf( "%.2f", $self->{ probability } );

     return $self;
}

sub _from_win_break
{
    my ( $self ) = @_;

    $self->{ probability } = $self->{ win_break } / 100;
    _from_probability( $self );

    return $self;
}

sub _from_fractional
{
    my ( $self ) = @_;

    $self->{ roi } = 100 * $self->{ fractional };
    _from_roi( $self );

    return $self;
}

sub _from_decimal
{
    my ( $self ) = @_;

    $self->{ fractional } = $self->{ decimal } - 1;
    _from_fractional( $self );

    return $self;
}

sub _from_moneyline
{
    my ( $self ) = @_;

    if ( $self->{ moneyline } =~ /^\+\/-(\d+)/ )
    {
        if ( $1 == 100 )
        {
            $self->{ moneyline } = 100;
        }
        else
        {
            carp "Moneyline value must be a numerical value positive, negative or the special value '+/-100'";
        }
    }
        
     $self->{ fractional }           = $self->{ moneyline } < 0 ? -(100 / $self->{ moneyline } ) : $self->{ moneyline } * 100 ;

    _from_fractional( $self );

    return $self;
}

=head1 EXAMPLE


	#!/usr/bin/perl

	use strict;
	use feature qw( say );
	use Data::Dumper;

	use OddsConverter;

	my $p = 0.5;
	my $oc = OddsConverter->new( probability => $p );
	say "Test probability ($p)";
	say "decimal=" . $oc->decimal_odds;  
	say "fractional=" . $oc->fractional_odds;
	say "probability=" . $oc->probability_odds;
	say "win_break=" . $oc->win_break_odds;
	say "roi=" . $oc->roi;
	say "money line=" . $oc->money_line_odds;
	say "";
	
	my $m = '-300';
	say "new from moneyline ($m)";
	say "new money line=" . $oc->money_line_odds($m);
	say "decimal=" . $oc->decimal_odds;  
	say "fractional=" . $oc->fractional_odds;
	say "probability=" . $oc->probability_odds;
	say "win_break=" . $oc->win_break_odds;
	say "roi=" . $oc->roi;
	say "money line=" . $oc->money_line_odds;
	say "";
	

=head1 AUTHOR

Fabrice Dulaunoy <fabrice@dulaunoy.com>

October 2012

=head1 LICENSE

Under the GNU GPL2

    
    This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public 
    License as published by the Free Software Foundation; either version 2 of the License, 
    or (at your option) any later version.

    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
    without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
    See the GNU General Public License for more details.

    You should have received a copy of the GNU General Public License along with this program; 
    if not, write to the Free Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

     OddsConverter   Copyright (C) 2010 DULAUNOY Fabrice.  OddsConverter comes with ABSOLUTELY NO WARRANTY; 
    for details See: L<http://www.gnu.org/licenses/gpl.html> 
    This is free software, and you are welcome to redistribute it under certain conditions;
   

=cut

1;
