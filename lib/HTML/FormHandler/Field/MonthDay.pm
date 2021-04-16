package HTML::FormHandler::Field::MonthDay;
# ABSTRACT: select list 1 to 31
our $VERSION = '100.000000';
use Moose;
extends 'HTML::FormHandler::Field::IntRange';

has '+range_start' => ( default => 1 );
has '+range_end'   => ( default => 31 );

=head1 DESCRIPTION

Generates a select list for integers 1 to 31.

=cut

__PACKAGE__->meta->make_immutable;
use namespace::autoclean;
1;
