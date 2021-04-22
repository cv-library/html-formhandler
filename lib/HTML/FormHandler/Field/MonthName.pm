package HTML::FormHandler::Field::MonthName;
# ABSTRACT: select list with month names
our $VERSION = '100.000001';
use Moose;
extends 'HTML::FormHandler::Field::Select';

sub build_options {
    my $i      = 1;
    my @months = qw/
        January
        February
        March
        April
        May
        June
        July
        August
        September
        October
        November
        December
        /;
    return [ map { { value => $i++, label => $_ } } @months ];
}

=head1 DESCRIPTION

Generates a list of English month names.

=cut

__PACKAGE__->meta->make_immutable;
use namespace::autoclean;
1;
